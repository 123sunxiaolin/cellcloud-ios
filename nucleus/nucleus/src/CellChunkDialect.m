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

#import "CellChunkDialect.h"
#import "CellChunkDialectFactory.h"
#import "CellDialectEnumerator.h"
#import "CellPredicateStuff.h"
#import "CellPrimitive.h"
#import "CellSubjectStuff.h"

@implementation CCChunkDialect

@synthesize delegate = _delegate;
@synthesize sign = _sign;
@synthesize ack = _ack;
@synthesize chunkIndex = _chunkIndex;
@synthesize chunkNum = _chunkNum;
@synthesize length = _length;
@synthesize totalLength = _totalLength;

- (id)init
{
    self = [super initWithName:CHUNK_DIALECT_NAME tracker:@"none"];
    if (self)
    {
        _ack = NO;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithTracker:(NSString *)tracker
{
    if (self = [super initWithName:CHUNK_DIALECT_NAME tracker:tracker])
    {
        _ack = NO;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithSign:(NSString *)sign totalLength:(long)totalLength chunkIndex:(int)chunkIndex
          chunkNum:(int)chunkNum data:(NSData *)data length:(int)length
{
    if (self = [super initWithName:CHUNK_DIALECT_NAME tracker:@"none"])
    {
        _ack = NO;
        _sign = sign;
        _totalLength = totalLength;
        _chunkIndex = chunkIndex;
        _chunkNum = chunkNum;
        _data = data;
        _length = length;
    }
 
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithTracker:(NSString *)tracker Sign:(NSString *)sign totalLength:(long)totalLength
           chunkIndex:(int)chunkIndex chunkNum:(int)chunkNum data:(NSData *)data length:(int)length
{
    if (self = [super initWithName:CHUNK_DIALECT_NAME tracker:tracker])
    {
        _ack = NO;
        _sign = sign;
        _totalLength = totalLength;
        _chunkIndex = chunkIndex;
        _chunkNum = chunkNum;
        _data = data;
        _length = length;
    }
    
    return self;
}
//------------------------------------------------------------------------------

- (void)setAckWithSign:(NSString *)sign chunkIndex:(int)chunkIndex chunkNum:(int)chunkNum
{
    _sign = sign;
    _chunkIndex = chunkIndex;
    _chunkNum = chunkNum;
    _ack = YES;
}
//------------------------------------------------------------------------------
- (void)fireProgress:(NSString *)target
{
    if (nil != _delegate && [_delegate respondsToSelector:@selector(onProgress:andTraget:)]) {
        [_delegate onProgress:self andTraget:target];
    }
}
//------------------------------------------------------------------------------
- (CCPrimitive *)translate
{
    CCPrimitive *primitive = [super translate];
    CCPredicateStuff *ackStuff = [CCPredicateStuff stuffWithBool:_ack];
    [primitive commit:ackStuff];
    
    if (_ack)
    {
        [primitive commit:[CCSubjectStuff stuffWithString:_sign]];
        [primitive commit:[CCSubjectStuff stuffWithInt:_chunkIndex]];
        [primitive commit:[CCSubjectStuff stuffWithInt:_chunkNum]];
        
    }
    else
    {
        [primitive commit:[CCSubjectStuff stuffWithString:_sign]];
        [primitive commit:[CCSubjectStuff stuffWithInt:_chunkIndex]];
        [primitive commit:[CCSubjectStuff stuffWithInt:_chunkNum]];
        [primitive commit:[CCSubjectStuff stuffWithString:[_data base64EncodedStringWithOptions:0]]];
        [primitive commit:[CCSubjectStuff stuffWithInt:_length]];
        [primitive commit:[CCSubjectStuff stuffWithLong:_totalLength]];
    }
    return primitive;
}
//------------------------------------------------------------------------------
- (void)build:(CCPrimitive *)primitive
{
    NSMutableArray *predicates = primitive.predicates;
    BOOL ack = [(CCPredicateStuff *)[predicates objectAtIndex:0] getValueAsBoolean];
    _ack = ack;
    if (_ack)
    {
        NSMutableArray *list = primitive.subjects;
        _sign = [(CCSubjectStuff *)[list objectAtIndex:0] getValueAsString];
        _chunkIndex = [(CCSubjectStuff *)[list objectAtIndex:1] getValueAsInt];
        _chunkNum = [(CCSubjectStuff *)[list objectAtIndex:2] getValueAsInt];
    }
    else
    {
        NSMutableArray *list = primitive.subjects;
        _sign = [(CCSubjectStuff *)[list objectAtIndex:0] getValueAsString];
        _chunkIndex = [(CCSubjectStuff *)[list objectAtIndex:1] getValueAsInt];
        _chunkNum = [(CCSubjectStuff *)[list objectAtIndex:2] getValueAsInt];
        NSString *base64String = [(CCSubjectStuff *)[list objectAtIndex:3] getValueAsString];
        NSData *decodedData = [[NSData alloc]initWithBase64EncodedString:base64String options:0];
        _data  =  decodedData;
        _length = [(CCSubjectStuff *)[list objectAtIndex:4] getValueAsInt];
        _totalLength = [(CCSubjectStuff *)[list objectAtIndex:5] getValueAsLong];
        
        if (nil != _data)
        {
            CCChunkDialectFactory *factory = (CCChunkDialectFactory *)[[CCDialectEnumerator sharedSingleton]getFactory:CHUNK_DIALECT_NAME];
            [factory write:self];
        }
    }
}

//------------------------------------------------------------------------------
- (BOOL)hasCompleted
{
    CCChunkDialectFactory *factory = (CCChunkDialectFactory *)[[CCDialectEnumerator sharedSingleton]getFactory:CHUNK_DIALECT_NAME];
    return [factory checkCompleted: self.ownerTag withSign:_sign];
}

//------------------------------------------------------------------------------
- (BOOL)isLast
{
    return (_chunkIndex + 1 == _chunkNum) && !_ack;
}

//------------------------------------------------------------------------------
- (int)read:(int)index andData:(NSData *)buffer
{
    CCChunkDialectFactory *factory = (CCChunkDialectFactory *)[[CCDialectEnumerator sharedSingleton]getFactory:CHUNK_DIALECT_NAME];
    return [factory read:self.ownerTag withSign:_sign withIndex:index withData:buffer];
}

//------------------------------------------------------------------------------
- (int)read:(NSData *)buffer
{
    if (_readIndex >= _chunkNum)
    {
        return -1;
    }
    
    CCChunkDialectFactory *factory = (CCChunkDialectFactory *)[[CCDialectEnumerator sharedSingleton]getFactory:CHUNK_DIALECT_NAME];
    int length = [factory read:self.ownerTag withSign:_sign withIndex:_readIndex withData:buffer];
    ++ _readIndex;
    return length;
}

//------------------------------------------------------------------------------
- (void)resetRead
{
    _readIndex = 0;
}

//------------------------------------------------------------------------------
- (void)clearAll
{
    CCChunkDialectFactory *factory = (CCChunkDialectFactory *)[[CCDialectEnumerator sharedSingleton]getFactory:CHUNK_DIALECT_NAME];
    [factory clear:self.ownerTag withSign:_sign];
}


@end
