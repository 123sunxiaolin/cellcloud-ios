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

#import "CellMessageService.h"

/**
 @brief 消息连接器。

 @author Ambrose Xu
 */
@interface CCMessageConnector : CCMessageService

/** 连接地址。 */
@property (nonatomic, strong, readonly) NSString *address;
/** 连接端口。 */
@property (nonatomic, assign, readonly) NSUInteger port;

/**
 @brief 连接指定地址的消息接收器。

 @param address 指定连接地址。
 @param port 指定连接端口。
 @return 如果连接成功返回连接的会话，否则返回 @cnil 值。
 */
- (CCSession *)connect:(NSString *)address port:(NSUInteger)port;

/**
 @brief 关闭已建立的连接。
 */
- (void)disconnect;

/**
 @brief 设置连接超时。

 @param timeout 指定以毫秒为单位的超时时长。
 */
- (void)setConnectTimeout:(NSTimeInterval)timeout;

/**
 @brief 获得对应的会话实例。

 @return 返回对应的会话实例。
 */
- (CCSession *)getSession;

/**
 @brief 是否已经连接。
 
 @return 如果已经连接返回 @ctrue 。
 */
- (BOOL)isConnected;

/**
 @brief 将指定的消息写入连接通道，发送给已连接的接收器。
 
 @param message 指定待发送的消息。
 */
- (void)write:(CCMessage *)message;

@end
