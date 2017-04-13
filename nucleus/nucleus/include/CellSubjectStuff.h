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
 @brief 主语语素。
 
 @author Ambrose Xu
 */
@interface CCSubjectStuff : CCStuff

/*!
 @brief 创建字面义为字符串类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithString:(NSString *)value;

/*!
 @brief 创建字面义为整数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithInt:(int)value;

/*!
 @brief 创建字面义为无符号整数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithUInt:(unsigned int)value;

/*!
 @brief 创建字面义为长整数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithLong:(long)value;

/*!
 @brief 创建字面义为无符号长整数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithULong:(unsigned long)value;

/*!
 @brief 创建字面义为长整数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithLongLong:(long long)value;

/*!
 @brief 创建字面义为布尔类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithBool:(BOOL)value;

/*!
 @brief 创建字面义为 JSON 对象类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithDictionary:(NSDictionary *)value;

/*!
 @brief 创建字面义为 JSON 数组类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithArray:(NSArray *)value;

/*!
 @brief 创建字面义为浮点数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithFloat:(float)value;

/*!
 @brief 创建字面义为双精浮点数类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithDouble:(double)value;

/*!
 @brief 创建字面义为二进制类型的主语语素。
 
 @param value 指定语素数据。
 */
+ (CCSubjectStuff *)stuffWithData:(NSData *)value;

@end
