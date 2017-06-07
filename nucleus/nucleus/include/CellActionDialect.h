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

#import "CellDialect.h"

#define ACTION_DIALECT_NAME @"ActionDialect"

typedef void (^action_block_t)(CCActionDialect*);

/*!
 @brief 动作执行委派。

 @author Ambrose Xu
 */
@protocol CCActionDelegate <NSObject>

/*!
 @brief 执行动作时被线程回调的执行方法。
 */
- (void)doAction:(CCActionDialect *)dialect;

@end


/*!
 @brief 动作方言。

 @author Ambrose Xu
 */
@interface CCActionDialect : CCDialect

/*! 动作名。 */
@property (nonatomic, strong) NSString *action;
/*! 自定义上下文。 */
@property (nonatomic, strong) id<NSObject> customContext;

/*!
 @brief 指定动作的跟踪器初始化。
 
 @param tracker 指定追踪器。
 */
- (id)initWithTracker:(NSString *)tracker;

/*!
 @brief 指定动作名和追踪器初始化。
 
 @param action 指定动作名称。
 */
- (id)initWithAction:(NSString *)action;

/*!
 @brief 指定动作名和追踪器初始化。
 
 @param action 指定动作名称。
 @param tracker 指定追踪器。
 */
- (id)initWithAction:(NSString *)action andTracker:(NSString *)tracker;

/*!
 @brief 添加动作参数键值对。

 @param name 参数名。
 @param value 参数值。
 */
- (void)appendParam:(NSString *)name stringValue:(NSString *)value;

/*!
 @brief 添加动作参数键值对。
 
 @param name 参数名。
 @param value 参数值。
 */
- (void)appendParam:(NSString *)name intValue:(int)value;

/*!
 @brief 添加动作参数键值对。
 
 @param name 参数名。
 @param value 参数值。
 */
- (void)appendParam:(NSString *)name longValue:(long)value;

/*!
 @brief 添加动作参数键值对。
 
 @param name 参数名。
 @param value 参数值。
 */
- (void)appendParam:(NSString *)name longlongValue:(long long)value;

/*!
 @brief 添加动作参数键值对。
 
 @param name 参数名。
 @param value 参数值。
 */
- (void)appendParam:(NSString *)name boolValue:(BOOL)value;

/*!
 @brief 添加动作参数键值对。
 
 @param name 参数名。
 @param value 参数值。
 */
- (void)appendParam:(NSString *)name json:(NSDictionary *)value;

/*!
 @brief 获得指定名称的字符串型参数值。

 @param name 指定待查找参数的参数名。
 @return 返回指定名称的参数值。
 */
- (NSString *)getParamAsString:(NSString *)name;

/*!
 @brief 获得指定名称的整数类型参数值。

 @param name 指定待查找参数的参数名。
 @return 返回指定名称的参数值。
 */
- (int)getParamAsInt:(NSString *)name;

/*!
 @brief 获得指定名称的长整型参数值。

 @param name 指定待查找参数的参数名。
 @return 返回指定名称的参数值。
 */
- (long)getParamAsLong:(NSString *)name;

/*!
 @brief 获得指定名称的长整型参数值。

 @param name 指定待查找参数的参数名。
 @return 返回指定名称的参数值。
 */
- (long long)getParamAsLongLong:(NSString *)name;

/*!
 @brief 获得指定名称的布尔型参数值。

 @param name 指定待查找参数的参数名。
 @return 返回指定名称的参数值。
 */
- (BOOL)getParamAsBool:(NSString *)name;

/*!
 @brief 获得指定名称的 JSON 类型参数值。

 @param name 指定待查找参数的参数名。
 @return 返回指定名称的参数值。
 */
- (NSDictionary *)getParamAsJson:(NSString *)name;

/*!
 @brief 判断指定名称的参数是否存在。

 @param name 待判断的参数名。
 @return 如果存在返回 <code>YES</code> 。
 */
- (BOOL)existParam:(NSString *)name;

/*!
 @brief 判断指定名称的参数是否存在。
 
 @param name 待判断的参数名。
 @return 如果存在返回 <code>YES</code> 。
 */
- (BOOL)hasParam:(NSString *)name;

/**
 * 异步执行动作。
 */
- (void)act:(id<CCActionDelegate>)delegate;

/**
 * 异步执行动作。
 */
- (void)actWithBlock:(action_block_t)block;

@end
