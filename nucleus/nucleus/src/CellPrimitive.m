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

#import "CellPrimitive.h"
#import "CellSubjectStuff.h"
#import "CellPredicateStuff.h"
#import "CellObjectiveStuff.h"
#import "CellAttributiveStuff.h"
#import "CellAdverbialStuff.h"
#import "CellComplementStuff.h"
#import "CellPrimitiveSerializer.h"
#import "CellDialect.h"

@interface CCPrimitive ()
{
@private
    CCDialect *_dialect;
    NSMutableArray *_subjectList;
    NSMutableArray *_predicateList;
    NSMutableArray *_objectiveList;
    NSMutableArray *_attributiveList;
    NSMutableArray *_adverbialList;
    NSMutableArray *_complementList;
}
@end

@implementation CCPrimitive

@synthesize ownerTag = _ownerTag;
@synthesize celletIdentifier = _celletIdentifier;
@synthesize dialect = _dialect;
@synthesize subjects = _subjectList;
@synthesize predicates = _predicateList;
@synthesize objectives = _objectiveList;
@synthesize attributives = _attributiveList;
@synthesize adverbials = _adverbialList;
@synthesize complements = _complementList;

//------------------------------------------------------------------------------
- (id)initWithTag:(NSString *)tag
{
    if ((self = [super init]))
    {
        self.ownerTag = tag;
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithDialect:(CCDialect *)dialect
{
    if (self = [super init])
    {
        _dialect = dialect;
    }
    
    return self;
}
//------------------------------------------------------------------------------
- (void)commit:(CCStuff *)stuff
{
    switch (stuff.type)
    {
    case CCStuffTypeSubject:
    {
        if (nil == _subjectList)
        {
            _subjectList = [[NSMutableArray alloc] initWithObjects:stuff, nil];
        }
        else
        {
            [_subjectList addObject:(CCSubjectStuff *)stuff];
        }
        break;
    }
    case CCStuffTypePredicate:
    {
        if (nil == _predicateList)
        {
            _predicateList = [[NSMutableArray alloc] initWithObjects:stuff, nil];
        }
        else
        {
            [_predicateList addObject:(CCPredicateStuff *)stuff];
        }
        break;
    }
    case CCStuffTypeObjective:
    {
        if (nil == _objectiveList)
        {
            _objectiveList = [[NSMutableArray alloc] initWithObjects:stuff, nil];
        }
        else
        {
            [_objectiveList addObject:(CCObjectiveStuff *)stuff];
        }
        break;
    }
    case CCStuffTypeAttributive:
    {
        if (nil == _attributiveList)
        {
            _attributiveList = [[NSMutableArray alloc] initWithObjects:stuff, nil];
        }
        else
        {
            [_attributiveList addObject:(CCAttributiveStuff *)stuff];
        }
        break;
    }
    case CCStuffTypeAdverbial:
    {
        if (nil == _adverbialList)
        {
            _adverbialList = [[NSMutableArray alloc] initWithObjects:stuff, nil];
        }
        else
        {
            [_adverbialList addObject:(CCAdverbialStuff *)stuff];
        }
        break;
    }
    case CCStuffTypeComplement:
    {
        if (nil == _complementList)
        {
            _complementList = [[NSMutableArray alloc] initWithObjects:stuff, nil];
        }
        else
        {
            [_complementList addObject:(CCComplementStuff *)stuff];
        }
        break;
    }
    default:
        break;
    }
}
//------------------------------------------------------------------------------
- (void)clearStuff
{
    if (nil != _subjectList)
    {
        [_subjectList removeAllObjects];
    }
    if (nil != _predicateList)
    {
        [_predicateList removeAllObjects];
    }
    if (nil != _objectiveList)
    {
        [_objectiveList removeAllObjects];
    }
    if (nil != _attributiveList)
    {
        [_attributiveList removeAllObjects];
    }
    if (nil != _adverbialList)
    {
        [_adverbialList removeAllObjects];
    }
    if (nil != _complementList)
    {
        [_complementList removeAllObjects];
    }
}
//------------------------------------------------------------------------------
- (void)copyStuff:(CCPrimitive *)dest
{
    if (nil != _subjectList)
    {
        for (CCSubjectStuff *stuff in _subjectList)
        {
            [dest commit:stuff];
        }
    }
    if (nil != _predicateList)
    {
        for (CCPredicateStuff *stuff in _predicateList)
        {
            [dest commit:stuff];
        }
    }
    if (nil != _objectiveList)
    {
        for (CCObjectiveStuff *stuff in _objectiveList)
        {
            [dest commit:stuff];
        }
    }
    if (nil != _attributiveList)
    {
        for (CCAttributiveStuff *stuff in _attributiveList)
        {
            [dest commit:stuff];
        }
    }
    if (nil != _adverbialList)
    {
        for (CCAdverbialStuff *stuff in _adverbialList)
        {
            [dest commit:stuff];
        }
    }
    if (nil != _complementList)
    {
        for (CCComplementStuff *stuff in _complementList)
        {
            [dest commit:stuff];
        }
    }
}
//------------------------------------------------------------------------------
- (void)capture:(CCDialect *)dialect
{
    _dialect = dialect;
    _dialect.ownerTag = self.ownerTag;
    _dialect.celletIdentifier = self.celletIdentifier;
}
//------------------------------------------------------------------------------
- (BOOL)isDialectal
{
    return (nil != _dialect);
}

#pragma mark Override Methods

//------------------------------------------------------------------------------
- (void)setOwnerTag:(NSString *)ownerTag
{
    _ownerTag = ownerTag;
    if (nil != _dialect)
    {
        _dialect.ownerTag = ownerTag;
    }
}
//------------------------------------------------------------------------------
- (void)setCelletIdentifier:(NSString *)celletIdentifier
{
    _celletIdentifier = celletIdentifier;
    if (nil != _dialect)
    {
        _dialect.celletIdentifier = celletIdentifier;
    }
}

#pragma mark Class Methods

//------------------------------------------------------------------------------
+ (NSData *)write:(CCPrimitive *)primitive
{
    return [CCPrimitiveSerializer serialize:primitive];
}
//------------------------------------------------------------------------------
+ (CCPrimitive *)read:(NSData *)stream
{
    return [CCPrimitiveSerializer deserialize:stream];
}

@end
