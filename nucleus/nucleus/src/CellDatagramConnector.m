/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2017 Cell Cloud Team - www.cellcloud.net
 
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

#import "CellDatagramConnector.h"
#import "CellInetAddress.h"
#import "CellSession.h"
#import "CellMessage.h"
#import "CellLogger.h"
#import "CellCryptology.h"
#import "CellUtil.h"

// 私有接口
@interface CCDatagramConnector ()
{
@private
    GCDAsyncUdpSocket *_udpSocket;

    CCSession *_session;
    
    NSMutableDictionary *_writeQueue;
}

/** 创建连接会话。 */
- (void)fireSessionCreated;
/** 销毁连接会话。 */
- (void)fireSessionDestroyed;
/** 开启连接会话。 */
- (void)fireSessionOpened;
/** 关闭连接会话。 */
- (void)fireSessionClosed;
/** 接收到消息。 */
- (void)fireMessageReceived:(CCMessage *)message;
/** 消息已发送。 */
- (void)fireMessageSent:(CCMessage *)message;
/** 发生错误。 */
- (void)fireErrorOccurred:(CCMessageErrorCode)errorCode;

/** 加密消息。 */
- (void)encryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length;
/** 解密消息。 */
- (void)decryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length;

@end


@implementation CCDatagramConnector

#pragma mark Message Connector Implements

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _udpSocket = nil;
        _session = nil;
        _writeQueue = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (id)init:(id<CCMessageHandler>)delegate
{
    if ((self = [super init]))
    {
        _udpSocket = nil;
        _session = nil;
        _writeQueue = [NSMutableDictionary dictionaryWithCapacity:4];

        [self setDelegate:delegate];
    }
    return self;
}
//------------------------------------------------------------------------------
- (CCSession *)connect:(NSString *)address port:(NSUInteger)port
{
    if (nil != _udpSocket)
    {
        return nil;
    }

    // 设置地址和端口
    [super connect:address port:port];

    // 创建 Socket
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];

    // 启用 IPv6/IPv4
    _udpSocket.IPv4Enabled = YES;
    _udpSocket.IPv6Enabled = YES;

    NSError *error = nil;
    if (![_udpSocket bindToPort:port error:&error])
    {
        // 绑定端口失败
        [self fireErrorOccurred:CCMessageErrorSocketFailed];

        return nil;
    }

    if (nil != _session)
    {
        _session = nil;
    }

    CCInetAddress *inetAddr = [[CCInetAddress alloc] initWithAddress:address port:port];
    _session = [[CCSession alloc] initWithService:self address:inetAddr];

    [self fireSessionCreated];

    [_udpSocket beginReceiving:&error];

    [self fireSessionOpened];

    return _session;
}
//------------------------------------------------------------------------------
- (void)disconnect
{
    [_writeQueue removeAllObjects];

    if (nil != _udpSocket)
    {
        [_udpSocket close];
        _udpSocket = nil;
    }

    if (nil != _session)
    {
        _session = nil;
    }
}
//------------------------------------------------------------------------------
- (CCSession *)getSession
{
    return _session;
}
//------------------------------------------------------------------------------
- (BOOL)isConnected
{
    return (nil != _udpSocket && ![_udpSocket isClosed]);
}
//------------------------------------------------------------------------------
- (void)write:(CCSession *)session message:(CCMessage *)message
{
    if (nil == _udpSocket)
    {
        return;
    }

    // 关联 Tag
    [_writeQueue setObject:message forKey:[message.sn stringValue]];

    // 发送数据
    [_udpSocket sendData:message.data toHost:self.address port:self.port withTimeout:-1 tag:[message.sn longValue]];
}
//------------------------------------------------------------------------------
- (void)write:(CCMessage *)message
{
    [self write:_session message:message];
}



#pragma mark Callback Method

//------------------------------------------------------------------------------
- (void)fireSessionCreated
{
    if (nil != self.delegate)
    {
        [self.delegate sessionCreated:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireSessionDestroyed
{
    if (nil != self.delegate)
    {
        [self.delegate sessionDestroyed:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireSessionOpened
{
    if (nil != self.delegate)
    {
        [self.delegate sessionOpened:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireSessionClosed
{
    if (nil != self.delegate)
    {
        [self.delegate sessionClosed:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireMessageReceived:(CCMessage *)message
{
    if (nil != self.delegate)
    {
        [self.delegate messageReceived:_session message:message];
    }
}
//------------------------------------------------------------------------------
- (void)fireMessageSent:(CCMessage *)message
{
    if (nil != self.delegate)
    {
        [self.delegate messageSent:_session message:message];
    }
}
//------------------------------------------------------------------------------
- (void)fireErrorOccurred:(CCMessageErrorCode)errorCode
{
    if (nil != self.delegate)
    {
        [self.delegate errorOccurred:errorCode session:_session];
    }
}
//------------------------------------------------------------------------------
- (void)encryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length
{
    // TODO
}
//------------------------------------------------------------------------------
- (void)decryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length
{
    // TODO
}


#pragma mark Socket Delegate

//------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    // Nothing
}
//------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error
{
    // Nothing
}
//------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSString *key = [[NSNumber numberWithLong:tag] stringValue];
    CCMessage *message = [_writeQueue objectForKey:key];
    if (nil != message)
    {
        // 回调消息发送
        [self fireMessageSent:message];

        // 删除
        [_writeQueue removeObjectForKey:key];
    }

    key = nil;
}
//------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error
{
    [self fireErrorOccurred:CCMessageErrorWriteFailed];

    NSString *key = [[NSNumber numberWithLong:tag] stringValue];
    [_writeQueue removeObjectForKey:key];
    key = nil;
}
//------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext
{
    // 回调消息接收
    CCMessage *message = [[CCMessage alloc] initWithData:data];
    [self fireMessageReceived:message];
}
//------------------------------------------------------------------------------
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error
{
    [self fireSessionClosed];

    if (nil != _session)
    {
        _session = nil;
    }

    [self fireSessionDestroyed];
}

@end
