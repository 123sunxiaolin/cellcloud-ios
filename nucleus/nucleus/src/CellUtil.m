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
//------------------------------------------------------------------------------
+ (NSString *)randomString:(int)length
{
    char ALPHABET[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
        'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
        'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
    
    int MAX = sizeof(ALPHABET);
    
    char data[length];
    
    for (int i = 0; i < length; ++i)
    {
        int index = arc4random() % MAX;
        
        data[i] = (char)ALPHABET[index];
    };
    
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}
//------------------------------------------------------------------------------
+ (unsigned int)intToBytes:(char *)output input:(int)input
{
    output[0] = input & 0xff;
    output[1] = (input & 0xff00) >> 8;
    output[2] = (input & 0xff0000) >> 16;
    output[3] = (input & 0xff000000) >> 24;
    return 4;
}
//------------------------------------------------------------------------------
+ (unsigned int)longToBytes:(char *)output input:(long long)input
{
    output[0] = input & 0xff;
    output[1] = (input >> 8) & 0xff;
    output[2] = (input >> 16) & 0xff;
    output[3] = (input >> 24) & 0xff;
    output[4] = (input >> 32) & 0xff;
    output[5] = (input >> 40) & 0xff;
    output[6] = (input >> 48) & 0xff;
    output[7] = (input >> 56) & 0xff;
    return 8;
}
//------------------------------------------------------------------------------
+ (unsigned int)floatToBytes:(char *)output input:(float)input
{
    int r = 0;
    memcpy(&r, &input, sizeof(int));
    return [CCUtil intToBytes:output input:r];
}
//------------------------------------------------------------------------------
+ (unsigned int)doubleToBytes:(char *)output input:(double)input
{
    long long r = 0;
    memcpy(&r, &input, sizeof(long long));
    return [CCUtil longToBytes:output input:r];
}
//------------------------------------------------------------------------------
+ (unsigned int)boolToBytes:(char *)output input:(BOOL)input
{
    output[0] = input ? 1 : 0;
    return 1;
}
//------------------------------------------------------------------------------
+ (int)bytesToInt:(char *)input
{
    return (0xff & input[0])
				| (0xff00 & (input[1] << 8))
				| (0xff0000 & (input[2] << 16))
				| (0xff000000 & (input[3] << 24));
}
//------------------------------------------------------------------------------
+ (long long)bytesToLong:(char *)input
{
    return (0xffL & (long long) input[0])
				| (0xff00L & ((long long) input[1] << 8))
				| (0xff0000L & ((long long) input[2] << 16))
				| (0xff000000L & ((long long) input[3] << 24))
				| (0xff00000000L & ((long long) input[4] << 32))
				| (0xff0000000000L & ((long long) input[5] << 40))
				| (0xff000000000000L & ((long long) input[6] << 48))
				| (0xff00000000000000L & ((long long) input[7] << 56));
}
//------------------------------------------------------------------------------
+ (float)bytesToFloat:(char *)input
{
    int r = [CCUtil bytesToInt:input];
    float f = 0.0f;
    memcpy(&f, &r, sizeof(int));
    return f;
}
//------------------------------------------------------------------------------
+ (double)bytesToDouble:(char *)input
{
    long long r = [CCUtil bytesToLong:input];
    double d = 0.0;
    memcpy(&d, &r, sizeof(long long));
    return d;
}
//------------------------------------------------------------------------------
+ (BOOL)bytesToBool:(char *)input
{
    return (input[0] == 1) ? YES : NO;
}

@end
