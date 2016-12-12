/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2016 Cell Cloud Team - www.cellcloud.net
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ------------------------------------------------------------------------------
 */

#import "CellSpeaker.h"
#import "CellNonblockingConnector.h"
#import "CellInetAddress.h"
#import "CellPacket.h"
#import "CellSession.h"
#import "CellMessage.h"
#import "CellLogger.h"
#import "CellCryptology.h"
#import "CellNucleusTag.h"
#import "CellNucleus.h"
#import "CellTalkCapacity.h"
#import "CellTalkService.h"
#import "CellTalkServiceFailure.h"
#import "CellPrimitive.h"
#import "CellUtil.h"
#include "CellTalkDefinition.h"


// Private

@interface CCSpeaker ()
{
@private
    NSMutableArray *_identifierList;

    CCInetAddress *_address;
    CCNonblockingConnector *_connector;

    NSData *_secretKey;

    CCNucleusTag *_remoteTag;

    NSObject *_monitor;

    NSTimer *_contactedTimer;
}

/// 数据处理入口
- (void)interpret:(CCSession *)session packet:(CCPacket *)packet;

/// 处理质询命令
- (void)processInterrogate:(CCPacket *)packet session:(CCSession *)session;

/// 处理进行完校验后操作
- (void)processCheck:(CCPacket *)packet session:(CCSession *)session;

/// 处理请求返回
- (void)processRequest:(CCPacket *)packet session:(CCSession *)session;

/// 会话
- (void)processDialogue:(CCPacket *)packet session:(CCSession *)session;

/// 请求 Cellet
- (void)requestCellets:(CCSession *)session;

/// 协商能力
- (void)requestConsult;

///
- (void)fireContacted:(NSString *)celletIdentifier;
///
- (void)fireQuitted:(NSString *)celletIdentifier;
///
- (void)fireFailed:(CCTalkServiceFailure *)failure;

@end


// Implementation

@implementation CCSpeaker

@synthesize identifiers = _identifierList;
@synthesize address = _address;
@synthesize remoteTag = _remoteTag;
@synthesize retryCounts = _retryCounts;
@synthesize retryEnd = _retryEnd;

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        _identifierList = [[NSMutableArray alloc] initWithCapacity:2];
        _contactedTimer = nil;
        self.capacity = nil;
        self.state = CCSpeakerStateHangUp;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWith:(CCInetAddress *)address
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        _identifierList = [[NSMutableArray alloc] initWithCapacity:2];
        _address = address;
        _contactedTimer = nil;
        self.capacity = nil;
        self.state = CCSpeakerStateHangUp;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithCapacity:(CCInetAddress *)address capacity:(CCTalkCapacity *)capacity
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        _identifierList = [[NSMutableArray alloc] initWithCapacity:2];
        _address = address;
        _contactedTimer = nil;
        self.capacity = capacity;
        self.state = CCSpeakerStateHangUp;
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    self.capacity = nil;

    _address = nil;
    _monitor = nil;
    _secretKey = nil;

    if (nil != _contactedTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_contactedTimer invalidate];
            _contactedTimer = nil;
        });
    }
}

#pragma mark - Public Method

//------------------------------------------------------------------------------
- (BOOL)call:(NSArray *)identifiers
{
    if (CCSpeakerStateCalling == self.state)
    {
        // 正在 Call 返回 false
        return FALSE;
    }

    if (nil != identifiers)
    {
        @synchronized (_identifierList)
        {
            for (NSString *identifier in identifiers)
            {
                if ([_identifierList containsObject:identifier])
                {
                    continue;
                }
                
                [_identifierList addObject:identifier];
            }
        }
    }

    if (_identifierList.count == 0)
    {
        [CCLogger e:@"Can not find any cellets to call in param 'identifiers'."];
        return FALSE;
    }

    if (nil == _connector)
    {
        char head[4] = {0x20, 0x10, 0x11, 0x10};
        char tail[4] = {0x19, 0x78, 0x10, 0x04};
        _connector = [[CCNonblockingConnector alloc] init:self
                                                 headMark:head
                                               headLength:4
                                                 tailMark:tail
                                               tailLength:4];
    }
    else
    {
        if ([_connector isConnected])
        {
            [_connector disconnect];
        }
    }

    self.state = CCSpeakerStateHangUp;

    CCSession *session = [_connector connect:_address.host port:_address.port];
    if (nil != session)
    {
        // 变更状态
        self.state = CCSpeakerStateCalling;
    }

    return (nil != session);
}
//------------------------------------------------------------------------------
- (BOOL)recall
{
    return [self call:_identifierList];
}

