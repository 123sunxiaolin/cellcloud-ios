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

#include "CellPrerequisites.h"

/*!
 @brief 消息错误码定义。
 
 @author Ambrose Xu
 */
typedef enum _CCMessageErrorCode
{
    /*! 未知的错误类型。 */
    CCMessageErrorUnknown = 100,
    /*! 无效的网络地址。 */
    CCMessageErrorAddressInvalid = 101,
    /*! 错误的状态。 */
    CCMessageErrorStateError = 102,
    
    /*! Socket 函数发生错误。 */
    CCMessageErrorSocketFailed = 200,
    /*! 绑定服务时发生错误。 */
    CCMessageErrorBindFailed = 201,
    /*! 监听连接时发生错误。 */
    CCMessageErrorListenFailed = 202,
    /*! Accept 发生错误。 */
    CCMessageErrorAcceptFailed = 203,

    /*! 连接失败。 */
    CCMessageErrorConnectFailed = 300,
    /*! 连接超时。 */
    CCMessageErrorConnectTimeout = 301,
    /*! 连接正常结束 */
    CCMessageErrorConnectEnd = 305,

    /*! 写数据超时。 */
    CCMessageErrorWriteTimeout = 401,
    /*! 读数据超时。 */
    CCMessageErrorReadTiemout = 402,
    /*! 写入数据时发生错误。 */
    CCMessageErrorWriteFailed = 403,
    /*! 读取数据时发生错误。 */
    CCMessageErrorReadFailed = 404

} CCMessageErrorCode;


/*!
 @brief 消息服务处理监听器。
 */
@protocol CCMessageHandler <NSObject>
@optional

/*!
 @brief 创建连接会话。
 
 @param session 发生此事件的会话。
 */
- (void)sessionCreated:(CCSession *)session;

/*!
 @brief 销毁连接会话。
 
 @param session 发生此事件的会话。
 */
- (void)sessionDestroyed:(CCSession *)session;

/*!
 @brief 开启连接会话。
 
 @param session 发生此事件的会话。
 */
- (void)sessionOpened:(CCSession *)session;

/*!
 @brief 关闭连接会话。
 
 @param session 发生此事件的会话。
 */
- (void)sessionClosed:(CCSession *)session;

/*!
 @brief 接收到消息。
 
 @param session 发生此事件的会话。
 @param message 接收到的消息。
 */
- (void)messageReceived:(CCSession *)session message:(CCMessage *)message;

/*!
 @brief 消息已发送。
 
 @param session 发生此事件的会话。
 @param message 已发送的消息。
 */
- (void)messageSent:(CCSession *)session message:(CCMessage *)message;

/*!
 @brief 发生错误。
 
 @param errorCode 发生错误的错误码。
 @param session 发生此事件的会话。
 @see CCMessageErrorCode
 */
- (void)errorOccurred:(CCMessageErrorCode)errorCode session:(CCSession *)session;

@end


/*!
 @brief 消息服务。
 
 @author Ambrose Xu
 */
@interface CCMessageService : NSObject
{
@protected
    /// 报文头记号。
    char *_headMark;
    /// 报文头长度。
    size_t _headLength;
    /// 报文尾记号。
    char *_tailMark;
    /// 报文尾长度。
    size_t _tailLength;
}

/*! 消息事件委派。 */
@property (strong, nonatomic) id<CCMessageHandler> delegate;

/*!
 @brief 指定消息操作委派初始化。
 
 @param delegate 指定委派。
 */
- (id)initWithDelegate:(id<CCMessageHandler>)delegate;

/*!
 @brief 设置消息操作委派。
 
 @param delegate 指定委派。
 */
- (void)setDelegate:(id<CCMessageHandler>)delegate;

/*!
 @brief 定义数据报文记号。
 
 @param headMark 数据报文头。
 @param headLength 数据报文头的长度。
 @param tailMark 数据报文尾。
 @param tailLength 数据报文尾的长度。
 */
- (void)defineDataMark:(char *)headMark headLength:(size_t)headLength
            tailMark:(char *)tailMark tailLength:(size_t)tailLength;

/*!
 @brief 是否定义了数据标示。
 
 @return 如果消息服务指定了数据记号返回 <code>YES</code> 。
 */
- (BOOL)existDataMark;

/*!
 @brief 向指定的会话写入消息。
 
 @param session 指定待写入的会话。
 @param message 指定需要发送给指定会话的消息。
 */
- (void)write:(CCSession *)session message:(CCMessage *)message;

@end
