/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2016 Cell Cloud Team - www.cellcloud.net
 
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

#import "CellTalkCapacity.h"
#import "CellVersion.h"

@implementation CCTalkCapacity


//------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
    {
        // 版本
        self.version = 2;

        // 默认不加密
        self.secure = FALSE;

        // 重连次数，默认 9 次
        self.retry = 9;

        // 重试延迟，默认 10 秒
        self.retryDelay = 10;

        // 版本串号
        self.versionNumber = [CCVersion versionNumber];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithRetry:(int)retry andRetryDelay:(int)delay
{
    self = [super init];
    if (self)
    {
        // 版本
        self.version = 2;

        // 默认不加密
        self.secure = FALSE;

        // 重试参数
        if (retry == INT_MAX)
        {
            self.retry = retry - 1;
        }
        else
        {
            self.retry = retry;
        }
        self.retryDelay = delay;

        // 版本串号
        self.versionNumber = [CCVersion versionNumber];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithSecure:(BOOL)secure andRetry:(int)retry andRetryDelay:(int)delay
{
    self = [super init];
    if (self)
    {
        // 版本
        self.version = 2;

        // 是否加密
        self.secure = secure;

        if (retry == INT_MAX)
        {
            self.retry = retry - 1;
        }
        else
        {
            self.retry = retry;
        }
        self.retryDelay = delay;

        // 版本串号
        self.versionNumber = [CCVersion versionNumber];
    }
    return self;
}
//------------------------------------------------------------------------------
+ (NSData *)serialize:(CCTalkCapacity *)capacity
{
    if (self.version == 1)
    {
        NSString *str = [[NSString alloc] initWithFormat:@"1|%@|%d|%.0f"
                         , capacity.secure ? @"Y" : @"N"
                         , capacity.retry
                         , capacity.retryDelay * 1000];
        return [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        NSString *str = [[NSString alloc] initWithFormat:@"2|%@|%d|%.0f|%d"
                         , capacity.secure ? @"Y" : @"N"
                         , capacity.retry
                         , capacity.retryDelay * 1000
                         , capacity.versionNumber];
        return [str dataUsingEncoding:NSUTF8StringEncoding];
    }
}
//------------------------------------------------------------------------------
+ (CCTalkCapacity *)deserialize:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *items = [str componentsSeparatedByString:@"|"];
    if (items.count < 4)
    {
        return nil;
    }

    CCTalkCapacity *cap = [[CCTalkCapacity alloc] init];

    // 版本
    NSString *szVersion = [items objectAtIndex:0];
    cap.version = [szVersion intValue];
    if (cap.version == 1)
    {
        NSString *szSecure = [items objectAtIndex:1];
        NSString *szRetry = [items objectAtIndex:2];
        NSString *szRetryDelay = [items objectAtIndex:3];

        cap.secure = [szSecure isEqualToString:@"Y"] ? TRUE : FALSE;
        cap.retry = [szRetry intValue];
        cap.retryDelay = ((NSTimeInterval)[szRetryDelay longLongValue]) / 1000.0f;
    }
    else if (cap.version == 2)
    {
        NSString *szSecure = [items objectAtIndex:1];
        NSString *szRetry = [items objectAtIndex:2];
        NSString *szRetryDelay = [items objectAtIndex:3];
        NSString *szVersionNumber = [items objectAtIndex:4];

        cap.secure = [szSecure isEqualToString:@"Y"] ? TRUE : FALSE;
        cap.retry = [szRetry intValue];
        cap.retryDelay = ((NSTimeInterval)[szRetryDelay longLongValue]) / 1000.0f;
        cap.versionNumber = [szVersionNumber intValue];
    }

    return cap;
}

@end
