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

@implementation CCTalkCapacity


//------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
    {
        // 默认不加密
        self.secure = FALSE;

        // 默认重连次数
        self.retryAttempts = 9;

        // 默认重试间隔：10 秒
        self.retryInterval = 10;
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithRetryAttemts:(int)attemts andRetryInterval:(int)interval
{
    self = [super init];
    if (self)
    {
        self.secure = FALSE;

        if (attemts == INT_MAX)
        {
            self.retryAttempts -= 1;
        }
        self.retryAttempts = attemts;
        self.retryInterval = interval;
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithSecure:(BOOL)secure andAttempts:(int)attemts andRetryInterval:(int)interval
{
    self = [super init];
    if (self)
    {
        self.secure = secure;

        if (attemts == INT_MAX)
        {
            self.retryAttempts -= 1;
        }
        self.retryAttempts = attemts;
        self.retryInterval = interval;
    }
    return self;
}
//------------------------------------------------------------------------------
+ (NSData *)serialize:(CCTalkCapacity *)capacity
{
    NSString *str = [[NSString alloc] initWithFormat:@"2|%@|%d|%.0f|150"
                     , capacity.secure ? @"Y" : @"N"
                     , capacity.retryAttempts
                     , capacity.retryInterval * 1000];
    return [str dataUsingEncoding:NSUTF8StringEncoding];
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

    //NSString *szVersion = [items objectAtIndex:0];
    NSString *szSecure = [items objectAtIndex:1];
    NSString *szRetryAttempts = [items objectAtIndex:2];
    NSString *szRetryInterval = [items objectAtIndex:3];

    CCTalkCapacity *tc = [[CCTalkCapacity alloc] init];
    tc.secure = [szSecure isEqualToString:@"Y"] ? TRUE : FALSE;
    tc.retryAttempts = (int) [szRetryAttempts integerValue];
    tc.retryInterval = ((NSTimeInterval)[szRetryInterval longLongValue]) / 1000.0f;

    return tc;
}

@end
