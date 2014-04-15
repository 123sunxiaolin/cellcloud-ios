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
#include "CellLiteralBase.h"

/**
 * 语素类型。
 */
typedef enum _CCStuffType
{
    /// 主语
    CCStuffTypeSubject = 1,
    /// 谓语
    CCStuffTypePredicate = 2,
    /// 宾语
    CCStuffTypeObjective = 3,
    /// 定语
    CCStuffTypeAttributive = 4,
    /// 状语
    CCStuffTypeAdverbial = 5,
    /// 补语
    CCStuffTypeComplement = 6
} CCStuffType;


/**
 * 原语语素。
 *
 * @author Jiangwei Xu
 */
@interface CCStuff : NSObject

@property (nonatomic, assign) CCStuffType type;
@property (nonatomic, assign) CCLiteralBase literalBase;

/**
 */
- (id)initWithString:(NSString *)value;
/**
 */
- (id)initWithInt:(int)value;
/**
 */
- (id)initWithLong:(long)value;
/**
 */
- (id)initWithBool:(BOOL)value;
/**
 */
- (id)initWithData:(NSData *)data literal:(CCLiteralBase)literal;


/** 仅用于子类覆盖 */
- (void)willInitType;

/**
 */
- (NSString *)getValueAsString;
/**
 */
- (int)getValueAsInt;
/**
 */
- (long)getValueAsLong;
/**
 */
- (BOOL)getValueAsBoolean;

@end
