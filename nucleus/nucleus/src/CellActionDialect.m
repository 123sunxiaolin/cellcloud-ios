/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2013 Cell Cloud Team - cellcloudproject@gmail.com
 
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
        _params = [NSMutableDictionary dictionary];
    }

    return self;
}
//------------------------------------------------------------------------------
- (CCPrimitive *)translate
{
    if (nil == self.action || self.action.length == 0)
    {
        return nil;
    }

    CCPrimitive *primitive = [super translate];

    for (NSString *key in _params)
    {
        NSString *value = [_params objectForKey:key];

        CCSubjectStuff *keyStuff = [CCSubjectStuff stuffWithString:key];
        CCObjectiveStuff *valueStuff = [CCObjectiveStuff stuffWithString:value];
        [primitive commit:keyStuff];
        [primitive commit:valueStuff];
    }
    
    CCPredicateStuff *actionStuff = [CCPredicateStuff stuffWithString:self.action];
    [primitive commit:actionStuff];

    return primitive;
}
//------------------------------------------------------------------------------
- (void)build:(CCPrimitive *)primitive
{
    self.action = [[primitive.predicates objectAtIndex:0] getValueAsString];

    if (nil != primitive.subjects)
    {
        for (NSUInteger i = 0, size = primitive.subjects.count; i < size; ++i)
        {
            NSString *key = [[primitive.subjects objectAtIndex:i] getValueAsString];
            NSString *value = [[primitive.objectives objectAtIndex:i] getValueAsString];
            [_params setObject:value forKey:key];
        }
    }
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name stringValue:(NSString *)value
{
    [_params setObject:value forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name intValue:(int)value
{
    NSString *strValue = [NSString stringWithFormat:@"%d", value];
    [_params setObject:strValue forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name longValue:(long)value
{
    NSString *strValue = [NSString stringWithFormat:@"%ld", value];
    [_params setObject:strValue forKey:name];
}
//------------------------------------------------------------------------------
- (void)appendParam:(NSString *)name boolValue:(BOOL)value
{
    NSString *strValue = [NSString stringWithFormat:@"%@", value ? @"true" : @"false"];
    [_params setObject:strValue forKey:name];
}
//------------------------------------------------------------------------------
- (NSString *)getParamAsString:(NSString *)name
{
    return [_params objectForKey:name];
}
//------------------------------------------------------------------------------
- (int)getParamAsInt:(NSString *)name
{
    NSString *value = [_params objectForKey:name];
    if (nil != value)
        return [value intValue];
    else
        return 0;
}
//------------------------------------------------------------------------------
- (long)getParamAsLong:(NSString *)name
{
    NSString *value = [_params objectForKey:name];
    if (nil != value)
        return [value longLongValue];
    else
        return 0;
}
//------------------------------------------------------------------------------
- (BOOL)getParamAsBool:(NSString *)name
{
    NSString *value = [_params objectForKey:name];
    if (nil != value)
        return [value isEqualToString:@"true"] ? TRUE : FALSE;
    else
        return FALSE;
}
//------------------------------------------------------------------------------
- (BOOL)existParam:(NSString *)name
{
    return [_params objectForKey:name] != nil ? TRUE : FALSE;
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
