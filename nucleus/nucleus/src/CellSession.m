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

#import "CellSession.h"
#import "CellMessageService.h"
#import "CellUtil.h"

@interface CCSession ()
{
@private
    long _id;
    CCMessageService *_service;
    CCInetAddress *_address;
}
@end

@implementation CCSession

@synthesize id = _id;

//------------------------------------------------------------------------------
- (id)initWithService:(CCMessageService *)service address:(CCInetAddress *)address
{
    if ((self = [super init]))
    {
        _service = service;
        _address = address;
        _id = [CCUtil randomLong];
    }

    return self;
}
//------------------------------------------------------------------------------
- (long)getId
{
    return _id;
}
//------------------------------------------------------------------------------
- (CCMessageService *)getService
{
    return _service;
}
//------------------------------------------------------------------------------
- (CCInetAddress *)getAddress
{
    return _address;
}
//------------------------------------------------------------------------------
- (void)write:(CCMessage *)message
{
    [_service write:self message:message];
}

@end
