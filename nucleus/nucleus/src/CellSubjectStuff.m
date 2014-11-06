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

#import "CellSubjectStuff.h"

@implementation CCSubjectStuff

//------------------------------------------------------------------------------
- (void)willInitType
{
    self.type = CCStuffTypeSubject;
}

//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithString:(NSString *)value
{
    return [[CCSubjectStuff alloc] initWithString:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithInt:(int)value
{
    return [[CCSubjectStuff alloc] initWithInt:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithUInt:(unsigned int)value
{
    return [[CCSubjectStuff alloc] initWithUInt:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithLong:(long)value
{
    return [[CCSubjectStuff alloc] initWithLong:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithULong:(unsigned long)value
{
    return [[CCSubjectStuff alloc] initWithULong:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithBool:(BOOL)value
{
    return [[CCSubjectStuff alloc] initWithBool:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithDictionary:(NSDictionary *)value
{
    return [[CCSubjectStuff alloc] initWithDictionary:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithArray:(NSArray *)value
{
    return [[CCSubjectStuff alloc] initWithArray:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithFloat:(float)value
{
    return [[CCSubjectStuff alloc] initWithFloat:value];
}
//------------------------------------------------------------------------------
+ (CCSubjectStuff *)stuffWithDouble:(double)value
{
    return [[CCSubjectStuff alloc] initWithDouble:value];
}

@end
