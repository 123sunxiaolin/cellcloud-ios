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

#import "CellActionDialect.h"
#import "CellPrimitive.h"
#import "CellSubjectStuff.h"
#import "CellObjectiveStuff.h"
#import "CellPredicateStuff.h"

@interface CCActionDialect ()
{
    NSMutableDictionary *_params;
}

@end

@implementation CCActionDialect

//------------------------------------------------------------------------------
- (id)initWithTracker:(NSString *)tracker
{
    if (self = [super initWithName:ACTION_DIALECT_NAME tracker:tracker])
    {
        _params = [[NSMutableDictionary alloc] initWithCapacity:2];
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithAction:(NSString *)action
{
    if (self = [super initWithName:ACTION_DIALECT_NAME tracker:@"none"])
    {
        _action = action;
        _params = [[NSMutableDictionary alloc] initWithCapacity:2];
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithAction:(NSString *)action andTracker:(NSString *)tracker
{
    if (self = [super initWithName:ACTION_DIALECT_NAME tracker:tracker])
    {
        _action = action;
        _params = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (CCPrimitive *)reconstruct
{
    if (nil == self.action || self.action.length == 0)
    {
        return nil;
    }

    CCPrimitive *primitive = [super reconstruct];

    for (NSString *key in _params)
    {
        CCSubjectStuff *keyStuff = [CCSubjectStuff stuffWithString:key];
        CCObjectiveStuff *valueStuff = [_params objectForKey:key];

        [primitive commit:keyStuff];
        [primitive commit:valueStuff];
    }

    CCPredicateStuff *actionStuff = [CCPredicateStuff stuffWithString:self.action];
    [primitive commit:actionStuff];

    return primitive;
}
//------------------------------------------------------------------------------
- (void)construct:(CCPrimitive *)primitive
{
    self.action = [[primitive.predicates objectAtIndex:0] getValueAsString];

    if (nil != primitive.subjects)
    {
        for (NSUInteger i = 0, size = primitive.subjects.count; i < size; ++i)
        {
            NSString *key = [[primitive.subjects objectAtIndex:i] getValueAsString];
            CCObjectiveStuff *value = [primitive.objectives objectAtIndex:i];
            [_params setObject:value forKey:key];
        }
    }
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name stringValue:(NSString *)value
{
    CCObjectiveStuff *stuff = [CCObjectiveStuff stuffWithString:value];
    [_params setObject:stuff forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name intValue:(int)value
{
//    NSString *strValue = [NSString stringWithFormat:@"%d", value];
    CCObjectiveStuff *stuff = [CCObjectiveStuff stuffWithInt:value];
    [_params setObject:stuff forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name longValue:(long)value
{
//    NSString *strValue = [NSString stringWithFormat:@"%ld", value];
    CCObjectiveStuff *stuff = [CCObjectiveStuff stuffWithLong:value];
    [_params setObject:stuff forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name longlongValue:(long long)value
{
//    NSString *strValue = [NSString stringWithFormat:@"%qi", value];
    CCObjectiveStuff *stuff = [CCObjectiveStuff stuffWithLongLong:value];
    [_params setObject:stuff forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name boolValue:(BOOL)value
{
//    NSString *strValue = [NSString stringWithFormat:@"%@", value ? @"true" : @"false"];
    CCObjectiveStuff *stuff = [CCObjectiveStuff stuffWithBool:value];
    [_params setObject:stuff forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name json:(NSDictionary *)value
{
//    __autoreleasing NSError *error = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//    NSString *strValue = [[NSString alloc] initWithData:jsonData
//                                               encoding:NSUTF8StringEncoding];
    CCObjectiveStuff *stuff = [CCObjectiveStuff stuffWithDictionary:value];
    [_params setObject:stuff forKey:name];
}

//------------------------------------------------------------------------------
- (NSString *)getParamAsString:(NSString *)name
{
    CCObjectiveStuff *stuff = [_params objectForKey:name];
    return [stuff getValueAsString];
}
//------------------------------------------------------------------------------
- (int)getParamAsInt:(NSString *)name
{
    CCObjectiveStuff *stuff = [_params objectForKey:name];
    return [stuff getValueAsInt];
}
//------------------------------------------------------------------------------
- (long)getParamAsLong:(NSString *)name
{
    CCObjectiveStuff *stuff = [_params objectForKey:name];
    return [stuff getValueAsLong];
}
//------------------------------------------------------------------------------
- (long long)getParamAsLongLong:(NSString *)name
{
    CCObjectiveStuff *stuff = [_params objectForKey:name];
    return [stuff getValueAsLongLong];
}
//------------------------------------------------------------------------------
- (BOOL)getParamAsBool:(NSString *)name
{
    CCObjectiveStuff *stuff = [_params objectForKey:name];
    return [stuff getValueAsBoolean];
}
//------------------------------------------------------------------------------
- (NSDictionary *)getParamAsJson:(NSString *)name
{
    CCObjectiveStuff *stuff = [_params objectForKey:name];
    return [stuff getValueAsDictionary];
}
//------------------------------------------------------------------------------
- (BOOL)existParam:(NSString *)name
{
    return [_params objectForKey:name] != nil ? YES : NO;
}
//------------------------------------------------------------------------------
- (void)act:(id<CCActionDelegate>)delegate
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
        ^{
            [delegate doAction:self];
        }
    );
}
//------------------------------------------------------------------------------
- (void)actWithBlock:(action_block_t)block
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
        ^{
            block(self);
        }
    );
}

@end
