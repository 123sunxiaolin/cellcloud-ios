/*
 -----------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2012 Cell Cloud Team - cellcloudproject@gmail.com
 
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
 -----------------------------------------------------------------------------
 */

#import "TestHelper.h"

@implementation TestHelper

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        self.primitives = [[NSMutableArray alloc] init];
        self.counts = 0;
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (void)fillPrimitive:(int)num
{
    [self.primitives removeAllObjects];

    for (int i = 0; i < num; ++i)
    {
        CCPrimitive *pri = [[CCPrimitive alloc] init];
        [pri commit:[CCSubjectStuff stuffWithString:@"I'am a SubjectStuff"]];
        [pri commit:[CCPredicateStuff stuffWithInt:1981+i]];
        [pri commit:[CCObjectiveStuff stuffWithLong:198111242012l - i]];
        [pri commit:[CCAttributiveStuff stuffWithBool:(i % 2 == 0 ? TRUE : FALSE)]];
        [pri commit:[CCComplementStuff stuffWithInt:i]];
        [self.primitives addObject:pri];
    }
}
//------------------------------------------------------------------------------
- (BOOL)assertPrimitive:(CCPrimitive *)expected actual:(CCPrimitive *)actual
{
    NSString *expected1 = [[expected.subjects objectAtIndex:0] getValueAsString];
    NSString *actual1 = [[actual.subjects objectAtIndex:0] getValueAsString];
    int expected2 = [[expected.predicates objectAtIndex:0] getValueAsInt];
    int actual2 = [[actual.predicates objectAtIndex:0] getValueAsInt];
    long expected3 = [[expected.objectives objectAtIndex:0] getValueAsLong];
    long actual3 = [[actual.objectives objectAtIndex:0] getValueAsLong];
    BOOL expected4 = [[expected.attributives objectAtIndex:0] getValueAsBoolean];
    BOOL actual4 = [[actual.attributives objectAtIndex:0] getValueAsBoolean];

    if ([expected1 isEqualToString:actual1]
        && expected2 == actual2
        && expected3 == actual3
        && expected4 == actual4)
        return TRUE;
    else
        return FALSE;
}

@end
