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
 @brief 方言工厂。

 @author Ambrose Xu
 */
@interface CCDialectFactory : NSObject

/*!
 @brief 返回元数据。
 */
- (CCDialectMetaData *)getMetaData;

/*!
 @brief 创建方言。
 
 @param tracker 指定该方言的追踪器。
 */
- (CCDialect *)create:(NSString *)tracker;

/*!
 @brief 关闭工厂。
 */
- (void)shutdown;

/*!
 @brief 休眠工厂。
 */
- (void)sleep;

/*!
 @brief 唤醒工厂。
 */
- (void)wakeup;

/*!
 @brief 当发送方言时此方法被回调。

 @param identifier 目标 Cellet 标识。
 @param dialect 被发送的方言。
 @return 返回 <code>NO</code> 表示工厂截获该方言，将不被送入发送队列。
 */
- (BOOL)onTalk:(NSString *)identifier andDialect:(CCDialect *)dialect;

/*!
 @brief 当收到对应的方言时此方法被回调。

 @param identifier 来源 Cellet 标识。
 @param dialect 接收到的方言。
 @return 返回 <code>NO</code> 表示工厂截获该方言，将不调用监听器通知 dialogue 事件发生。
 */
- (BOOL)onDialogue:(NSString *)identifier andDialect:(CCDialect *)dialect;

@end
