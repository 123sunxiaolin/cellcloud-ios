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

#import "CellMessageService.h"
#import "CellSession.h"

@implementation CCMessageService

@synthesize delegate = _delegate;

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _headMark = malloc(8);
        memset(_headMark, 0x0, 8);
        _headLength = 0;

        _tailMark = malloc(8);
        memset(_tailMark, 0x0, 8);
        _tailLength = 0;
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithDelegate:(id<CCMessageHandler>)delegate
{
    if ((self = [super init]))
    {
        _delegate = delegate;

        _headMark = malloc(8);
        memset(_headMark, 0x0, 8);
        _headLength = 0;

        _tailMark = malloc(8);
        memset(_tailMark, 0x0, 8);
        _tailLength = 0;
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    free(_headMark);
    _headMark = NULL;
    _headLength = 0;

    free(_tailMark);
    _tailMark = NULL;
    _tailLength = 0;
}
//------------------------------------------------------------------------------
- (void)setDelegate:(id<CCMessageHandler>)delegate
{
    _delegate = delegate;
}
//------------------------------------------------------------------------------
- (void)defineDataMark:(char *)headMark headLength:(size_t)headLength
            tailMark:(char *)tailMark tailLength:(size_t)tailLength
{
    _headLength = headLength;
    memcpy(_headMark, headMark, headLength);

    _tailLength = tailLength;
    memcpy(_tailMark, tailMark, tailLength);
}
//------------------------------------------------------------------------------
- (BOOL)existDataMark
{
    return (_headLength > 0 && _tailLength > 0);
}
//------------------------------------------------------------------------------
- (void)write:(CCSession *)session message:(CCMessage *)message
{
    // Nothing
}

@end
