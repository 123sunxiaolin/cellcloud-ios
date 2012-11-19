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
#import "CellTalkService.h"
#import "CellPrimitive.h"
#include "CellTalkPacketDefinition.h"


// Private

@interface CCSpeaker (Private)

/// 数据处理入口
- (void)interpret:(CCSession *)session packet:(CCPacket *)packet;

/// 请求进行密文校验
- (void)requestCheck:(CCPacket *)packet session:(CCSession *)session;

/// 处理进行完校验后操作
- (void)processCheck:(CCPacket *)packet session:(CCSession *)session;

/// 请求 Cellet
- (void)requestCellet:(CCSession *)session;

/// 处理请求返回
- (void)processRequest:(CCPacket *)packet session:(CCSession *)session;

/// 会话
- (void)processDialogue:(CCPacket *)packet session:(CCSession *)session;

///
- (void)fireContacted;
///
- (void)fireQuitted;
///
- (void)fireFailed;

@end


// Implementation

@implementation CCSpeaker

@synthesize identifier = _identifier;
@synthesize remoteTag = _remoteTag;

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
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
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
}

#pragma mark Public Method

//------------------------------------------------------------------------------
- (BOOL)call:(CCInetAddress *)address
{
    if (nil != _connector && [_connector isConnected])
    {
        return FALSE;
    }
    
    self.called = FALSE;

    char head[4] = {0x20, 0x10, 0x11, 0x10};
    char tail[4] = {0x19, 0x78, 0x10, 0x04};
    _connector = [[CCNonblockingConnector alloc] initWithDataMark:self
            headMark:head headLength:4 tailMark:tail tailLength:4];

    CCSession *session = [_connector connect:address.host port:address.port];

    return (nil != session);
}
//------------------------------------------------------------------------------
- (void)hangup
{
    // TODO
}
//------------------------------------------------------------------------------
- (BOOL)isCalled
{
    return self.called;
}
//------------------------------------------------------------------------------
- (void)speak:(CCPrimitive *)primitive
{
    if (nil == _connector || ![_connector isConnected])
    {
        return;
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
            CCMessage *message = [[CCMessage alloc] initWithData:data];
            [[_connector getSession] write:message];
        }
    }
}

#pragma mark Private Method

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
    else if (tag[2] == TPT_CHECK_B3 && tag[3] == TPT_CHECK_B4)
    {
        [self processCheck:packet session:session];
    }
    else if (tag[2] == TPT_INTERROGATE_B3 && tag[3] == TPT_INTERROGATE_B4)
    {
        [self requestCheck:packet session:session];
    }
}
//------------------------------------------------------------------------------
- (void)requestCheck:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：密文|密钥
    char ciphertext[32] = {0x0};
    NSData *ctData = [packet getSubsegment:0];
    [ctData getBytes:ciphertext];
    char key[16] = {0x0};
    NSData *kData = [packet getSubsegment:1];
    [kData getBytes:key];

    // 解密
    char plaintext[32] = {0x0};
    int plen = [[CCCryptology sharedSingleton] simpleDecrypt:plaintext
                    text:ciphertext length:ctData.length key:key];

    // 回送数据进行服务器验证
    char tag[] = TPT_CHECK;
    CCPacket *response = [[CCPacket alloc] initWithTag:tag sn:1 major:1 minor:0];
    [response appendSubsegment:[NSData dataWithBytes:plaintext length:plen]];
    
    NSData *data = [CCPacket pack:response];
    if (nil != data)
    {
        CCMessage *message = [[CCMessage alloc] initWithData:data];
        [session write:message];
    }
}
//------------------------------------------------------------------------------
- (void)processCheck:(CCPacket *)packet session:(CCSession *)session
{
    // 包格式：成功码|内核标签
    NSData *tagdata = [packet getSubsegment:1];
    char tag[64] = {0x0};
    [tagdata getBytes:tag];

    // 设置对端标签
    _remoteTag = [[CCNucleusTag alloc] initWithString:[[NSString alloc] initWithFormat:@"%s", tag]];

    // 请求 Cellet
    [self requestCellet:session];
}
//------------------------------------------------------------------------------
- (void)requestCellet:(CCSession *)session
{
    // 包格式：Cellet标识串|标签
    char ptag[] = TPT_REQUEST;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:2 major:1 minor:0];

    [packet appendSubsegment:[self.identifier dataUsingEncoding:NSUTF8StringEncoding]];
    [packet appendSubsegment:[[[CCNucleus sharedSingleton] getTagAsString] dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [[CCMessage alloc] initWithData:data];
        [session write:message];
    }
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
    [data getBytes:sc];
    
    char success[] = CCTS_SUCCESS;
    if (sc[0] == success[0] && sc[1] == success[1]
        && sc[2] == success[2] && sc[3] == success[3])
    {
        [CCLogger d:@"Cellet %@ has called at %@:%d", _identifier,
            [[session getAddress] getHost], [[session getAddress] getPort]];

        // 变更状态
        self.called = TRUE;

        // 调用回调
        [self fireContacted];
    }
    else
    {
        [self fireFailed];
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

        if (nil != [CCTalkService sharedSingleton].listener)
        {
            [[CCTalkService sharedSingleton].listener dialogue:primitive.ownerTag primitive:primitive];
        }
    }
}
//------------------------------------------------------------------------------
- (void)heartbeat
{
    // 心跳包（无包体）
    char ptag[] = TPT_HEARTBEAT;
    CCPacket *packet = [[CCPacket alloc] initWithTag:ptag sn:99 major:1 minor:0];
    NSData *data = [CCPacket pack:packet];
    if (nil != data)
    {
        CCMessage *message = [[CCMessage alloc] initWithData:data];
        [[_connector getSession] write:message];
    }
}
//------------------------------------------------------------------------------
- (void)fireContacted
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener contacted:[_remoteTag getAsString]];
    }
}
//------------------------------------------------------------------------------
- (void)fireQuitted
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener quitted:[_remoteTag getAsString]];
    }
}
//------------------------------------------------------------------------------
- (void)fireFailed
{
    if (nil != [CCTalkService sharedSingleton].listener)
    {
        [[CCTalkService sharedSingleton].listener failed:_identifier];
    }
}

#pragma mark Message Handle Delegate

//------------------------------------------------------------------------------
- (void)sessionCreated:(CCSession *)session
{
//    [CCLogger d:@"sessionCreated - %p", session];
}
//------------------------------------------------------------------------------
- (void)sessionDestroyed:(CCSession *)session
{
//    [CCLogger d:@"sessionDestroyed - %p", session];
}
//------------------------------------------------------------------------------
- (void)sessionOpened:(CCSession *)session
{
//    [CCLogger d:@"sessionOpened - %p", session];
}
//------------------------------------------------------------------------------
- (void)sessionClosed:(CCSession *)session
{
//    [CCLogger d:@"sessionClosed - %p", session];
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
//    [CCLogger d:@"messageSent - %p", session];
}
//------------------------------------------------------------------------------
- (void)errorOccurred:(CCMessageErrorCode)errorCode session:(CCSession *)session
{
    [CCLogger d:@"errorOccurred - %d - %p", errorCode, session];
}

@end
