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
 @brief Cell Cloud 的内核。内核是 Cell Cloud 运行时的唯一操作入口。
        也是其他服务的根管理器。
 
 @author Ambrose Xu
 */
@interface CCNucleus : NSObject <CCService>

/*! 内核标签。 */
@property (nonatomic, strong, readonly) CCNucleusTag *tag;

/*! 是否允许内核后台运行。 */
@property (nonatomic, setter=setBackgroundActiveEnabled:) BOOL backgroundEnable;

/*!
 @brief 返回 Nucleus 的单例。
 */
+ (CCNucleus *)sharedSingleton;

/*!
 @brief 使用配置信息创建 Nucleus 的单例。
 
 @param config 指定内核配置。
 */
+ (CCNucleus *)createSingletonWith:(CCNucleusConfig *)config;

/*!
 @brief 以字符串形式返回内核标签。
 
 @return 返回字符串形式的内核标签。
 */
- (NSString *)getTagAsString;

/*!
 @brief 启动内核。

 @return 内核启动成功返回 <code>YES</code> 。
 */
- (BOOL)startup;

/*!
 @brief 停止内核。
 */
- (void)shutdown;

/*!
 @brief 休眠内核。当应用程序从前台进入后台时调用。
 */
- (void)sleep;

/*!
 @brief 唤醒内核。当应用程序从后台回到前台时调用。
 */
- (void)wakeup;

@end
