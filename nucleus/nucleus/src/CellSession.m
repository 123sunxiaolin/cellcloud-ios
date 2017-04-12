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

#import "CellSession.h"
#import "CellMessageService.h"
#import "CellUtil.h"

@interface CCSession ()
{
@private
    long _id;
    CCMessageService *_service;
    CCInetAddress *_address;

    // 安全密钥
    char *_secretKey;
    int _keyLength;
}
@end

@implementation CCSession

@synthesize writeTimeout = _writeTimeout;
@synthesize lastMessage = _lastMessage;

//------------------------------------------------------------------------------
- (id)initWithService:(CCMessageService *)service address:(CCInetAddress *)address
{
    if ((self = [super init]))
    {
        _service = service;
        _address = address;
        _id = [CCUtil randomLong];
        _writeTimeout = 5.0;
        _secretKey = NULL;
        _keyLength = 0;
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    if (_keyLength > 0 && _secretKey)
    {
        free(_secretKey);
        _secretKey = NULL;
        _keyLength = 0;
    }

    _lastMessage = nil;
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
- (BOOL)isSecure
{
    return (_keyLength > 0);
}
//------------------------------------------------------------------------------
- (BOOL)activeSecretKey:(const char *)key keyLength:(int)keyLength
{
    if (_secretKey && _keyLength > 0)
    {
        free(_secretKey);
        _keyLength = 0;
    }

    _secretKey = malloc(keyLength);
    memcpy(_secretKey, key, keyLength);

    _keyLength = keyLength;
    return YES;
}
//------------------------------------------------------------------------------
- (void)deactiveSecretKey
{
    if (_secretKey && _keyLength > 0)
    {
        free(_secretKey);
        _secretKey = NULL;
        _keyLength = 0;
    }
}
//------------------------------------------------------------------------------
- (const char *)getSecretKey
{
    return _secretKey;
}
//------------------------------------------------------------------------------
- (int)copySecretKey:(char *)out
{
    memcpy(out, _secretKey, _keyLength);
    return _keyLength;
}
//------------------------------------------------------------------------------
- (void)write:(CCMessage *)message
{
    [_service write:self message:message];
}

@end
