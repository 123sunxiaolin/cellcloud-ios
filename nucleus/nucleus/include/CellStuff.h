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

#include "CellPrerequisites.h"
#include "CellLiteralBase.h"

/*!
 @brief 语素类型。
 */
typedef enum _CCStuffType
{
    /*! 主语。 */
    CCStuffTypeSubject = 1,

    /*! 谓语。 */
    CCStuffTypePredicate = 2,

    /*! 宾语。 */
    CCStuffTypeObjective = 3,

    /*! 定语。 */
    CCStuffTypeAttributive = 4,

    /*! 状语。 */
    CCStuffTypeAdverbial = 5,

    /*! 补语。 */
    CCStuffTypeComplement = 6

} CCStuffType;


/*!
 @brief 原语语素。

 @author Ambrose Xu
 */
@interface CCStuff : NSObject

/*! 语素类型。 */
@property (nonatomic, assign) CCStuffType type;
/*! 语素值的字面义。 */
@property (nonatomic, assign) CCLiteralBase literalBase;

/*!
 @brief 初始化为字面义为字符串类型。

 @param value 指定语义为字符串的数据。
 */
- (id)initWithString:(NSString *)value;

/*!
 @brief 初始化为字面义为整数类型。
 
 @param value 指定语义为整数的数据。
 */
- (id)initWithInt:(int)value;

/*!
 @brief 初始化为字面义为无符号整数类型。
 
 @param value 指定语义为无符号整数的数据。
 */
- (id)initWithUInt:(unsigned int)value;

/*!
 @brief 初始化为字面义为长整数类型。
 
 @param value 指定语义为长整数的数据。
 */
- (id)initWithLong:(long)value;

/*!
 @brief 初始化为字面义为无符号长整数类型。
 
 @param value 指定语义为无符号长整数的数据。
 */
- (id)initWithULong:(unsigned long)value;

/*!
 @brief 初始化为字面义为长整数类型。
 
 @param value 指定语义为长整数的数据。
 */
- (id)initWithLongLong:(long long)value;

/*!
 @brief 初始化为字面义为布尔类型。
 
 @param value 指定语义为布尔值的数据。
 */
- (id)initWithBool:(BOOL)value;

/*!
 @brief 初始化为字面义为 JSON 对象类型。
 
 @param value 指定语义为 JSON 对象的数据。
 */
- (id)initWithDictionary:(NSDictionary *)value;

/*!
 @brief 初始化为字面义为 JSON 数组类型。
 
 @param value 指定语义为 JSON 数组的数据。
 */
- (id)initWithArray:(NSArray *)value;

/*!
 @brief 初始化为字面义为浮点数类型。
 
 @param value 指定语义为浮点数的数据。
 */
- (id)initWithFloat:(float)value;

/*!
 @brief 初始化为字面义为双精浮点类型。
 
 @param value 指定语义为双精浮点的数据。
 */
- (id)initWithDouble:(double)value;

/*!
 @brief 初始化为字面义为二进制类型。
 
 @param value 指定语义为二进制的数据。
 */
- (id)initWithBin:(NSData *)value;

/*!
 @brief 指定数据和字面义初始化。
 
 @param data 指定数据。
 @param literal 指定字面义。
 */
- (id)initWithData:(NSData *)data literal:(CCLiteralBase)literal;


/**
 仅用于子类覆盖。
 */
- (void)willInitType;

/*!
 @brief 按照二进制形式返回值。

 @return 返回字节数组形式的二进制数据。
 */
- (NSData *)getValue;

/*!
 @brief 按照字符串形式返回值。

 @return 返回字符串数据。
 */
- (NSString *)getValueAsString;

/*!
 @brief 按照整数形式返回值。

 @return 返回整数数据。
 */
- (int)getValueAsInt;

/*!
 @brief 按照无符号整数形式返回值。

 @return 返回无符号整数数据。
 */
- (unsigned int)getValueAsUInt;

/*!
 @brief 按照长整数形式返回值。

 @return 返回长整数数据。
 */
- (long)getValueAsLong;

/*!
 @brief 按照无符号长整数形式返回值。

 @return 返回无符号长整数数据。
 */
- (unsigned long)getValueAsULong;

/*!
 @brief 按照长整数形式返回值。

 @return 返回长整数数据。
 */
- (long long)getValueAsLongLong;

/*!
 @brief 按照布尔值形式返回值。

 @return 返回布尔值数据。
 */
- (BOOL)getValueAsBoolean;

/*!
 @brief 按照 JSON 对象格式返回值。

 @return 返回 JSON 对象数据。
 */
- (NSDictionary *)getValueAsDictionary;

/*!
 @brief 按照 JSON 数组格式返回值。

 @return 返回 JSON 数组数据。
 */
- (NSArray *)getValueAsArray;

/*!
 @brief 按照浮点数形式返回值。

 @return 返回浮点数数据。
 */
- (float)getValueAsFloat;

/*!
 @brief 按照双精浮点数形式返回值。

 @return 返回双精浮点数数据。
 */
- (double)getValueAsDouble;

@end
