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

#import "CellStuff.h"

@interface CCSubjectStuff : CCStuff

/**
 */
+ (CCSubjectStuff *)stuffWithString:(NSString *)value;
/**
 */
+ (CCSubjectStuff *)stuffWithInt:(int)value;
/**
 */
+ (CCSubjectStuff *)stuffWithUInt:(unsigned int)value;
/**
 */
+ (CCSubjectStuff *)stuffWithLong:(long)value;
/**
 */
+ (CCSubjectStuff *)stuffWithULong:(unsigned long)value;
/**
 */
+ (CCSubjectStuff *)stuffWithLongLong:(long long)value;
/**
 */
+ (CCSubjectStuff *)stuffWithBool:(BOOL)value;
/**
 */
+ (CCSubjectStuff *)stuffWithDictionary:(NSDictionary *)value;
/**
 */
+ (CCSubjectStuff *)stuffWithArray:(NSArray *)value;
/**
 */
+ (CCSubjectStuff *)stuffWithFloat:(float)value;
/**
 */
+ (CCSubjectStuff *)stuffWithDouble:(double)value;

@end
