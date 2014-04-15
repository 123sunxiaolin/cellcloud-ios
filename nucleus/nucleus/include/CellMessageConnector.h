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

#import "CellMessageService.h"

/** 消息连接器。
 */
@interface CCMessageConnector : CCMessageService

/// 连接地址。
@property (nonatomic, strong, readonly) NSString *address;
/// 连接端口。
@property (nonatomic, assign, readonly) NSUInteger port;

/** 连接对端消息接收器。 */
- (CCSession *)connect:(NSString *)address port:(NSUInteger)port;

/** 关闭已建立的连接。 */
- (void)disconnect;

/** 设置连接超时。 */
- (void)setConnectTimeout:(NSTimeInterval)timeout;

/** 返回对应的会话实例。 */
- (CCSession *)getSession;

/** 是否已经连接。 */
- (BOOL)isConnected;

/** 写数据。
 */
- (void)write:(CCMessage *)message;

@end
