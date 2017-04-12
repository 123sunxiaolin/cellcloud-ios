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
 @brief 消息会话描述。
 
 @author Ambrose Xu
 */
@interface CCSession : NSObject

/*! 发送数据时的超时时间，单位：秒。 */
@property (nonatomic, assign) NSTimeInterval writeTimeout;

/*! 最近一次处理的消息。 */
@property (nonatomic, strong) CCMessage *lastMessage;

/*!
 @brief 指定消息服务实例和地址初始化。
 */
- (id)initWithService:(CCMessageService *)service address:(CCInetAddress *)address;

/*!
 @brief 返回会话 ID 。
 */
- (long)getId;

/*!
 @brief 返回消息服务实例。
 */
- (CCMessageService *)getService;

/*!
 @brief 返回会话的网络地址。
 */
- (CCInetAddress *)getAddress;

/*!
 @brief 是否是安全连接。
 */
- (BOOL)isSecure;

/*!
 @brief 使用密钥激活加密模式。
 
 @param key 指定密钥数据。
 @param keyLength 指定密钥长度。
 */
- (BOOL)activeSecretKey:(const char *)key keyLength:(int)keyLength;

/*!
 @brief 吊销密钥，不使用加密模式。
 */
- (void)deactiveSecretKey;

/*!
 @brief 返回安全密钥。
 */
- (const char *)getSecretKey;

/*!
 @brief 复制密钥，并返回密钥长度。
 
 @param out 接收复制数据的缓存。
 @return 返回密钥长度。
 */
- (int)copySecretKey:(char *)out;

/*!
 @brief 向该会话发送指定的消息。
 
 @param message 指定待发送的消息。
 */
- (void)write:(CCMessage *)message;

@end
