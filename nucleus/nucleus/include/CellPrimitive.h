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
#import "CellStuff.h"

/*!
 @brief 原语。用于进行数据传输的基础封装结构。

 @author Ambrose Xu
 */
@interface CCPrimitive : NSObject

/*! 生成该原语的内核节点标签。 */
@property (nonatomic, strong) NSString *ownerTag;
/*! 此原语关联的 Cellet 标识。 */
@property (nonatomic, strong) NSString *celletIdentifier;
/*! 方言。 */
@property (nonatomic, strong, readonly) CCDialect *dialect;
/*! 主语语素清单。 */
@property (nonatomic, strong, readonly) NSMutableArray *subjects;
/*! 谓语语素清单。 */
@property (nonatomic, strong, readonly) NSMutableArray *predicates;
/*! 宾语语素清单。 */
@property (nonatomic, strong, readonly) NSMutableArray *objectives;
/*! 定语语素清单。 */
@property (nonatomic, strong, readonly) NSMutableArray *attributives;
/*! 状语语素清单。 */
@property (nonatomic, strong, readonly) NSMutableArray *adverbials;
/*! 补语语素清单。 */
@property (nonatomic, strong, readonly) NSMutableArray *complements;

/*! 版本号。 */
@property (nonatomic, assign) int version;

/*!
 @brief 使用内核标签初始化。
 
 @param tag 指定内核标签。
 */
- (id)initWithTag:(NSString *)tag;

/*!
 @brief 使用方言初始化。
 
 @param dialect 指定关联的方言。
 */
- (id)initWithDialect:(CCDialect *)dialect;

/*!
 @brief 提交语素。
 
 @param stuff 指定需提交的语素。
 */
- (void)commit:(CCStuff *)stuff;

/*!
 @brief 清空所有语素。
 */
- (void)clearStuff;

/*!
 @brief 复制语素。
 
 @param dest 数据复制的目标原语。
 */
- (void)copyStuff:(CCPrimitive *)dest;

/*!
 @brief 关联方言。
 
 @param dialect 指定需关联的方言。
 */
- (void)capture:(CCDialect *)dialect;

/*!
 @brief 是否具有方言特征。
 
 @return 如果原语具备方言特征可被转为方言则返回 <code>YES</code> 。
 */
- (BOOL)isDialectal;

/*!
 @brief 序列化原语。将原语序列化为字节数据流。
 
 @param primitive 指定待序列化的原语。
 @return 返回成功序列化的数据。
 */
+ (NSData *)write:(CCPrimitive *)primitive;

/*!
 @brief 反序列化原语。
 
 @param stream 指定原语的序列化数据流。
 @param tag 原语的源内核标签。
 @return 返回反序列化的原语。
 */
+ (CCPrimitive *)read:(NSData *)stream andTag:(NSString *)tag;

@end