//------------------------------------------------------------------------------
- (void)fireRetryEnd
{
    // TODO
    CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                     initWithSource:CCFailureRetryEnd
                                     file:__FILE__
                                     line:__LINE__
                                     function:__FUNCTION__];
    failure.sourceDescription = @"Retry End";
    failure.sourceCelletIdentifiers = _identifierList;
    [self fireFailed:failure];
}
//------------------------------------------------------------------------------
- (void)hangUp
{
    if (nil != _connector)
    {
        if ([_connector isConnected])
        {
            [_connector disconnect];
        }
        else
        {
            // 没有连接则直接清空
            @synchronized (_identifierList) {
                [_identifierList removeAllObjects];
            }
        }

        _connector = nil;

        self.state = CCSpeakerStateHangUp;
    }
}
//------------------------------------------------------------------------------
- (BOOL)speak:(NSString *)identifier primitive:(CCPrimitive *)primitive
{
    if (nil == _connector
        || ![_connector isConnected]
        || self.state != CCSpeakerStateCalled)
    {
        return FALSE;
    }

    @synchronized(_monitor) {
        NSData *stream = [CCPrimitive write:primitive];

        // 封装数据包
        char ptag[] = TPT_DIALOGUE;
        CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:99 major:1 minor:0];
        [packet appendSubsegment:stream];
        [packet appendSubsegment:[[[CCNucleus sharedSingleton].tag getAsString] dataUsingEncoding:NSUTF8StringEncoding]];
        [packet appendSubsegment:[identifier dataUsingEncoding:NSUTF8StringEncoding]];

        NSData *data = [CCPacket pack:packet];
        if (nil != data)
        {
            CCMessage *message = [CCMessage messageWithData:data];
            [_connector write:message];

            return TRUE;
        }

        return FALSE;
    }
}
//------------------------------------------------------------------------------
- (BOOL)isCalled
{
    return self.state == CCSpeakerStateCalled;
}
//------------------------------------------------------------------------------
- (BOOL)heartbeat
{
    if (nil == _connector
        || ![_connector isConnected]
        || self.state != CCSpeakerStateCalled)
    {
        return FALSE;
    }
    // 心跳包（无包体）
    char ptag[] = TPT_HEARTBEAT;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:9 major:1 minor:0];
    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [CCMessage messageWithData:data];
        [_connector write:message];
    }
    return TRUE;
}

#pragma mark - Private Method

