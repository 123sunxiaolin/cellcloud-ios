/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2014 Cell Cloud Team - www.cellcloud.net
 
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

#import "CellNonblockingConnector.h"
#import "CellInetAddress.h"
#import "CellSession.h"
#import "CellMessage.h"
#import "CellLogger.h"
#import "CellCryptology.h"

// 私有接口
@interface CCNonblockingConnector ()
{
@private
    GCDAsyncSocket *_asyncSocket;
    
    CCSession *_session;
    
    NSTimeInterval _timeout;

    NSMutableDictionary *_writeQueue;

    NSUInteger _blockSize;
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

/** 处理接收数据。 */
- (void)processReceived:(NSData *)data;

- (void)encryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length;

- (void)decryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length;

@end


@implementation CCNonblockingConnector

#pragma mark Message Connector Implements

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _timeout = 10.0;
        _blockSize = 16 * 1024;
        _writeQueue = [NSMutableDictionary dictionaryWithCapacity:4];
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)init:(id<CCMessageHandler>)delegate
            headMark:(char *)headMark headLength:(size_t)headLength
            tailMark:(char *)tailMark tailLength:(size_t)tailLength
{
    if ((self = [super init]))
    {
        [self setDelegate:delegate];
        [self defineDataMark:headMark headLength:headLength
                tailMark:tailMark tailLength:tailLength];
        
        _timeout = 10.0;
        _blockSize = 16 * 1024;
        _writeQueue = [NSMutableDictionary dictionaryWithCapacity:4];
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)setConnectTimeout:(NSTimeInterval)timeout
{
    _timeout = timeout;
}
//------------------------------------------------------------------------------
- (CCSession *)connect:(NSString *)address port:(NSUInteger)port
{
    if (nil != _session)
    {
        return nil;
    }

    // 设置地址和端口
    [super connect:address port:port];

    // 创建 Socket
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];

    // 启用 IPv6/IPv4
    _asyncSocket.IPv4Enabled = YES;
    _asyncSocket.IPv6Enabled = YES;
    _asyncSocket.IPv4PreferredOverIPv6 = NO;

    // 注册为 VoIP Socket
    [_asyncSocket enableBackgroundingOnSocket];

    [CCLogger d:@"Connecting to %@:%hu", address, port];

    NSError *error = nil;
    if (![_asyncSocket connectToHost:address onPort:port withTimeout:_timeout error:&error])
    {
        [CCLogger e:@"Error connecting: %@", error];

        if (_asyncSocket)
        {
            _asyncSocket = nil;
        }

        [self fireErrorOccurred:CCMessageErrorSocketFailed];
    }
    else
    {
        CCInetAddress *inetAddr = [[CCInetAddress alloc] initWithAddress:address port:port];
        _session = [[CCSession alloc] initWithService:self address:inetAddr];

        [self fireSessionCreated];
    }

    return _session;
}
//------------------------------------------------------------------------------
- (void)disconnect
{
    if (nil != _asyncSocket)
    {
        [_asyncSocket disconnect];
        _asyncSocket = nil;
    }

    if (nil != _session)
    {
        _session = nil;
    }

    [_writeQueue removeAllObjects];
}
//------------------------------------------------------------------------------
- (CCSession *)getSession
{
    return _session;
}
//------------------------------------------------------------------------------
- (BOOL)isConnected
{
    return (nil != _session && nil != _asyncSocket && [_asyncSocket isConnected]);
}
//------------------------------------------------------------------------------
- (void)write:(CCSession *)session message:(CCMessage *)message
{
    if (nil == _asyncSocket)
    {
        return;
    }

    if ([session isSecure])
    {
        [self encryptMessage:message key:[session getSecretKey] keyLength:8];
    }

    // 关联 Tag
    [_writeQueue setObject:message forKey:[message.tag stringValue]];

    if ([self existDataMark])
    {
        char *buf = malloc(message.length + _headLength + _tailLength);
        memset(buf, 0x0, message.length + _headLength + _tailLength);
        memcpy(buf, _headMark, _headLength);
        memcpy(buf + _headLength, message.data.bytes, message.length);
        memcpy(buf + _headLength + message.length, _tailMark, _tailLength);
        NSData *data = [NSData dataWithBytes:buf length:_headLength + _tailLength + message.length];
        free(buf);
        [_asyncSocket writeData:data withTimeout:60 tag:[message.tag longValue]];
    }
    else
    {
        [_asyncSocket writeData:message.data withTimeout:60 tag:[message.tag longValue]];
    }

    // 回调消息发送
    //[self fireMessageSent:message];
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
    if (nil != _delegate)
    {
        [_delegate sessionCreated:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireSessionDestroyed
{
    if (nil != _delegate)
    {
        [_delegate sessionDestroyed:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireSessionOpened
{
    if (nil != _delegate)
    {
        [_delegate sessionOpened:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireSessionClosed
{
    if (nil != _delegate)
    {
        [_delegate sessionClosed:_session];
    }
}
//------------------------------------------------------------------------------
- (void)fireMessageReceived:(CCMessage *)message
{
    if (nil != _delegate)
    {
        [_delegate messageReceived:_session message:message];
    }
}
//------------------------------------------------------------------------------
- (void)fireMessageSent:(CCMessage *)message
{
    if (nil != _delegate)
    {
        [_delegate messageSent:_session message:message];
    }
}
//------------------------------------------------------------------------------
- (void)fireErrorOccurred:(CCMessageErrorCode)errorCode
{
    if (nil != _delegate)
    {
        [_delegate errorOccurred:errorCode session:_session];
    }
}

#pragma mark Private Methods

//------------------------------------------------------------------------------
- (void)processReceived:(NSData *)data
{
    if ([self existDataMark])
    {
        // 计算数据范围
        NSRange range = NSMakeRange(_headLength,
                data.length - _headLength - _tailLength);
        NSData *cur = [data subdataWithRange:range];
        CCMessage *message = [[CCMessage alloc] initWithData:cur];

        // 如果是安全连接，解密
        if ([_session isSecure])
        {
            [self decryptMessage:message key:[_session getSecretKey] keyLength:8];
        }

        [self fireMessageReceived:message];
    }
    else
    {
        CCMessage *message = [[CCMessage alloc] initWithData:data];

        // 如果是安全连接，解密
        if ([_session isSecure])
        {
            [self decryptMessage:message key:[_session getSecretKey] keyLength:8];
        }

        [self fireMessageReceived:message];
    }
}
//------------------------------------------------------------------------------
- (void)encryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length
{
    const char *plaintext = [message.data bytes];
    NSUInteger len = message.length;

    char *ciphertext = malloc(len);
    memset(ciphertext, 0x0, len);

    NSUInteger newlen = [[CCCryptology sharedSingleton] simpleEncrypt:ciphertext text:plaintext length:(int)len key:key];

    // 重新填写消息数据
    [message resetData:ciphertext length:newlen];

    free(ciphertext);
}
//------------------------------------------------------------------------------
- (void)decryptMessage:(CCMessage *)message key:(const char *)key keyLength:(int)length
{
    const char *ciphertext = [message.data bytes];
    NSUInteger len = message.length;

    char *plaintext = malloc(len);
    memset(plaintext, 0x0, len);

    NSUInteger newlen = [[CCCryptology sharedSingleton] simpleDecrypt:plaintext text:ciphertext length:(int)len key:key];

    // 重新填写消息数据
    [message resetData:plaintext length:newlen];

    free(plaintext);
}


#pragma mark Socket Delegate

//------------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [CCLogger d:@"didConnectToHost"];

    [sock performBlock:^{
        if ([sock enableBackgroundingOnSocket])
            [CCLogger d:@"Enabled backgrounding on socket."];
        else
            [CCLogger d:@"Enabling backgrounding failed!"];
    }];

    // 回调会话开启
    [self fireSessionOpened];

    if ([self existDataMark])
    {
        NSData* data = [NSData dataWithBytes:_tailMark length:_tailLength];
        [_asyncSocket readDataToData:data withTimeout:-1.0 tag:0];
    }
    else
    {
        [_asyncSocket readDataToLength:_blockSize withTimeout:-1.0 tag:0];
    }
}
//------------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    [CCLogger d:@"didWriteDataWithTag - tag:%ld", tag];

    NSString *key = [[NSNumber numberWithLong:tag] stringValue];
    CCMessage *message = [_writeQueue objectForKey:key];
    if (nil != message)
    {
        // 回调已发送
        [self fireMessageSent:message];

        // 删除
        [_writeQueue removeObjectForKey:key];
    }

    key = nil;
}
//------------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    [CCLogger d:@"didReadData"];

    [self processReceived:data];

    if ([self existDataMark])
    {
        NSData* data = [NSData dataWithBytes:_tailMark length:_tailLength];
        [_asyncSocket readDataToData:data withTimeout:-1.0 tag:0];
    }
    else
    {
        [_asyncSocket readDataToLength:_blockSize withTimeout:-1.0 tag:0];
    }
}
//------------------------------------------------------------------------------
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    long errCode = [err code];
    [CCLogger d:@"socketDidDisconnect - %ld : %@", errCode, err];

    switch (errCode)
    {
    case 0:
        // Socket end
        [self fireErrorOccurred:CCMessageErrorConnectEnd];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    case 3:
        // Attempt to connect to host timed out
        [self fireErrorOccurred:CCMessageErrorConnectTimeout];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    case 7:
        // Socket closed by remote peer
        [self fireSessionClosed];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;
    case 51:
        // Network is unreachable
        [self fireErrorOccurred:CCMessageErrorConnectFailed];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    case 57:
        // Socket is not connected
        [self fireErrorOccurred:CCMessageErrorConnectFailed];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    case 60:
        // Operation timeout
        [self fireErrorOccurred:CCMessageErrorStateError];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    case 61:
        // Connection refused
        [self fireErrorOccurred:CCMessageErrorConnectFailed];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    case 64:
        // Host is down
        [self fireErrorOccurred:CCMessageErrorConnectFailed];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;

    default:
        [self fireErrorOccurred:CCMessageErrorUnknown];
        [self fireSessionDestroyed];
        _session = nil;
        _asyncSocket = nil;
        break;
    }
}
//------------------------------------------------------------------------------
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return 0;
}
//------------------------------------------------------------------------------
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return 0;
}

@end
