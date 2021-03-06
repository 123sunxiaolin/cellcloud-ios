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

#import "CellComplementStuff.h"

@implementation CCComplementStuff

//------------------------------------------------------------------------------
- (void)willInitType
{
    self.type = CCStuffTypeComplement;
}

//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithString:(NSString *)value
{
    return [[CCComplementStuff alloc] initWithString:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithInt:(int)value
{
    return [[CCComplementStuff alloc] initWithInt:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithUInt:(unsigned int)value
{
    return [[CCComplementStuff alloc] initWithUInt:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithLong:(long)value
{
    return [[CCComplementStuff alloc] initWithLong:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithULong:(unsigned long)value
{
    return [[CCComplementStuff alloc] initWithULong:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithLongLong:(long long)value
{
    return [[CCComplementStuff alloc] initWithLongLong:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithBool:(BOOL)value
{
    return [[CCComplementStuff alloc] initWithBool:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithDictionary:(NSDictionary *)value
{
    return [[CCComplementStuff alloc] initWithDictionary:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithArray:(NSArray *)value
{
    return [[CCComplementStuff alloc] initWithArray:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithFloat:(float)value
{
    return [[CCComplementStuff alloc] initWithFloat:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithDouble:(double)value
{
    return [[CCComplementStuff alloc] initWithDouble:value];
}
//------------------------------------------------------------------------------
+ (CCComplementStuff *)stuffWithData:(NSData *)value
{
    return [[CCComplementStuff alloc] initWithBin:value];
}

@end
