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

#import "CellTalkCapacity.h"

@implementation CCTalkCapacity


//------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
    {
        // 默认重试间隔：10 秒
        self.retryInterval = 10;
    }
    return self;
}

//------------------------------------------------------------------------------
+ (NSData *)serialize:(CCTalkCapacity *)capacity
{
    NSString *str = [[NSString alloc] initWithFormat:@"%@|%.0f"
                     , capacity.autoSuspend ? @"Y" : @"N"
                     , capacity.suspendDuration * 1000];
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}
//------------------------------------------------------------------------------
+ (CCTalkCapacity *)deserialize:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange range = [str rangeOfString:@"|"];
    NSString *szAutoSuspend = [str substringWithRange:NSMakeRange(0, range.location)];
    NSString *szDuration = [str substringFromIndex:(range.location + range.location)];

    CCTalkCapacity *tc = [[CCTalkCapacity alloc] init];
    tc.autoSuspend = [szAutoSuspend isEqualToString:@"Y"] ? TRUE : FALSE;
    tc.suspendDuration = ((NSTimeInterval)[szDuration longLongValue]) / 1000.0f;

    return tc;
}

@end
