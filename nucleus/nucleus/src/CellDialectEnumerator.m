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

#import "CellDialectEnumerator.h"
#import "CellDialect.h"
#import "CellDialectMetaData.h"
#import "CellDialectFactory.h"

@interface CCDialectEnumerator ()
{
    NSMutableDictionary *_factories;
}

@end

@implementation CCDialectEnumerator

/// 实例
static CCDialectEnumerator *sharedInstance = nil;

//------------------------------------------------------------------------------
+ (CCDialectEnumerator *)sharedSingleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCDialectEnumerator alloc] init];
    });
    return sharedInstance;
}
//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _factories = [NSMutableDictionary dictionary];
    }
    return self;
}
//------------------------------------------------------------------------------
- (CCDialect *)createDialect:(NSString *)name tracker:(NSString *)tracker
{
    CCDialectFactory* fact = [_factories objectForKey:name];
    if (nil != fact)
    {
        return [fact create:tracker];
    }

    return nil;
}
//------------------------------------------------------------------------------
- (void)addFactory:(CCDialectFactory *)fact
{
    if (nil == [_factories objectForKey:[fact getMetaData].name])
    {
        [_factories setObject:fact forKey:[fact getMetaData].name];
    }
}
//------------------------------------------------------------------------------
- (void)removeFactory:(CCDialectFactory *)fact
{
    [_factories removeObjectForKey:[fact getMetaData].name];
}
//------------------------------------------------------------------------------
- (CCDialectFactory *)getFactory:(NSString *)name
{
    return [_factories objectForKey:name];
}

//------------------------------------------------------------------------------
- (void)shutdownAll
{
    if (nil != _factories)
    {
        NSArray *keys = [_factories allKeys];
        for (NSString *key in keys)
        {
            CCDialectFactory *fact = [_factories objectForKey:key];
            [fact shutdown];
        }
    }
}

#pragma mark - CCTalkDelegate

//------------------------------------------------------------------------------
- (BOOL)doTalk:(NSString *)identifier withDialect:(CCDialect *)dialect
{
    CCDialectFactory *fact = [_factories objectForKey:dialect.name];
    if (nil == fact)
    {
        // 返回YES,不劫持
        return YES;
    }
    
    // 回调返回
    return [fact onTalk:identifier andDialect:dialect];
}

//------------------------------------------------------------------------------
- (void)didTalk:(NSString *)identifier withDialect:(CCDialect *)dialect
{
    //Nothing
}

//------------------------------------------------------------------------------
- (BOOL)doDialogue:(NSString *)identifier withDialect:(CCDialect *)dialect
{
    CCDialectFactory *fact = [_factories objectForKey:dialect.name];
    if (nil == fact)
    {
        // 返回YES,不劫持
        return YES;
    }
    // 回调返回
    return [fact onDialogue:identifier andDialect:dialect];
}

//------------------------------------------------------------------------------
- (void)didDialogue:(NSString *)identifier withDialect:(CCDialect *)dialect
{
    //Nothing
}

@end
