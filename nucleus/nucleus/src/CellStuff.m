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

#import "CellStuff.h"
#import "CellUtil.h"

@interface CCStuff ()
{
@private
    NSData *_value;
}
@end

@implementation CCStuff

@synthesize type;
@synthesize literalBase;

//------------------------------------------------------------------------------
- (id)initWithString:(NSString *)value
{
    if ((self = [super init]))
    {
        _value = [value dataUsingEncoding:NSUTF8StringEncoding];
        self.literalBase = CCLiteralBaseString;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithInt:(int)value
{
    if ((self = [super init]))
    {
        char dest[4] = {0, 0, 0, 0};
        NSUInteger length = [CCUtil intToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseInt;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithUInt:(unsigned int)value
{
    if ((self = [super init]))
    {
        char dest[4] = {0, 0, 0, 0};
        NSUInteger length =[CCUtil intToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseUInt;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithLong:(long)value
{
    if ((self = [super init]))
    {
        char dest[8] = {0, 0, 0, 0, 0, 0, 0, 0};
        NSUInteger length = [CCUtil longToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseLong;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithULong:(unsigned long)value
{
    if ((self = [super init]))
    {
        char dest[8] = {0, 0, 0, 0, 0, 0, 0, 0};
        NSUInteger length = [CCUtil longToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseULong;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithLongLong:(long long)value
{
    if ((self = [super init]))
    {
        char dest[8] = {0, 0, 0, 0, 0, 0, 0, 0};
        NSUInteger length = [CCUtil longToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseLong;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithBool:(BOOL)value
{
    if ((self = [super init]))
    {
        char dest[1] = {0};
        NSUInteger length = [CCUtil boolToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseBool;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithDictionary:(NSDictionary *)value
{
    if ((self = [super init]))
    {
        __autoreleasing NSError *error = nil;
        _value = [NSJSONSerialization dataWithJSONObject:value
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:&error];
        self.literalBase = CCLiteralBaseJSON;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithArray:(NSArray *)value
{
    if ((self = [super init]))
    {
        __autoreleasing NSError *error = nil;
        _value = [NSJSONSerialization dataWithJSONObject:value
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:&error];
        self.literalBase = CCLiteralBaseJSON;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithFloat:(float)value
{
    if ((self = [super init]))
    {
        char dest[4] = {0, 0, 0, 0};
        NSUInteger length = [CCUtil floatToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseFloat;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithDouble:(double)value
{
    if ((self = [super init]))
    {
        char dest[8] = {0, 0, 0, 0, 0, 0, 0, 0};
        NSUInteger length = [CCUtil doubleToBytes:dest input:value];
        _value = [NSData dataWithBytes:dest length:length];
        self.literalBase = CCLiteralBaseDouble;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithBin:(NSData *)value
{
    if ((self = [super init]))
    {
        _value = [NSData dataWithData:value];
        self.literalBase = CCLiteralBaseBin;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithData:(NSData *)data literal:(CCLiteralBase)literal
{
    if ((self = [super init]))
    {
        _value = [NSData dataWithData:data];
        self.literalBase = literal;
        [self willInitType];
    }
    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    _value = nil;
}
//------------------------------------------------------------------------------
- (void)willInitType
{
    // Nothing
}
//------------------------------------------------------------------------------
- (NSData *)getValue
{
    return _value;
}
//------------------------------------------------------------------------------
- (NSString *)getValueAsString
{
    return [[NSString alloc] initWithData:_value encoding:NSUTF8StringEncoding];
}
//------------------------------------------------------------------------------
- (int)getValueAsInt
{
//    return [_value intValue];

    // 检查数据
    if (_value.length < 4)
    {
        return 0;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    int result = [CCUtil bytesToInt:buf];
    free(buf);

    return result;
}
//------------------------------------------------------------------------------
- (unsigned int)getValueAsUInt
{
//    return [_value intValue];

    // 检查数据
    if (_value.length < 4)
    {
        return 0;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    int result = [CCUtil bytesToInt:buf];
    free(buf);

    return result;
}
//------------------------------------------------------------------------------
- (long)getValueAsLong
{
//    return [NSNumber numberWithLongLong:[_value longLongValue]].longValue;

    // 检查数据
    if (_value.length < 8)
    {
        return 0;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    long long result = [CCUtil bytesToLong:buf];
    free(buf);

    return [NSNumber numberWithLongLong:result].longValue;
}
//------------------------------------------------------------------------------
- (unsigned long)getValueAsULong
{
//    return [NSNumber numberWithLongLong:[_value longLongValue]].unsignedLongValue;

    // 检查数据
    if (_value.length < 8)
    {
        return 0;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    long long result = [CCUtil bytesToLong:buf];
    free(buf);

    return [NSNumber numberWithLongLong:result].unsignedLongValue;
}
//------------------------------------------------------------------------------
- (long long)getValueAsLongLong
{
//    return [_value longLongValue];

    // 检查数据
    if (_value.length < 8)
    {
        return 0;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    long long result = [CCUtil bytesToLong:buf];
    free(buf);

    return result;
}
//------------------------------------------------------------------------------
- (BOOL)getValueAsBoolean
{
//    return [_value isEqualToString:@"true"] ? TRUE : FALSE;

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    BOOL result = [CCUtil bytesToBool:buf];
    free(buf);

    return result;
}
//------------------------------------------------------------------------------
- (NSDictionary *)getValueAsDictionary
{
    __autoreleasing NSError *error = nil;
//    NSData *jsonData = [_value dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:_value
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
    return ret;
}
//------------------------------------------------------------------------------
- (NSArray *)getValueAsArray
{
    __autoreleasing NSError *error = nil;
//    NSData *jsonData = [_value dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *ret = [NSJSONSerialization JSONObjectWithData:_value
                                                   options:NSJSONReadingAllowFragments
                                                     error:&error];
    return ret;
}
//------------------------------------------------------------------------------
- (float)getValueAsFloat
{
//    return [_value floatValue];

    // 检查数据
    if (_value.length < 4)
    {
        return 0.0f;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    float result = [CCUtil bytesToFloat:buf];
    free(buf);

    return result;
}
//------------------------------------------------------------------------------
- (double)getValueAsDouble
{
//    return [_value doubleValue];

    // 检查数据
    if (_value.length < 8)
    {
        return 0.0f;
    }

    char *buf = malloc(sizeof(char) * _value.length);
    memcpy(buf, _value.bytes, _value.length);
    double result = [CCUtil bytesToDouble:buf];
    free(buf);

    return result;
}

@end
