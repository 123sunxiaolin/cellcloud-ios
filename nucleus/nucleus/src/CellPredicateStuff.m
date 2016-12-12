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

#import "CellPredicateStuff.h"

@implementation CCPredicateStuff

//------------------------------------------------------------------------------
- (void)willInitType
{
    self.type = CCStuffTypePredicate;
}

//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithString:(NSString *)value
{
    return [[CCPredicateStuff alloc] initWithString:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithInt:(int)value
{
    return [[CCPredicateStuff alloc] initWithInt:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithUInt:(unsigned int)value
{
    return [[CCPredicateStuff alloc] initWithUInt:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithLong:(long)value
{
    return [[CCPredicateStuff alloc] initWithLong:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithULong:(unsigned long)value
{
    return [[CCPredicateStuff alloc] initWithULong:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithLongLong:(long long)value
{
    return [[CCPredicateStuff alloc] initWithLongLong:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithBool:(BOOL)value
{
    return [[CCPredicateStuff alloc] initWithBool:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithDictionary:(NSDictionary *)value
{
    return [[CCPredicateStuff alloc] initWithDictionary:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithArray:(NSArray *)value
{
    return [[CCPredicateStuff alloc] initWithArray:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithFloat:(float)value
{
    return [[CCPredicateStuff alloc] initWithFloat:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithDouble:(double)value
{
    return [[CCPredicateStuff alloc] initWithDouble:value];
}
//------------------------------------------------------------------------------
+ (CCPredicateStuff *)stuffWithData:(NSData *)value
{
    return [[CCPredicateStuff alloc] initWithBin:value];
}

@end
