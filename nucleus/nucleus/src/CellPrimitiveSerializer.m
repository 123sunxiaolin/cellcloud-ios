/*
 ------------------------------------------------------------------------------
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
 ------------------------------------------------------------------------------
 */

#import "CellPrimitiveSerializer.h"
#import "CellPrimitive.h"
#import "CellLiteralBase.h"
#import "CellSubjectStuff.h"
#import "CellPredicateStuff.h"
#import "CellObjectiveStuff.h"
#import "CellAttributiveStuff.h"
#import "CellAdverbialStuff.h"
#import "CellComplementStuff.h"
#import "CellDialect.h"
#import "CellDialectEnumerator.h"
#import "CellDialectFactory.h"
#import "CellLogger.h"

#define PS_MAJOR 1
#define PS_MINOR 0

#define TOKEN_OPEN_BRACKET '['
#define TOKEN_CLOSE_BRACKET ']'
#define TOKEN_OPEN_BRACE '{'
#define TOKEN_CLOSE_BRACE '}'
#define TOKEN_POINT '.'
#define TOKEN_OPERATE_ASSIGN '='
#define TOKEN_OPERATE_DECLARE ':'
#define TOKEN_AT '@'

#define TOKEN_OPEN_BRACKET_STR "["
#define TOKEN_CLOSE_BRACKET_STR "]"
#define TOKEN_OPEN_BRACE_STR "{"
#define TOKEN_CLOSE_BRACE_STR "}"
#define TOKEN_OPERATE_ASSIGN_STR "="
#define TOKEN_OPERATE_DECLARE_STR ":"
#define TOKEN_AT_STR "@"

#define TOKEN_AT_NSSTRING @"@"

#define STUFFTYPE_SUBJECT "sub"
#define STUFFTYPE_PREDICATE "pre"
#define STUFFTYPE_OBJECTIVE "obj"
#define STUFFTYPE_ADVERBIAL "adv"
#define STUFFTYPE_ATTRIBUTIVE "att"
#define STUFFTYPE_COMPLEMENT "com"

#define STUFFTYPE_SUBJECT_NSSTRING @"sub"
#define STUFFTYPE_PREDICATE_NSSTRING @"pre"
#define STUFFTYPE_OBJECTIVE_NSSTRING @"obj"
#define STUFFTYPE_ADVERBIAL_NSSTRING @"adv"
#define STUFFTYPE_ATTRIBUTIVE_NSSTRING @"att"
#define STUFFTYPE_COMPLEMENT_NSSTRING @"com"

#define LITERALBASE_STRING "string"
#define LITERALBASE_INT "int"
#define LITERALBASE_LONG "long"
#define LITERALBASE_BOOL "bool"

#define LITERALBASE_STRING_NSSTRING @"string"
#define LITERALBASE_INT_NSSTRING @"int"
#define LITERALBASE_LONG_NSSTRING @"long"
#define LITERALBASE_BOOL_NSSTRING @"bool"

#define PARSE_PHASE_UNKNOWN 0
#define PARSE_PHASE_VERSION 1
#define PARSE_PHASE_TYPE 2
#define PARSE_PHASE_LITERAL 3
#define PARSE_PHASE_VALUE 4
#define PARSE_PHASE_STUFF 5
#define PARSE_PHASE_DIALECT 6

#define BLOCK 65536

@interface CCPrimitiveSerializer ()

/** 修正数据。 */
+ (NSData *)reviseValue:(NSData *)input;

/** 解析类型。 */
+ (NSData *)parseStuffType:(CCStuffType)stuffType;

/** 解析字面义。 */
+ (NSData *)parseLiteralBase:(CCLiteralBase)literal;

/** 将数据加入原语。 */
+ (void)injectStuff:(CCPrimitive *)primitive type:(NSData *)type value:(NSData *)value literal:(NSData *)literal;

/** 反序列化方言。 */
+ (void)deserializeDialect:(CCPrimitive *)primitive dialectStr:(NSString *)dialectStr;

@end

@implementation CCPrimitiveSerializer

