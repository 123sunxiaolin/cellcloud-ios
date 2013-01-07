/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2012 Cell Cloud Team - cellcloudproject@gmail.com
 
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

#import "CellNucleus.h"
#import "CellNucleusConfig.h"
#import "CellNucleusTag.h"
#import "CellTalkService.h"
#import "CellLogger.h"
#import "CellVersion.h"

@interface CCNucleus ()
{
@private
    CCNucleusTag *_tag;
    CCNucleusConfig *_config;
}

/** 使用配置参数初始化 */
- (id)initWithConfig:(CCNucleusConfig *)config;

@end


@implementation CCNucleus

@synthesize tag = _tag;

/// 实例
static CCNucleus *sharedInstance = nil;

//------------------------------------------------------------------------------
+ (CCNucleus *)sharedSingleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCNucleus alloc] init];
    });
    return sharedInstance;
}
//------------------------------------------------------------------------------
 + (CCNucleus *)sharedSingletonWithConfig:(CCNucleusConfig *)config
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCNucleus alloc] initWithConfig:config];
    });
    return sharedInstance;
}
//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _tag = [[CCNucleusTag alloc] initWithRandom];
        _config = [[CCNucleusConfig alloc] init];
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithConfig:(CCNucleusConfig *)config
{
    if ((self = [super init]))
    {
        _tag = [[CCNucleusTag alloc] initWithRandom];
        _config = [[CCNucleusConfig alloc] init];
        
        _config.role = config.role;
        _config.device = config.device;

        [CCLogger i:@"Cell Cloud %d.%d.%d (Build iOS - %@)"
            , [CCVersion major]
            , [CCVersion minor]
            , [CCVersion revision]
            , [CCVersion name]];
        [CCLogger i:@"Nucleus Tag : %@", [_tag getAsString]];
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
}
//------------------------------------------------------------------------------
- (NSString *)getTagAsString
{
    return [_tag getAsString];
}
//------------------------------------------------------------------------------
- (BOOL)startup
{
    [CCLogger i:@"*-*-* Cell Initializing *-*-*"];

    CCTalkService *talkService = [CCTalkService sharedSingleton];

    // 节点角色
    if ((_config.role & NODE) != 0)
    {
        // 启动 Talk Service
        if ([talkService startup])
        {
            // TODO
        }
        else
        {
            // TODO
        }
    }

    // 消费角色
    if ((_config.role & CONSUMER) != 0)
    {
        [talkService startDaemon];
    }

    return TRUE;
}
//------------------------------------------------------------------------------
- (void)shutdown
{
    [CCLogger i:@"*-*-* Cell Finalizing *-*-*"];
    // TODO
}

@end
