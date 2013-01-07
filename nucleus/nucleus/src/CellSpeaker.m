/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2012 Cell Cloud Team - cellcloudproject@gmail.com
 
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
    NSString *_identifier;
    CCTalkCapacity *_capacity;
    
    CCInetAddress *_address;
    CCNonblockingConnector *_connector;
    
    CCNucleusTag *_remoteTag;
    
    NSObject *_monitor;
}

/// 数据处理入口
- (void)interpret:(CCSession *)session packet:(CCPacket *)packet;

/// 处理质询命令
- (void)processInterrogate:(CCPacket *)packet session:(CCSession *)session;

/// 处理进行完校验后操作
- (void)processCheck:(CCPacket *)packet session:(CCSession *)session;

/// 处理请求返回
- (void)processRequest:(CCPacket *)packet session:(CCSession *)session;

/// 处理协商
- (void)processConsult:(CCPacket *)packet session:(CCSession *)session;

/// 处理挂起
- (void)processSuspend:(CCPacket *)packet session:(CCSession *)session;

/// 处理恢复
- (void)processResume:(CCPacket *)packet session:(CCSession *)session;

/// 会话
- (void)processDialogue:(CCPacket *)packet session:(CCSession *)session;

/// 请求 Cellet
- (void)requestCellet:(CCSession *)session;

/// 协商能力
- (void)consult:(CCTalkCapacity *)capacity;

///
- (void)fireContacted;
///
- (void)fireQuitted;
///
- (void)fireSuspended:(NSTimeInterval)timestamp mode:(CCSuspendMode)mode;
///
- (void)fireResumed:(NSTimeInterval)timestamp primitive:(CCPrimitive *)primitive;
///
- (void)fireFailed:(CCTalkServiceFailure *)failure;

@end


// Implementation

@implementation CCSpeaker

@synthesize identifier = _identifier;
@synthesize address = _address;
@synthesize remoteTag = _remoteTag;

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        self.state = CCSpeakerStateHangUp;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithIdentifier:(NSString *)identifier
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        _identifier = identifier;
        self.state = CCSpeakerStateHangUp;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithCapacity:(NSString *)identifier capacity:(CCTalkCapacity *)capacity
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        _identifier = identifier;
        _capacity = capacity;
        self.state = CCSpeakerStateHangUp;
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
}

#pragma mark - Public Method