//------------------------------------------------------------------------------
+ (NSData *)serialize:(CCPrimitive *)primitive
{
    /*
    原语序列化格式：
    [version]{sutff}...{stuff}[dialect@tracker]
    示例：
    [01.00]{sub=cloud:string}{pre=add:string}[FileReader@Lynx]
    */
    
    NSMutableData *stream = [[NSMutableData alloc] init];
    
    // 版本
    char version[8] = {0x0};
    sprintf(version, "%c%02d%c%02d%c", TOKEN_OPEN_BRACKET,
        PS_MAJOR, TOKEN_POINT, PS_MINOR, TOKEN_CLOSE_BRACKET);
    [stream appendBytes:version length:7];

    // 序列化各语素
    NSMutableArray *stuffs = nil;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    stuffs = primitive.subjects;
    if (nil != stuffs)
    {
        [list addObject:stuffs];
    }
    stuffs = primitive.predicates;
    if (nil != stuffs)
    {
        [list addObject:stuffs];
    }
    stuffs = primitive.objectives;
    if (nil != stuffs)
    {
        [list addObject:stuffs];
    }
    stuffs = primitive.attributives;
    if (nil != stuffs)
    {
        [list addObject:stuffs];
    }
    stuffs = primitive.adverbials;
    if (nil != stuffs)
    {
        [list addObject:stuffs];
    }
    stuffs = primitive.complements;
    if (nil != stuffs)
    {
        [list addObject:stuffs];
    }

    for (NSMutableArray *stuffList in list)
    {
        for (CCStuff *stuff in stuffList)
        {
            [stream appendBytes:TOKEN_OPEN_BRACE_STR length:1];
            [stream appendData:[CCPrimitiveSerializer parseStuffType:stuff.type]];
            [stream appendBytes:TOKEN_OPERATE_ASSIGN_STR length:1];

            NSData *vd = [[stuff getValueAsString] dataUsingEncoding:NSUTF8StringEncoding];
            NSData *rvd = [CCPrimitiveSerializer reviseValue:vd];
            [stream appendData:rvd];

            [stream appendBytes:TOKEN_OPERATE_DECLARE_STR length:1];
            [stream appendData:[CCPrimitiveSerializer parseLiteralBase:stuff.literalBase]];
            [stream appendBytes:TOKEN_CLOSE_BRACE_STR length:1];
        }
    }
    
    // 序列化方言
    CCDialect* dialect = primitive.dialect;
    if (nil != dialect)
    {
        [stream appendBytes:TOKEN_OPEN_BRACKET_STR length:1];
        [stream appendData:[dialect.name dataUsingEncoding:NSUTF8StringEncoding]];
        [stream appendBytes:TOKEN_AT_STR length:1];
        [stream appendData:[dialect.tracker dataUsingEncoding:NSUTF8StringEncoding]];
        [stream appendBytes:TOKEN_CLOSE_BRACKET_STR length:1];
    }

    return [NSData dataWithData:stream];
}
//------------------------------------------------------------------------------
+ (CCPrimitive *)deserialize:(NSData *)dataStream
{
    /*
    原语序列化格式：
    [version]{sutff}...{stuff}[dialect@tracker]
    示例：
    [01.00]{sub=cloud:string}{pre=add:string}[FileReader@Lynx]
    */

    CCPrimitive *primitive = [[CCPrimitive alloc] init];

    // FIXME 跳过版本
    NSData *pridata = [dataStream subdataWithRange:NSMakeRange(7, dataStream.length - 7)];

    const int srcSize = pridata.length;
    char *src = malloc(srcSize);
    [pridata getBytes:src length:srcSize];
    int srcCursor = 0;

    const int bufSize = BLOCK;
    char *buf = malloc(bufSize);
    int bufCursor = 0;

    NSData *type = nil;
    NSData *value = nil;
    NSData *literal = nil;

    int phase = PARSE_PHASE_UNKNOWN;
    char byte;
    while (srcCursor < srcSize)
    {
        byte = src[srcCursor];
        ++srcCursor;

        switch (phase)
        {
        case PARSE_PHASE_VALUE:
            // 判断转义
            if (byte == '\\')
            {
                // 读取下一个字符
                char next = src[srcCursor];
                if (next == TOKEN_OPEN_BRACE
                    || next == TOKEN_CLOSE_BRACE
                    || next == TOKEN_OPERATE_ASSIGN
                    || next == TOKEN_OPERATE_DECLARE)
                {
                    buf[bufCursor] = next;
                    ++bufCursor;
                    ++srcCursor;
                }
                else
                {
                    buf[bufCursor] = byte;
                    ++bufCursor;
                }

                continue;
            }

            if (byte == TOKEN_OPERATE_DECLARE)
            {
                // 数值解析结束
                if (nil != value)
                    value = nil;
                value = [NSData dataWithBytes:buf length:bufCursor];
                
                memset(buf, 0x0, bufSize);
                bufCursor = 0;
                
                phase = PARSE_PHASE_LITERAL;
                continue;
            }

            buf[bufCursor] = byte;
            ++bufCursor;
            break;
        case PARSE_PHASE_TYPE:
            if (byte == TOKEN_OPERATE_ASSIGN)
            {
                // 类型读取完毕
                if (nil != type)
                    type = nil;
                type = [NSData dataWithBytes:buf length:bufCursor];

                memset(buf, 0x0, bufSize);
                bufCursor = 0;

                phase = PARSE_PHASE_VALUE;
                continue;
            }
            // 写入类型
            buf[bufCursor] = byte;
            ++bufCursor;
            break;
        case PARSE_PHASE_LITERAL:
            if (byte == TOKEN_CLOSE_BRACE)
            {
                // 字面义结束
                if (nil != literal)
                    literal = nil;
                literal = [NSData dataWithBytes:buf length:bufCursor];
                
                // 提交语素
                [CCPrimitiveSerializer injectStuff:primitive type:type value:value literal:literal];
                
                memset(buf, 0x0, bufSize);
                bufCursor = 0;
                
                phase = PARSE_PHASE_DIALECT;
                continue;
            }
            // 记录数据
            buf[bufCursor] = byte;
            ++bufCursor;
            break;
        case PARSE_PHASE_DIALECT:
            if (byte == TOKEN_OPEN_BRACE)
            {
                // 进行语素类型解析
                phase = PARSE_PHASE_TYPE;
            }
            else if (byte == TOKEN_OPEN_BRACKET)
            {
                // 开始解析方言
                memset(buf, 0x0, bufSize);
                bufCursor = 0;
            }
            else if (byte == TOKEN_CLOSE_BRACKET)
            {
                // 结束解析方言
                NSString *dialectStr = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                [CCPrimitiveSerializer deserializeDialect:primitive dialectStr:dialectStr];
            }
            else
            {
                // 记录数据
                buf[bufCursor] = byte;
                ++bufCursor;
            }
            break;
        default:
            if (byte == TOKEN_OPEN_BRACE)
            {
                phase = PARSE_PHASE_TYPE;
                memset(buf, 0x0, bufSize);
                bufCursor = 0;
            }
            break;
        }
    }

    free(buf);
    free(src);
    
    return primitive;
}
//------------------------------------------------------------------------------
+ (NSData *)reviseValue:(NSData *)input
{
    char *data = malloc(input.length);
    [input getBytes:data length:input.length];

    char *dest = malloc(input.length + input.length);
    memset(dest, 0x0, input.length + input.length);
    int destCoursor = 0;

    for (int i = 0, size = input.length; i < size; ++i)
    {
        char c = data[i];

        // 判断并进行转义
        if (c == TOKEN_OPEN_BRACE
            || c == TOKEN_CLOSE_BRACE
            || c == TOKEN_OPERATE_ASSIGN
            || c == TOKEN_OPERATE_DECLARE)
        {
            dest[destCoursor] = '\\';
            ++destCoursor;
        }

        dest[destCoursor] = c;
        ++destCoursor;
    }
    
    NSData *ret = [NSData dataWithBytes:dest length:destCoursor];
    
    free(data);
    free(dest);

    return ret;
}
//------------------------------------------------------------------------------
+ (NSData *)parseStuffType:(CCStuffType)stuffType
{
    NSData *ret;
    switch (stuffType)
    {
    case CCStuffTypeSubject:
        ret = [NSData dataWithBytes:STUFFTYPE_SUBJECT length:strlen(STUFFTYPE_SUBJECT)];
        break;
    case CCStuffTypePredicate:
        ret = [NSData dataWithBytes:STUFFTYPE_PREDICATE length:strlen(STUFFTYPE_PREDICATE)];
        break;
    case CCStuffTypeObjective:
        ret = [NSData dataWithBytes:STUFFTYPE_OBJECTIVE length:strlen(STUFFTYPE_OBJECTIVE)];
        break;
    case CCStuffTypeAttributive:
        ret = [NSData dataWithBytes:STUFFTYPE_ATTRIBUTIVE length:strlen(STUFFTYPE_ATTRIBUTIVE)];
        break;
    case CCStuffTypeAdverbial:
        ret = [NSData dataWithBytes:STUFFTYPE_ADVERBIAL length:strlen(STUFFTYPE_ADVERBIAL)];
        break;
    case CCStuffTypeComplement:
        ret = [NSData dataWithBytes:STUFFTYPE_COMPLEMENT length:strlen(STUFFTYPE_COMPLEMENT)];
        break;
    default:
        break;
    }
    
    return ret;
}
//------------------------------------------------------------------------------
+ (NSData *)parseLiteralBase:(CCLiteralBase)literalBase
{
    NSData *ret;
    switch (literalBase)
    {
    case CCLiteralBaseString:
        ret = [NSData dataWithBytes:LITERALBASE_STRING length:strlen(LITERALBASE_STRING)];
        break;
    case CCLiteralBaseInt:
        ret = [NSData dataWithBytes:LITERALBASE_INT length:strlen(LITERALBASE_INT)];
        break;
    case CCLiteralBaseLong:
        ret = [NSData dataWithBytes:LITERALBASE_LONG length:strlen(LITERALBASE_LONG)];
        break;
    case CCLiteralBaseBool:
        ret = [NSData dataWithBytes:LITERALBASE_BOOL length:strlen(LITERALBASE_BOOL)];
        break;
    default:
        break;
    }
    return ret;
}
//------------------------------------------------------------------------------
+ (void)injectStuff:(CCPrimitive *)primitive type:(NSData *)type value:(NSData *)value literal:(NSData *)literal
{
    CCLiteralBase literalBase = CCLiteralBaseString;
    NSString *szLiteral = [[NSString alloc] initWithData:literal encoding:NSUTF8StringEncoding];
    if ([szLiteral isEqualToString:LITERALBASE_STRING_NSSTRING])
        literalBase = CCLiteralBaseString;
    else if ([szLiteral isEqualToString:LITERALBASE_INT_NSSTRING])
        literalBase = CCLiteralBaseInt;
    else if ([szLiteral isEqualToString:LITERALBASE_LONG_NSSTRING])
        literalBase = CCLiteralBaseLong;
    else if ([szLiteral isEqualToString:LITERALBASE_BOOL_NSSTRING])
        literalBase = CCLiteralBaseBool;
    else
        [CCLogger e:@"Error primitive stuff literal base"];

    NSString *szType = [[NSString alloc] initWithData:type encoding:NSUTF8StringEncoding];
    if ([szType isEqualToString:STUFFTYPE_SUBJECT_NSSTRING])
    {
        CCSubjectStuff *stuff = [[CCSubjectStuff alloc] initWithData:value literal:literalBase];
        [primitive commit:stuff];
    }
    else if ([szType isEqualToString:STUFFTYPE_PREDICATE_NSSTRING])
    {
        CCPredicateStuff *stuff = [[CCPredicateStuff alloc] initWithData:value literal:literalBase];
        [primitive commit:stuff];
    }
    else if ([szType isEqualToString:STUFFTYPE_OBJECTIVE_NSSTRING])
    {
        CCObjectiveStuff *stuff = [[CCObjectiveStuff alloc] initWithData:value literal:literalBase];
        [primitive commit:stuff];
    }
    else if ([szType isEqualToString:STUFFTYPE_ATTRIBUTIVE_NSSTRING])
    {
        CCAttributiveStuff *stuff = [[CCAttributiveStuff alloc] initWithData:value literal:literalBase];
        [primitive commit:stuff];
    }
    else if ([szType isEqualToString:STUFFTYPE_ADVERBIAL_NSSTRING])
    {
        CCAdverbialStuff *stuff = [[CCAdverbialStuff alloc] initWithData:value literal:literalBase];
        [primitive commit:stuff];
    }
    else if ([szType isEqualToString:STUFFTYPE_COMPLEMENT_NSSTRING])
    {
        CCComplementStuff *stuff = [[CCComplementStuff alloc] initWithData:value literal:literalBase];
        [primitive commit:stuff];
    }
}
//------------------------------------------------------------------------------
+ (void)deserializeDialect:(CCPrimitive *)primitive dialectStr:(NSString *)dialectStr
{
    NSArray *sections = [dialectStr componentsSeparatedByString:TOKEN_AT_NSSTRING];
    if (sections.count != 2)
    {
        return;
    }

    NSString *dialectName = [sections objectAtIndex:0];
    NSString *tracker = [sections objectAtIndex:1];

    // 创建方言
    CCDialect *dialect = [[CCDialectEnumerator sharedSingleton] createDialect:dialectName
                                                                      tracker:tracker];
    if (nil == dialect)
    {
        [CCLogger w:@"Can't create '%@' dialect.", dialectName];
        return;
    }

    // 关联
    [primitive capture:dialect];
    // 分析数据
    [dialect build:primitive];
}


@end
