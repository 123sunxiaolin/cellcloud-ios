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

#import "CellUtil.h"

#include <sys/time.h>

@implementation CCUtil

//------------------------------------------------------------------------------
+ (NSTimeInterval)currentTimeInterval
{
    NSDate *date = [[NSDate alloc] init];
    return [date timeIntervalSince1970];
}
//------------------------------------------------------------------------------
+ (int64_t)currentTimeMillis
{
    struct timeval time;
    gettimeofday(&time, NULL);

    float us = roundf(time.tv_usec);
    us = us / 1000.0f;
    us = roundf(us);

    int64_t millis = (time.tv_sec * (int64_t)1000l) + (int64_t)(us);

    return millis;
}
//------------------------------------------------------------------------------
+ (long)randomLong
{
    return arc4random();
}
//------------------------------------------------------------------------------
+ (NSTimeInterval)convertDataToTimeInterval:(NSData *)data
{
    NSString *szTimestamp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    long long llTimestamp = [szTimestamp longLongValue];
    NSTimeInterval timestamp = (NSTimeInterval)llTimestamp / 1000.0f;
    return timestamp;
}

@end