//------------------------------------------------------------------------------
- (void)interpret:(CCSession *)session packet:(CCPacket *)packet
{
    char tag[PSL_TAG + 1] = {0x0};
    [packet getTag:tag];

    if (tag[2] == TPT_DIALOGUE_B3 && tag[3] == TPT_DIALOGUE_B4)
    {
        [self processDialogue:packet session:session];
    }
    else if (tag[2] == TPT_REQUEST_B3 && tag[3] == TPT_REQUEST_B4)
    {
        [self processRequest:packet session:session];
    }
    else if (tag[2] == TPT_CONSULT_B3 && tag[3] == TPT_CONSULT_B4)
    {
        [self processConsult:packet session:session];
    }
    else if (tag[2] == TPT_CHECK_B3 && tag[3] == TPT_CHECK_B4)
    {
        [self processCheck:packet session:session];
    }
    else if (tag[2] == TPT_INTERROGATE_B3 && tag[3] == TPT_INTERROGATE_B4)
    {
        [self processInterrogate:packet session:session];
    }
}
//------------------------------------------------------------------------------
- (void)processInterrogate:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：密文|密钥
    char ciphertext[32] = {0x0};
    NSData *ctData = [packet getSubsegment:0];
    [ctData getBytes:ciphertext length:ctData.length];
    char key[16] = {0x0};
    NSData *kData = [packet getSubsegment:1];
    [kData getBytes:key length:kData.length];

    // 保存密钥
    _secretKey = nil;
    _secretKey = [[NSData alloc] initWithBytes:key length:kData.length];

    // 解密
    char plaintext[32] = {0x0};
    int plen = [[CCCryptology sharedSingleton] simpleDecrypt:plaintext
                    text:ciphertext length:(int)ctData.length key:key];

    // 回送数据进行服务器验证
    char tag[] = TPT_CHECK;
    CCPacket *response = [[CCPacket alloc] initWithTag:tag sn:2 major:1 minor:0];
    [response appendSubsegment:[NSData dataWithBytes:plaintext length:plen]];
    [response appendSubsegment:[[[CCNucleus sharedSingleton] getTagAsString] dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *data = [CCPacket pack:response];
    if (nil != data)
    {
        CCMessage *message = [CCMessage messageWithData:data];
        [session write:message];
    }
}
//------------------------------------------------------------------------------
- (void)processCheck:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：成功码|内核标签
    NSData *tagdata = [packet getSubsegment:1];
    char tag[64] = {0x0};
    [tagdata getBytes:tag length:tagdata.length];

    // 设置对端标签
    _remoteTag = [[CCNucleusTag alloc] initWithString:[[NSString alloc] initWithFormat:@"%s", tag]];

    // 请求进行协商
    [self requestConsult];
}
//------------------------------------------------------------------------------
- (void)processRequest:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：
    // 成功格式：请求方标签|成功码|Cellet识别串|Cellet版本
    // 失败格式：请求方标签|失败码

    // 返回码
    NSData *data = [packet getSubsegment:1];
    char sc[4] = {0x0};
    [data getBytes:sc length:data.length];
    
    char success[] = CCTS_SUCCESS;
    if (sc[0] == success[0] && sc[1] == success[1]
        && sc[2] == success[2] && sc[3] == success[3])
    {
        NSString *identifier = [[NSString alloc] initWithData:[packet getSubsegment:2] encoding:NSUTF8StringEncoding];
        [CCLogger d:@"Cellet %@ has called at %@:%d", identifier,
            [[session getAddress] getHost], [[session getAddress] getPort]];

        // 变更状态
        self.state = CCSpeakerStateCalled;

        // 调用回调
        [self fireContacted:identifier];
    }
    else
    {
        // 变更状态
        self.state = CCSpeakerStateHangUp;

        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCFailureNotFoundCellet
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];

        // 关闭连接
        [_connector disconnect];
    }
}
//------------------------------------------------------------------------------
- (void)processDialogue:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：原语序列|Cellet
    NSData *data = [packet getSubsegment:0];
    NSString *celletIdentifier = [[NSString alloc] initWithData:[packet getSubsegment:1] encoding:NSUTF8StringEncoding];

    CCPrimitive *primitive = [CCPrimitive read:data andTag:[_remoteTag getAsString]];
    if (nil != primitive)
    {
        // 设置对端标签
        primitive.ownerTag = [_remoteTag getAsString];
        primitive.celletIdentifier = celletIdentifier;
        
        BOOL delegated = (nil != [CCTalkService sharedSingleton].delegate && primitive.isDialectal);
        if (delegated)
        {
            BOOL ret = [[CCTalkService sharedSingleton].delegate doDialogue:primitive.celletIdentifier withDialect:primitive.dialect];
            if (!ret)
            {
                // 劫持对话
                return;
            }
        }

        if (nil != [CCTalkService sharedSingleton].listener)
        {
            [[CCTalkService sharedSingleton].listener dialogue:primitive.celletIdentifier primitive:primitive];
        }
        
        if (delegated)
        {
            [[CCTalkService sharedSingleton].delegate didDialogue:primitive.celletIdentifier withDialect:primitive.dialect];
        }
    }
}
//------------------------------------------------------------------------------
- (void)processConsult:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：源标签|能力描述序列化串

    CCTalkCapacity *newCapacity = [CCTalkCapacity deserialize:[packet getSubsegment:1]];
    if (nil == newCapacity)
    {
        // 请求 Cellet
        [self requestCellets:session];

        return;
    }

    // 更新
    if (nil == self.capacity)
    {
        self.capacity = newCapacity;
    }
    else
    {
        self.capacity.secure = newCapacity.secure;
        self.capacity.retryAttempts = newCapacity.retryAttempts;
        self.capacity.retryInterval = newCapacity.retryInterval;
    }

    [CCLogger w:@"Talk capacity has changed from '%@' : secure=%d attempts=%d delay=%f"
         , self.remoteTag
         , newCapacity.secure
         , newCapacity.retryAttempts
         , newCapacity.retryInterval];

    // 请求 Cellet
    [self requestCellets:session];
}
//------------------------------------------------------------------------------
- (void)requestConsult
{
    if (nil == self.capacity)
    {
        self.capacity = [[CCTalkCapacity alloc] init];
    }
    
    // 包格式：源标签|能力描述序列化数据
    char ptag[] = TPT_CONSULT;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:4 major:1 minor:0];
    [packet appendSubsegment:[[[CCNucleus sharedSingleton] getTagAsString] dataUsingEncoding:NSUTF8StringEncoding]];
    [packet appendSubsegment:[CCTalkCapacity serialize:self.capacity]];
    
    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [CCMessage messageWithData:data];
        [_connector write:message];
    }
}
//------------------------------------------------------------------------------
- (void)requestCellets:(CCSession *)session
{
    // 包格式：Cellet标识串|标签

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (_identifierList)
        {
            for (NSString *identifier in _identifierList)
            {
                char ptag[] = TPT_REQUEST;
                CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:3 major:1 minor:0];
                
                [packet appendSubsegment:[identifier dataUsingEncoding:NSUTF8StringEncoding]];
                [packet appendSubsegment:[[[CCNucleus sharedSingleton] getTagAsString] dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSData *data = [CCPacket pack:packet];
                if (nil != data)
                {
                    CCMessage *message = [CCMessage messageWithData:data];
                    [session write:message];
                }
            }
        }
    });
}
//------------------------------------------------------------------------------
- (void)handleContactedTimer:(NSTimer *)timer
{
    if (self.capacity.secure)
    {
        [[_connector getSession] activeSecretKey:[_secretKey bytes] keyLength:(int)_secretKey.length];
        [CCLogger i:@"Active secret key for server: %@:%d", _address.host, _address.port];
    }
    else
    {
        [[_connector getSession] deactiveSecretKey];
    }

    if (nil != [CCTalkService sharedSingleton].listener)
    {
        @synchronized (_identifierList)
        {
            for (NSString *celletIdentifier in _identifierList)
            {
                [[CCTalkService sharedSingleton].listener contacted:celletIdentifier tag:[_remoteTag getAsString]];
            }
        }
    }

    _contactedTimer = nil;
}
//------------------------------------------------------------------------------
- (void)fireContacted:(NSString *)celletIdentifier
{
    NSTimeInterval interval = 0.5f;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil != _contactedTimer)
        {
            [_contactedTimer invalidate];
            _contactedTimer = nil;
        }

        _contactedTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                           target:self
                                                         selector:@selector(handleContactedTimer:)
                                                         userInfo:celletIdentifier
                                                          repeats:NO];
    });

}
//------------------------------------------------------------------------------
- (void)fireQuitted:(NSString *)celletIdentifier
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil != _contactedTimer)
        {
            [_contactedTimer invalidate];
            _contactedTimer = nil;
        }
    });

    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener quitted:celletIdentifier tag:[_remoteTag getAsString]];
    }

    CCSession *session = [_connector getSession];
    if (nil != session)
    {
        [session deactiveSecretKey];
    }
}
//------------------------------------------------------------------------------
- (void)fireFailed:(CCTalkServiceFailure *)failure
{
    if (failure.code == CCFailureCallFailed)
    {
        // 变更状态
        self.state = CCSpeakerStateHangUp;
    }

    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener failed:failure];
    }
}