//------------------------------------------------------------------------------
- (BOOL)call:(CCInetAddress *)address
{
    if (nil == _connector)
    {
        char head[4] = {0x20, 0x10, 0x11, 0x10};
        char tail[4] = {0x19, 0x78, 0x10, 0x04};
        _connector = [[CCNonblockingConnector alloc] initWithDataMark:self
                                                             headMark:head
                                                           headLength:4
                                                             tailMark:tail
                                                           tailLength:4];
    }
    else
    {
        NSString *addr = _connector.address;
        UInt16 port = _connector.port;
        if ([_connector isConnected]
            && [[address getHost] isEqualToString:addr]
            && [address getPort] == port)
        {
            return FALSE;
        }

        [_connector disconnect];
    }

    self.state = CCSpeakerStateHangUp;

    _address = address;

    CCSession *session = [_connector connect:address.host port:address.port];
    if (nil != session)
    {
        // 变更状态
        self.state = CCSpeakerStateCalling;
    }

    return (nil != session);
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

        _connector = nil;

        self.state = CCSpeakerStateHangUp;
    }
}
//------------------------------------------------------------------------------
- (void)suspend:(NSTimeInterval)duration
{
    if (self.state == CCSpeakerStateCalled)
    {
        // 包格式：内核标签|有效时长

        char tag[] = TPT_SUSPEND;
        CCPacket *packet = [[CCPacket alloc] initWithTag:tag sn:5 major:1 minor:0];

        NSString *nucleusTag = [[CCNucleus sharedSingleton].tag getAsString];
        [packet appendSubsegment:[nucleusTag dataUsingEncoding:NSUTF8StringEncoding]];

        NSString *szDuration = [NSString stringWithFormat:@"%.0f", duration * 1000];
        [packet appendSubsegment:[szDuration dataUsingEncoding:NSUTF8StringEncoding]];

        NSData *data = [CCPacket pack:packet];
        if (nil != data)
        {
            CCMessage *message = [CCMessage messageWithData:data];
            [_connector write:message];

            // 更新状态
            _state = CCSpeakerStateSuspended;
        }
    }
}
//------------------------------------------------------------------------------
- (void)resume:(NSTimeInterval)startTime
{
    if (_state == CCSpeakerStateSuspended
        || _state == CCSpeakerStateCalled)
    {
        // 包格式：内核标签|需要恢复的原语起始时间戳
        char tag[] = TPT_RESUME;
        CCPacket *packet = [[CCPacket alloc] initWithTag:tag sn:6 major:1 minor:0];

        NSString *nucleusTag = [[CCNucleus sharedSingleton].tag getAsString];
        [packet appendSubsegment:[nucleusTag dataUsingEncoding:NSUTF8StringEncoding]];

        NSString *szDuration = [NSString stringWithFormat:@"%.0f", startTime * 1000];
        [packet appendSubsegment:[szDuration dataUsingEncoding:NSUTF8StringEncoding]];

        NSData *data = [CCPacket pack:packet];
        if (nil != data)
        {
            CCMessage *message = [CCMessage messageWithData:data];
            [_connector write:message];

            // 恢复状态
            _state = CCSpeakerStateCalled;
        }
    }
}
//------------------------------------------------------------------------------
- (BOOL)speak:(CCPrimitive *)primitive
{
    if (nil == _connector
        || ![_connector isConnected]
        || _state != CCSpeakerStateCalled)
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
- (BOOL)isSuspended
{
    return self.state == CCSpeakerStateSuspended;
}
//------------------------------------------------------------------------------
- (void)heartbeat
{
    // 心跳包（无包体）
    char ptag[] = TPT_HEARTBEAT;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:9 major:1 minor:0];
    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [CCMessage messageWithData:data];
        [_connector write:message];
    }
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
    else if (tag[2] == TPT_RESUME_B3 && tag[3] == TPT_RESUME_B4)
    {
        [self processResume:packet session:session];
    }
    else if (tag[2] == TPT_SUSPEND_B3 && tag[3] == TPT_SUSPEND_B4)
    {
        [self processSuspend:packet session:session];
    }
    else if (tag[2] == TPT_CONSULT_B3 && tag[3] == TPT_CONSULT_B4)
    {
        [self processConsult:packet session:session];
    }
    else if (tag[2] == TPT_REQUEST_B3 && tag[3] == TPT_REQUEST_B4)
    {
        [self processRequest:packet session:session];
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

    // 解密
    char plaintext[32] = {0x0};
    int plen = [[CCCryptology sharedSingleton] simpleDecrypt:plaintext
                    text:ciphertext length:ctData.length key:key];

    // 回送数据进行服务器验证
    char tag[] = TPT_CHECK;
    CCPacket *response = [[CCPacket alloc] initWithTag:tag sn:2 major:1 minor:0];
    [response appendSubsegment:[NSData dataWithBytes:plaintext length:plen]];
    
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

    // 请求 Cellet
    [self requestCellet:session];
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
        [CCLogger d:@"Cellet %@ has called at %@:%d", _identifier,
            [[session getAddress] getHost], [[session getAddress] getPort]];

        // 变更状态
        self.state = CCSpeakerStateCalled;

        // 调用回调
        [self fireContacted];
    }
    else
    {
        // 变更状态
        self.state = CCSpeakerStateHangUp;

        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCTalkFailureNotFoundCellet
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceCelletIdentifier = _identifier;
        [self fireFailed:failure];

        // 关闭连接
        [_connector disconnect];
    }

    // 如果调用成功，则进行能力协商
    if (_state == CCSpeakerStateCalled && nil != _capacity)
    {
        [self consult:_capacity];
    }
}
//------------------------------------------------------------------------------
- (void)processDialogue:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：原语序列
    NSData *data = [packet getBody];
    CCPrimitive *primitive = [CCPrimitive read:data];
    if (nil != primitive)
    {
        // 设置对端标签
        primitive.ownerTag = [_remoteTag getAsString];
        primitive.celletIdentifier = [NSString stringWithString:_identifier];

        if (nil != [CCTalkService sharedSingleton].listener)
        {
            [[CCTalkService sharedSingleton].listener dialogue:primitive.celletIdentifier primitive:primitive];
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
        return;
    }

    // 进行对比
    if (nil != _capacity)
    {
        if (newCapacity.autoSuspend != _capacity.autoSuspend
            || newCapacity.suspendDuration != _capacity.suspendDuration)
        {
            [CCLogger w:@"Talk capacity has changed from '%@' : AutoSuspend=%d SuspendDuration=%f"
                , _identifier
                , newCapacity.autoSuspend
                , newCapacity.suspendDuration];
        }
    }

    // 更新
    _capacity.autoSuspend = newCapacity.autoSuspend;
    _capacity.suspendDuration = newCapacity.suspendDuration;
}
//------------------------------------------------------------------------------
- (void)processSuspend:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：请求方标签|成功码|时间戳
    NSData *code = [packet getSubsegment:1];
    char sc[4] = {0x0};
    [code getBytes:sc length:code.length];
    
    char success[] = CCTS_SUCCESS;
    if (sc[0] == success[0] && sc[1] == success[1]
        && sc[2] == success[2] && sc[3] == success[3])
    {
        // 更新状态
        _state = CCSpeakerStateSuspended;

        NSData *data = [packet getSubsegment:2];
        NSTimeInterval timestamp = [CCUtil convertDataToTimeInterval:data];

        [self fireSuspended:timestamp mode:CCSuspendModeInitative];
    }
    else
    {
        // 更新状态
        _state = CCSpeakerStateCalled;
    }
}
//------------------------------------------------------------------------------
- (void)processResume:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：目标标签|时间戳|原语序列
    NSTimeInterval timestamp = [CCUtil convertDataToTimeInterval:[packet getSubsegment:1]];

    NSData *data = [packet getSubsegment:2];
    CCPrimitive *primitive = [CCPrimitive read:data];
    if (nil != primitive)
    {
        // 设置对端标签
        primitive.ownerTag = [_remoteTag getAsString];
        primitive.celletIdentifier = [NSString stringWithString:_identifier];
        
        [self fireResumed:timestamp primitive:primitive];
    }
}
//------------------------------------------------------------------------------
- (void)requestCellet:(CCSession *)session
{
    // 包格式：Cellet标识串|标签
    char ptag[] = TPT_REQUEST;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:3 major:1 minor:0];
    
    [packet appendSubsegment:[self.identifier dataUsingEncoding:NSUTF8StringEncoding]];
    [packet appendSubsegment:[[[CCNucleus sharedSingleton] getTagAsString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [CCMessage messageWithData:data];
        [session write:message];
    }
}
//------------------------------------------------------------------------------
- (void)consult:(CCTalkCapacity *)capacity
{
    // 包格式：源标签|能力描述序列化数据
    char ptag[] = TPT_CONSULT;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:4 major:1 minor:0];
    [packet appendSubsegment:[[[CCNucleus sharedSingleton] getTagAsString] dataUsingEncoding:NSUTF8StringEncoding]];
    [packet appendSubsegment:[CCTalkCapacity serialize:capacity]];

    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [CCMessage messageWithData:data];
        [_connector write:message];
    }
}
//------------------------------------------------------------------------------
- (void)fireContacted
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener contacted:_identifier tag:[_remoteTag getAsString]];
    }
}
//------------------------------------------------------------------------------
- (void)fireQuitted
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener quitted:_identifier tag:[_remoteTag getAsString]];
    }
}
//------------------------------------------------------------------------------
- (void)fireSuspended:(NSTimeInterval)timestamp mode:(CCSuspendMode)mode
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener suspended:_identifier
                                                        tag:[_remoteTag getAsString]
                                                  timestamp:timestamp
                                                       mode:mode];
    }
}
//------------------------------------------------------------------------------
- (void)fireResumed:(NSTimeInterval)timestamp primitive:(CCPrimitive *)primitive
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener resumed:_identifier
                                                      tag:[_remoteTag getAsString]
                                                timestamp:timestamp
                                                primitive:primitive];
    }
}
//------------------------------------------------------------------------------
- (void)fireFailed:(CCTalkServiceFailure *)failure
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener failed:failure];
    }
}

