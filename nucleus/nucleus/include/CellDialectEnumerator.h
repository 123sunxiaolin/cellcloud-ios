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
#import "CellTalkService.h"

/*!
 @brief 方言枚举器。

 @author Ambrose Xu
 */
@interface CCDialectEnumerator : NSObject <CCTalkDelegate>

/*!
 @brief 返回枚举器的单例。
 */
+ (CCDialectEnumerator *)sharedSingleton;

/*!
 @brief 创建方言。

 @param name 指定方言名称。
 @param tracker 指定追踪器。
 @return 如果没有找到指定名称的方言工厂则无法创建方言，返回 <code>nil</code> 值。
 */
- (CCDialect *)createDialect:(NSString *)name tracker:(NSString *)tracker;

/*!
 @brief 添加方言工厂。

 @param fact 指定方言工厂。
 */
- (void)addFactory:(CCDialectFactory *)fact;

/*!
 @brief 删除方言工厂。

 @param fact 指定方言工厂。
 */
- (void)removeFactory:(CCDialectFactory *)fact;

/*!
 @brief 获取指定名称的方言工厂。

 @param name 指定方言名称。
 @return 返回指定名称的方言工厂。
 */
- (CCDialectFactory *)getFactory:(NSString *)name;

/*!
 @brief 关闭所有方言工厂。
 */
- (void)shutdownAll;

@end