#pragma mark - Message Handle Delegate

//------------------------------------------------------------------------------
- (void)sessionCreated:(CCSession *)session
{
     // Nothing
}
//------------------------------------------------------------------------------
- (void)sessionDestroyed:(CCSession *)session
{
    // Nothing
    self.state = CCSpeakerStateHangUp;
}
//------------------------------------------------------------------------------
- (void)sessionOpened:(CCSession *)session
{
    // Nothing
}
//------------------------------------------------------------------------------
- (void)sessionClosed:(CCSession *)session
{
    // 判断是否为异常网络中断
    if (CCSpeakerStateCalling == self.state)
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc] initWithSource:CCFailureCallFailed
                                                                                file:__FILE__
                                                                                line:__LINE__
                                                                            function:__FUNCTION__];
        failure.sourceDescription = @"No network device";
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];
        
        // 标记为丢失
        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }
    else if (CCSpeakerStateCalled == self.state)
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc] initWithSource:CCFailureTalkLost
                                                                                file:__FILE__
                                                                                line:__LINE__
                                                                            function:__FUNCTION__];
        failure.sourceDescription = @"Network fault, connection closed";
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];
        
        // 标记为丢失
        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }

    self.state = CCSpeakerStateHangUp;

    // 通知退出
    @synchronized (_identifierList)
    {
        for (NSString *identifier in _identifierList)
        {
            [self fireQuitted:identifier];
        }
    }
}
//------------------------------------------------------------------------------
- (void)messageReceived:(CCSession *)session message:(CCMessage *)message
{
    CCPacket *packet = [CCPacket unpack:message.data];
    if (nil != packet)
    {
        [self interpret:session packet:packet];
    }   
}
//------------------------------------------------------------------------------
- (void)messageSent:(CCSession *)session message:(CCMessage *)message
{
}
//------------------------------------------------------------------------------
- (void)errorOccurred:(CCMessageErrorCode)errorCode session:(CCSession *)session
{
    [CCLogger d:@"errorOccurred - %d - %p", errorCode, session];

    if (errorCode == CCMessageErrorConnectEnd)
    {
        // 连接结束
        [CCLogger i:@"Connect end."];

        // 通知退出
        @synchronized (_identifierList)
        {
            for (NSString *identifier in _identifierList)
            {
                [self fireQuitted:identifier];
            }
        }
    }
    else if (errorCode == CCMessageErrorConnectTimeout)
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCFailureCallFailed
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceDescription = @"Attempt to connect to host timed out";
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];

        // 标记为丢失
        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }
    else if (errorCode == CCMessageErrorConnectFailed)
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCFailureCallFailed
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceDescription = @"Attempt to connect to host failed";
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];
        
        // 标记为丢失
        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }
    else if (errorCode >= CCMessageErrorSocketFailed)
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCFailureTalkLost
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceDescription = @"No network available";
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];

        // 标记为丢失
        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }
    else
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCFailureCallFailed
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceDescription = @"Unknown network error";
        failure.sourceCelletIdentifiers = _identifierList;
        [self fireFailed:failure];
        // 标记为丢失
        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }

    // 变更状态
    self.state = CCSpeakerStateHangUp;
}

@end
