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

#import "CellTalkServiceFailure.h"

@interface CCTalkServiceFailure (Private)

- (void)construct:(CCTalkFailureCode)code file:(const char *)file line:(int)line function:(const char *)function;

@end


@implementation CCTalkServiceFailure

@synthesize description;

//------------------------------------------------------------------------------
- (id)initWithSource:(CCTalkFailureCode)code file:(const char *)file line:(int)line function:(const char *)function
{
    if ((self = [super init]))
    {
        [self construct:code file:file line:line function:function];
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)construct:(CCTalkFailureCode)code file:(const char *)file line:(int)line function:(const char *)function
{
    self.code = code;
    self.reason = [NSString stringWithFormat:@"Error in %s function - %s on line %d", function, file, line];

    switch (code)
    {
    case CCFailureNotFoundCellet:
        self.description = @"Server can not find specified cellet";
        self.sourceDescription = @"";
        break;
    case CCFailureCallFailed:
        self.description = @"Network connecting timeout";
        self.sourceDescription = @"";
        break;
    case CCFailureTalkLost:
        self.description = @"Lost talk connection";
        self.sourceDescription = @"";
        break;
    case CCFailureRetryEnd:
        self.description = @"Auto retry end";
        self.sourceDescription = @"";
        break;
    default:
        self.description = @"Unknown failure";
        self.sourceDescription = @"";
        break;
    }
}

@end
