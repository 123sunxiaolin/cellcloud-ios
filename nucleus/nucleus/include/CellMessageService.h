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

#include "CellPrerequisites.h"

/// 未知的错误类型。
#define CCEC_UNKNOWN 0
/// 无效的网络地址。
#define CCEC_ADDRESS_INVALID 1
/// 错误的状态。
#define CCEC_STATE_ERROR 2
/// Socket 函数发生错误。
#define CCEC_SOCK_FAILED 3
/// 绑定服务时发生错误。
#define CCEC_BIND_FAILED 4
/// 监听连接时发生错误。
#define CCEC_LISTEN_FAILED 5
/// Accept 发生错误。
#define CCEC_ACCEPT_FAILED 6
/// 写入数据时发生错误。
#define CCEC_WRITE_FAILED 7
/// 连接超时
#define CCEC_CONNECT_TIMEOUT 9


/** 消息服务处理监听器。
 */
@protocol CCMessageHandler <NSObject>
@optional

/** 创建连接会话。 */
- (void)sessionCreated:(CCSession *)session;
/** 销毁连接会话。 */
- (void)sessionDestroyed:(CCSession *)session;
/** 开启连接会话。 */
- (void)sessionOpened:(CCSession *)session;
/** 关闭连接会话。 */
- (void)sessionClosed:(CCSession *)session;
/** 接收到消息。 */
- (void)messageReceived:(CCSession *)session message:(CCMessage *)message;
/** 消息已发送。 */
- (void)messageSent:(CCSession *)session message:(CCMessage *)message;
/** 发生错误。 */
- (void)errorOccurred:(int)errorCode session:(CCSession *)session;

@end


/** 消息服务。
 */
@interface CCMessageService : NSObject
{
@protected
    id<CCMessageHandler> _delegate;

@protected
    char *_headMark;
    size_t _headLength;
    char *_tailMark;
    size_t _tailLength;
}

@property (strong, nonatomic) id<CCMessageHandler> delegate;

/** 指定消息操作委派初始化。
 */
- (id)initWithDelegate:(id<CCMessageHandler>)delegate;

/** 设置消息操作委派。
 */
- (void)setDelegate:(id<CCMessageHandler>)delegate;

/** 定义数据包标志。
 */
- (void)defineDataMark:(char *)headMark headLength:(size_t)headLength
            tailMark:(char *)tailMark tailLength:(size_t)tailLength;

/** 是否定义了数据标示。
 */
- (BOOL)existDataMark;

/** 向指定的会话写入消息。
 */
- (void)write:(CCSession *)session message:(CCMessage *)message;

/** 从指定的会话读取消息。
 */
- (void)read:(CCMessage *)message session:(CCSession *)session;

@end
