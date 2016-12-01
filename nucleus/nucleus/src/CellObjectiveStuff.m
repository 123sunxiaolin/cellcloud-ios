/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2015 Cell Cloud Team (www.cellcloud.net)
 
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

#import "CellObjectiveStuff.h"

@implementation CCObjectiveStuff

//------------------------------------------------------------------------------
- (void)willInitType
{
    self.type = CCStuffTypeObjective;
}

//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithString:(NSString *)value
{
    return [[CCObjectiveStuff alloc] initWithString:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithInt:(int)value
{
    return [[CCObjectiveStuff alloc] initWithInt:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithUInt:(unsigned int)value
{
    return [[CCObjectiveStuff alloc] initWithUInt:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithLong:(long)value
{
    return [[CCObjectiveStuff alloc] initWithLong:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithULong:(unsigned long)value
{
    return [[CCObjectiveStuff alloc] initWithULong:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithLongLong:(long long)value
{
    return [[CCObjectiveStuff alloc] initWithLongLong:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithBool:(BOOL)value
{
    return [[CCObjectiveStuff alloc] initWithBool:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithDictionary:(NSDictionary *)value
{
    return [[CCObjectiveStuff alloc] initWithDictionary:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithArray:(NSArray *)value
{
    return [[CCObjectiveStuff alloc] initWithArray:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithFloat:(float)value
{
    return [[CCObjectiveStuff alloc] initWithFloat:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithDouble:(double)value
{
    return [[CCObjectiveStuff alloc] initWithDouble:value];
}
//------------------------------------------------------------------------------
+ (CCObjectiveStuff *)stuffWithData:(NSData *)value
{
    return [[CCObjectiveStuff alloc] initWithBin:value];
}

@end
