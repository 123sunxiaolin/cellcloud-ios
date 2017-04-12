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
 @brief 加解密工具。
 
 @author Ambrose Xu
 */
@interface CCCryptology : NSObject

/*!
 @brief 返回 CCCryptology 的单例。
 */
+ (CCCryptology *)sharedSingleton;

/*!
 @brief 简单数据异或加密。密钥长度必须为 8 位。

 @param out 加密后的密文。
 @param text 待加密的明文数据。
 @param length 待加密明文数据的长度。
 @param key 加密数据使用的密钥，长度必须为 8 位。
 @return 返回加密后的密文长度。
 */
- (int)simpleEncrypt:(char *)out text:(const char *)text length:(int)length key:(const char *)key;

/*!
 @brief 简单数据异或解密。密钥长度必须为 8 位。

 @param out 解密后的明文。
 @param text 待解密的密文数据。
 @param length 待解密密文数据的长度。
 @param key 解密数据使用的密钥，长度必须为 8 位。
 @return 返回解密后的明文长度。
 */
- (int)simpleDecrypt:(char *)out text:(const char *)text length:(int)length key:(const char *)key;

@end
