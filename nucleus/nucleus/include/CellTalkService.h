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
#include "CellTalkDefinition.h"

/*!
 @brief 会话监听器。

 @author Ambrose Xu
 */
@protocol CCTalkListener <NSObject>
@optional
/*!
 @brief 当收到来自服务器的数据时该函数被调用。
 
 @param identifier 该数据来源的 Cellet 的标识。
 @param primitive 接收到的原语数据。
 */
- (void)dialogue:(NSString *)identifier primitive:(CCPrimitive *)primitive;

/*!
 @brief 当终端成功与指定的 Cellet 建立连接时该函数被调用。

 @param identifier 建立连接的 Cellet 的标识。
 @param tag Cellet 的内核标签。
 */
- (void)contacted:(NSString *)identifier tag:(NSString *)tag;

/*!
 @brief 当终端与 Cellet 的连接断开时该函数被调用。

 @param identifier 断开连接的 Cellet 的标识。
 @param tag Cellet 的内核标签。
 */
- (void)quitted:(NSString *)identifier tag:(NSString *)tag;

/*!
 @brief 当发生连接错误时该函数被调用。

 @param failure 错误描述。
 */
- (void)failed:(CCTalkServiceFailure *)failure;

@end

/*!
 @brief 会话代理。

 @author Ambrose Xu
 */
@protocol CCTalkDelegate <NSObject>

/*!
 @brief 当准备执行数据发送时调用此函数。

 @param identifier 发送目标标识。
 @param dialect 发送的方言。
 @return 如果返回 <code>NO</code> 则劫持事件，阻止事件回调发生。
 */
- (BOOL)doTalk:(NSString *)identifier withDialect:(CCDialect *)dialect;

/*!
 @brief 当完成数据发送时调用此函数。

 @param identifier 发送目标标识。
 @param dialect 发送的方言。
 */
- (void)didTalk:(NSString *)identifier withDialect:(CCDialect *)dialect;

/*!
 @brief 当准备执行对话数据送达时调用此函数。

 @param identifier 目标标识。
 @param dialect 方言数据。
 @return 如果返回 <code>NO</code> 则劫持事件，阻止事件回调发生。
 */
- (BOOL)doDialogue:(NSString *)identifier withDialect:(CCDialect *)dialect;

/*!
 @brief 当完成对话数据送达时调用此函数。

 @param identifier 目标标识。
 @param dialect 方言数据。
 */
- (void)didDialogue:(NSString *)identifier withDialect:(CCDialect *)dialect;

@end


/*!
 @brief 会话服务。

 @author Ambrose Xu
 */
@interface CCTalkService : NSObject <CCService>

/*! 会话监听器。 */
@property (nonatomic, strong) id<CCTalkListener> listener;

/*! 会话代理。 */
@property (nonatomic, assign) id<CCTalkDelegate> delegate;

/*!
 @brief 返回会话服务的单例。
 */
+ (CCTalkService *)sharedSingleton;

/**
 @brief 启动守护任务。
 */
- (void)startDaemon;

/**
 @brief 停止守护任务。
 */
- (void)stopDaemon;

/**
 @brief 启动后台守护任务。
 */
- (void)backgroundKeepAlive;

/*!
 @brief 向指定的 Cellet 发起会话请求。

 @param identifiers 指定要进行会话的 Cellet 标识名列表。
 @param address 指定服务器地址及端口。
 @return 返回是否成功发起请求。
 */
- (BOOL)call:(NSArray *)identifiers hostAddress:(CCInetAddress *)address;

/*!
 @brief 向指定的 Cellet 发起会话请求。

 @param identifiers 指定要进行会话的 Cellet 标识名列表。
 @param address 指定服务器地址及端口。
 @param capacity 指定能力协商。
 @return 返回是否成功发起请求。
 */
- (BOOL)call:(NSArray *)identifiers hostAddress:(CCInetAddress *)address capacity:(CCTalkCapacity *)capacity;

/*!
 @brief 挂断 Cellet 会话服务。

 @param identifier 指定需挂断的 Cellet 标识符。
 */
- (void)hangUp:(NSString *)identifier;

/*!
 @brief 向指定 Cellet 发送原语。

 @param identifier 指定目标 Cellet 的标识。
 @param primitive 指定需发送的原语。
 @return 返回是否成功处理了发送请求。
 */
- (BOOL)talk:(NSString *)identifier primitive:(CCPrimitive *)primitive;

/*!
 @brief 向指定 Cellet 发送方言。

 @param identifier 指定目标 Cellet 的标识。
 @param dialect 指定需发送的方言。
 @return 返回是否成功处理了发送请求。
 */
- (BOOL)talk:(NSString *)identifier dialect:(CCDialect *)dialect;

/*!
 @brief 是否已经与 Cellet 建立服务。

 @param identifier 指定待判断的 Cellet 标识。
 @return 如果已经建立服务返回 <code>YES</code> 。
 */
- (BOOL)isCalled:(NSString *)identifier;

/*!
 @brief 标记指定 Speaker 为连接丢失。
 */
- (void)markLostSpeaker:(CCSpeaker *)speaker;

@end
