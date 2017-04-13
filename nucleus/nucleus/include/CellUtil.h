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
 @brief 辅助函数库。
 
 @author Ambrose Xu
 */
@interface CCUtil : NSObject

/*!
 @brief 返回当前系统绝对时间值。单位：秒。
 */
+ (NSTimeInterval)currentTimeInterval;

/*!
 @brief 返回当前系统绝对时间值。单位：毫秒。
 */
+ (int64_t)currentTimeMillis;

/*!
 @brief 生成随机数。
 */
+ (long)randomLong;

/*!
 @brief 生成指定长度的随机字符串。
 
 @param length 指定字符串长度。
 @return 返回生成的字符串。
 */
+ (NSString *)randomString:(int)length;

/*!
 @brief 转换 NSData 为 NSTimeInterval，即绝对时间。
 */
+ (NSTimeInterval)convertDataToTimeInterval:(NSData *)data;

/*!
 @brief short 型转字节流。
 */
+ (unsigned int)shortToBytes:(char *)output input:(short)input;

/*!
 @brief int 型转字节流。
 */
+ (unsigned int)intToBytes:(char *)output input:(int)input;

/*!
 @brief long long 型转字节流。
 */
+ (unsigned int)longToBytes:(char *)output input:(long long)input;

/*!
 @brief float 型转字节流。
 */
+ (unsigned int)floatToBytes:(char *)output input:(float)input;

/*!
 @brief double 型转字节流。
 */
+ (unsigned int)doubleToBytes:(char *)output input:(double)input;

/*!
 @brief BOOL 型转字节流。
 */
+ (unsigned int)boolToBytes:(char *)output input:(BOOL)input;

/*!
 @brief 字节流转 short 型。
 */
+ (short)bytesToShort:(char *)input;

/*!
 @brief 字节流转 int 型。
 */
+ (int)bytesToInt:(char *)input;

/*!
 @brief 字节流转 long long 型。
 */
+ (long long)bytesToLong:(char *)input;

/*!
 @brief 字节流转 float 型。
 */
+ (float)bytesToFloat:(char *)input;

/*!
 @brief 字节流转 double 型。
 */
+ (double)bytesToDouble:(char *)input;

/*!
 @brief 字节流转 BOOL 型。
 */
+ (BOOL)bytesToBool:(char *)input;

@end
