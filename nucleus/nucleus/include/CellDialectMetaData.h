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
 @brief 方言元数据。

 @author Ambrose Xu
 */
@interface CCDialectMetaData : NSObject

/*! 标识方言的唯一字符串标识符。 */
@property (nonatomic, strong, readonly) NSString *name;
/*! 方言文本描述。 */
@property (nonatomic, strong, readonly) NSString *description;

/*!
 @brief 指定方言名和描述初始化。

 @param name 指定方言名称。
 @param description 指定方言描述信息。
 */
- (id)initWithName:(NSString *)name description:(NSString *)description;


/*!
 @brief 使用指定名称和描述构建 Meta Data

 @param name 指定方言名称。
 @param description 指定方言描述信息。
 */
+ (CCDialectMetaData *)metaDataWithName:(NSString *)name description:(NSString *)description;

@end
