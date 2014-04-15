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

/** 日志等级。
 */
typedef enum _CCLogLevel
{
    /// Debug
    LL_DEBUG = 1,
    /// Info
    LL_INFO = 3,
    /// Warning
    LL_WARN = 5,
    /// Error
    LL_ERROR = 7
} CCLogLevel;


/** 日志事件委派。
 */
@protocol CCLogDelegate <NSObject>

- (void)logDebug:(NSString *)text;
- (void)logInfo:(NSString *)text;
- (void)logWarn:(NSString *)text;
- (void)logError:(NSString *)text;

@end // CCLogDelegate


/** 日志管理器。
 */
@interface CCLoggerManager : NSObject

@property (strong, nonatomic) id<CCLogDelegate> delegate;

/** 返回单例。
 */
+ (CCLoggerManager *)sharedSingleton;

/** 记录日志。
 */
- (void)log:(NSString *)text level:(CCLogLevel)level;

/** 记录日志。
 */
- (void)log:(CCLogLevel)level textFormat:(NSString *)format, ...;

@end