#pragma mark - Message Handle Delegate

//------------------------------------------------------------------------------
- (void)sessionCreated:(CCSession *)session
{
}
//------------------------------------------------------------------------------
- (void)sessionDestroyed:(CCSession *)session
{
}
//------------------------------------------------------------------------------
- (void)sessionOpened:(CCSession *)session
{
}
//------------------------------------------------------------------------------
- (void)sessionClosed:(CCSession *)session
{
    if (nil != self.capacity && _state == CCSpeakerStateCalled)
    {
        if (self.capacity.autoSuspend)
        {
            // 更新状态
            _state = CCSpeakerStateSuspended;
            [self fireSuspended:[CCUtil currentTimeInterval] mode:CCSuspendModePassive];

            // 自动重连
            [[CCTalkService sharedSingleton] markLostSpeaker:self];
        }
    }

    _state = CCSpeakerStateHangUp;

    // 通知退出
    [self fireQuitted];
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

    if (errorCode == CCMessageErrorConnectTimeout
        || errorCode == CCMessageErrorConnectFailed)
    {
        CCTalkServiceFailure *failure = [[CCTalkServiceFailure alloc]
                                         initWithSource:CCTalkFailureCallTimeout
                                         file:__FILE__
                                         line:__LINE__
                                         function:__FUNCTION__];
        failure.sourceDescription = @"Attempt to connect to host timed out";
        [self fireFailed:failure];

        [[CCTalkService sharedSingleton] markLostSpeaker:self];
    }
}

@end
