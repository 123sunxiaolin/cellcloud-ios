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

#import "CellDialect.h"

#define ACTION_DIALECT_NAME @"ActionDialect"

typedef void (^action_block_t)(CCActionDialect*);

/**
 * 动作执行委派。
 *
 * @author Jiangwei Xu
 */
@protocol CCActionDelegate <NSObject>

/**
 * 执行动作时被线程回调的执行方法。
 */
- (void)doAction:(CCActionDialect *)dialect;

@end


/**
 * 动作方言。
 *
 * @author Jiangwei Xu
 */
@interface CCActionDialect : CCDialect

/// 动作名
@property (nonatomic, strong) NSString *action;
/// 自定义上下文
@property (nonatomic, strong) id<NSObject> customContext;

/**
 * 指定动作的跟踪器。
 */
- (id)initWithTracker:(NSString *)tracker;

/**
 * 指定动作名称。
 */
- (id)initWithAction:(NSString *)action;

/**
 * 添加动作键值对。
 */
- (void)appendParam:(NSString *)name stringValue:(NSString *)value;

/**
 * 添加动作键值对。
 */
- (void)appendParam:(NSString *)name intValue:(int)value;

/**
 * 添加动作键值对。
 */
- (void)appendParam:(NSString *)name longValue:(long)value;

/**
 * 添加动作键值对。
 */
- (void)appendParam:(NSString *)name boolValue:(BOOL)value;

/**
 * 返回指定名称的参数值。
 */
- (NSString *)getParamAsString:(NSString *)name;

/**
 * 返回指定名称的参数值。
 */
- (int)getParamAsInt:(NSString *)name;

/**
 * 返回指定名称的参数值。
 */
- (long)getParamAsLong:(NSString *)name;

/**
 * 返回指定名称的参数值。
 */
- (BOOL)getParamAsBool:(NSString *)name;

/**
 * 判断指定名称的参数是否存在。
 */
- (BOOL)existParam:(NSString *)name;

/**
 * 异步执行动作。
 */
- (void)act:(id<CCActionDelegate>)delegate;

/**
 * 异步执行动作。
 */
- (void)actWithBlock:(action_block_t)block;

@end
