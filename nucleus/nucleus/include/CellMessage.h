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
 @brief 消息描述类。

 @author Ambrose Xu
 */
@interface CCMessage : NSObject

/** 消息序号。 */
@property (nonatomic, strong, readonly) NSNumber *sn;
/** 消息数据。 */
@property (nonatomic, strong, readonly) NSData *data;
/** 消息数据的长度。 */
@property (nonatomic, assign, readonly) NSUInteger length;

/**
 @brief 创建指定数据的消息。
 */
+ (CCMessage *)messageWithData:(NSData *)data;

/**
 @brief 指定数据对象初始化。

 @param data 指定消息数据。
 */
- (id)initWithData:(NSData *)data;

/**
 @brief 指定字节数组初始化。

 @param bytes 指定字节数组形式的消息数据。
 @param length 指定数据长度。
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

/**
 @brief 重置消息内的数据。

 @param data 指定消息数据。
 */
- (void)resetData:(NSData *)data;

/**
 @brief 重置消息内的数据。

 @param bytes 指定字节数组形式的消息数据。
 @param length 指定数据长度。
 */
- (void)resetData:(const void *)bytes length:(NSUInteger)length;

@end
