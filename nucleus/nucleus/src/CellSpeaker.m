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
#include "CellTalkPacketDefinition.h"


// Private

@interface CCSpeaker (Private)

/// 
- (void)interpret:(CCSession *)session packet:(CCPacket *)packet;

/// 请求进行密文校验
- (void)requestCheck:(CCPacket *)packet session:(CCSession *)session;

@end


// Implementation

@implementation CCSpeaker

@synthesize identifier = _identifier;

//------------------------------------------------------------------------------
- (id)initWithIdentifier:(NSString *)identifier
{
    if ((self = [super init]))
    {
        _identifier = identifier;
        _connector = nil;
    }
    
    return self;
}

#pragma mark Public Method

//------------------------------------------------------------------------------
- (BOOL)call:(CCInetAddress *)address
{
    if (nil != _connector && [_connector isConnected])
    {
        return FALSE;
    }

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
    
}
//------------------------------------------------------------------------------
- (BOOL)isCalled
{
    return FALSE;
}

#pragma mark Private Method

//------------------------------------------------------------------------------
- (void)interpret:(CCSession *)session packet:(CCPacket *)packet
{
    char tag[PSL_TAG + 1] = {0x0};
    [packet getTag:tag];

    if (tag[2] == TPT_CHECK_B3 && tag[3] == TPT_CHECK_B4)
    {
        NSLog(@"check is ok");
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
//    NSString *str = [[NSString alloc] initWithData:message.data
//                    encoding:NSUTF8StringEncoding];
//    [CCLogger d:@"messageReceived - %p : %@", session, str];

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
- (void)errorOccurred:(int)errorCode session:(CCSession *)session
{
    [CCLogger d:@"errorOccurred - %p", session];
}

@end
