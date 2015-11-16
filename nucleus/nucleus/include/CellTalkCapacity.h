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

#include "CellPrerequisites.h"

/**
 * 会话能力描述。
 *
 * @author Jiangwei Xu
 */
@interface CCTalkCapacity : NSObject

/// 是否为加密会话
@property (nonatomic, assign) BOOL secure;

/// 重复尝试连接的次数
@property (nonatomic, assign) int retryAttempts;

/// 对话失败时，尝试重新建立会话的操作间隔
@property (nonatomic, assign) NSTimeInterval retryInterval;

/**
 * 构造函数
 * @param attemts 最大重连次数。
 * @param interval 重连时间间隔。
 */
- (id)initWithRetryAttemts:(int)attemts andRetryInterval:(int)interval;

/**
 * 序列化。
 */
+ (NSData *)serialize:(CCTalkCapacity *)capacity;

/**
 * 反序列化。
 */
+ (CCTalkCapacity *)deserialize:(NSData *)data;

@end
