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

/**
 * 会话能力描述。
 *
 * @author Jiangwei Xu
 */
@interface CCTalkCapacity : NSObject

/// 版本
@property (nonatomic, assign) int version;

/// 是否为加密会话
@property (nonatomic, assign) BOOL secure;

/// 重复尝试连接的次数
@property (nonatomic, assign) int retry;

/// 两次连接中间隔时间，单位毫秒
@property (nonatomic, assign) NSTimeInterval retryDelay;

/// 版本串号
@property (nonatomic, assign) int versionNumber;

/**
 * 构造函数
 * @param attemts 最大重连次数。
 * @param interval 重连时间间隔。
 */
- (id)initWithRetry:(int)retry andRetryDelay:(int)delay;

/**
 * 构造函数
 * @param secure 是否使用安全连接。
 * @param attemts 最大重连次数。
 * @param interval 重连时间间隔。
 */
- (id)initWithSecure:(BOOL)secure andRetry:(int)retry andRetryDelay:(int)delay;

/**
 * 序列化。
 */
+ (NSData *)serialize:(CCTalkCapacity *)capacity;

/**
 * 反序列化。
 */
+ (CCTalkCapacity *)deserialize:(NSData *)data;

@end
