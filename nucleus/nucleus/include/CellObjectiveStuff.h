/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2017 Cell Cloud Team (www.cellcloud.net)
 
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

#import "CellStuff.h"

/*!
 @brief 宾语语素。
 
 @author Ambrose Xu
 */
@interface CCObjectiveStuff : CCStuff

/*!
 @brief 创建字面义为字符串类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithString:(NSString *)value;

/*!
 @brief 创建字面义为整数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithInt:(int)value;

/*!
 @brief 创建字面义为无符号整数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithUInt:(unsigned int)value;

/*!
 @brief 创建字面义为长整数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithLong:(long)value;

/*!
 @brief 创建字面义为无符号长整数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithULong:(unsigned long)value;

/*!
 @brief 创建字面义为长整数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithLongLong:(long long)value;

/*!
 @brief 创建字面义为布尔类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithBool:(BOOL)value;

/*!
 @brief 创建字面义为 JSON 对象类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithDictionary:(NSDictionary *)value;

/*!
 @brief 创建字面义为 JSON 数组类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithArray:(NSArray *)value;

/*!
 @brief 创建字面义为浮点数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithFloat:(float)value;

/*!
 @brief 创建字面义为双精浮点数类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithDouble:(double)value;

/*!
 @brief 创建字面义为二进制类型的宾语语素。
 
 @param value 指定语素数据。
 */
+ (CCObjectiveStuff *)stuffWithData:(NSData *)value;

@end
