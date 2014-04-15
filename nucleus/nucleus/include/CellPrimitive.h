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
#import "CellStuff.h"

/**
 * 原语。
 *
 * @author Jiangwei Xu
 */
@interface CCPrimitive : NSObject

@property (nonatomic, strong) NSString *ownerTag;
@property (nonatomic, strong) NSString *celletIdentifier;
@property (nonatomic, strong, readonly) CCDialect *dialect;
@property (nonatomic, strong, readonly) NSMutableArray *subjects;
@property (nonatomic, strong, readonly) NSMutableArray *predicates;
@property (nonatomic, strong, readonly) NSMutableArray *objectives;
@property (nonatomic, strong, readonly) NSMutableArray *attributives;
@property (nonatomic, strong, readonly) NSMutableArray *adverbials;
@property (nonatomic, strong, readonly) NSMutableArray *complements;

/**
 * 使用标签初始化。
 */
- (id)initWithTag:(NSString *)tag;

/**
 * 使用方言初始化。
 */
- (id)initWithDialect:(CCDialect *)dialect;

/**
 * 提交语素。
 */
- (void)commit:(CCStuff *)stuff;

/**
 * 清空所有语素。
 */
- (void)clearStuff;

/**
 * 复制语素。
 */
- (void)copyStuff:(CCPrimitive *)dest;

/**
 * 关联方言。
 */
- (void)capture:(CCDialect *)dialect;

/**
 * 是否具有方言特征。
 */
- (BOOL)isDialectal;

/**
 * 序列化原语。
 */
+ (NSData *)write:(CCPrimitive *)primitive;

/**
 * 反序列化原语。
 */
+ (CCPrimitive *)read:(NSData *)stream;

@end
