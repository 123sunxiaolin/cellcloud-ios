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

#import "CellAdverbialStuff.h"

@implementation CCAdverbialStuff

//------------------------------------------------------------------------------
- (void)willInitType
{
    self.type = CCStuffTypeAdverbial;
}

//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithString:(NSString *)value
{
    return [[CCAdverbialStuff alloc] initWithString:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithInt:(int)value
{
    return [[CCAdverbialStuff alloc] initWithInt:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithUInt:(unsigned int)value
{
    return [[CCAdverbialStuff alloc] initWithUInt:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithLong:(long)value
{
    return [[CCAdverbialStuff alloc] initWithLong:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithULong:(unsigned long)value
{
    return [[CCAdverbialStuff alloc] initWithULong:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithLongLong:(long long)value
{
    return [[CCAdverbialStuff alloc] initWithLongLong:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithBool:(BOOL)value
{
    return [[CCAdverbialStuff alloc] initWithBool:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithDictionary:(NSDictionary *)value
{
    return [[CCAdverbialStuff alloc] initWithDictionary:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithArray:(NSArray *)value
{
    return [[CCAdverbialStuff alloc] initWithArray:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithFloat:(float)value
{
    return [[CCAdverbialStuff alloc] initWithFloat:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithDouble:(double)value
{
    return [[CCAdverbialStuff alloc] initWithDouble:value];
}
//------------------------------------------------------------------------------
+ (CCAdverbialStuff *)stuffWithData:(NSData *)value
{
    return [[CCAdverbialStuff alloc] initWithBin:value];
}

@end
