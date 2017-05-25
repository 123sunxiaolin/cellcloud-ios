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

#define TOKEN_OPEN_BRACKET    '['
#define TOKEN_CLOSE_BRACKET   ']'
#define TOKEN_OPEN_BRACE      '{'
#define TOKEN_CLOSE_BRACE     '}'
#define TOKEN_OPERATE_ASSIGN  '='
#define TOKEN_OPERATE_DECLARE ':'
#define TOKEN_AT              '@'
#define TOKEN_ESCAPE          '\\'

#define TOKEN_OPEN_BRACKET_STR    "["
#define TOKEN_CLOSE_BRACKET_STR   "]"
#define TOKEN_OPEN_BRACE_STR      "{"
#define TOKEN_CLOSE_BRACE_STR     "}"
#define TOKEN_OPERATE_ASSIGN_STR  "="
#define TOKEN_OPERATE_DECLARE_STR ":"
#define TOKEN_AT_STR              "@"
#define TOKEN_ESCAPE_STR          "\\"

#define TOKEN_AT_NSSTRING @"@"

#define STUFFTYPE_SUBJECT     "sub"
#define STUFFTYPE_PREDICATE   "pre"
#define STUFFTYPE_OBJECTIVE   "obj"
#define STUFFTYPE_ADVERBIAL   "adv"
#define STUFFTYPE_ATTRIBUTIVE "att"
#define STUFFTYPE_COMPLEMENT  "com"

#define STUFFTYPE_SUBJECT_NSSTRING     @"sub"
#define STUFFTYPE_PREDICATE_NSSTRING   @"pre"
#define STUFFTYPE_OBJECTIVE_NSSTRING   @"obj"
#define STUFFTYPE_ADVERBIAL_NSSTRING   @"adv"
#define STUFFTYPE_ATTRIBUTIVE_NSSTRING @"att"
#define STUFFTYPE_COMPLEMENT_NSSTRING  @"com"

#define LITERALBASE_STRING   "string"
#define LITERALBASE_STRING_M "s"
#define LITERALBASE_INT      "int"
#define LITERALBASE_INT_M    "i"
#define LITERALBASE_UINT     "uint"
#define LITERALBASE_UINT_M   "ui"
#define LITERALBASE_LONG     "long"
#define LITERALBASE_LONG_M   "l"
#define LITERALBASE_ULONG    "ulong"
#define LITERALBASE_ULONG_M  "ul"
#define LITERALBASE_FLOAT    "float"
#define LITERALBASE_FLOAT_M  "f"
#define LITERALBASE_DOUBLE   "double"
#define LITERALBASE_DOUBLE_M "d"
#define LITERALBASE_BOOL     "bool"
#define LITERALBASE_BOOL_M   "b"
#define LITERALBASE_JSON     "json"
#define LITERALBASE_JSON_M   "j"
#define LITERALBASE_BIN      "bin"
#define LITERALBASE_BIN_M    "bn"
#define LITERALBASE_XML      "xml"
#define LITERALBASE_XML_M    "x"

#define LITERALBASE_STRING_BYTE  's'
#define LITERALBASE_INT_BYTE     'i'
#define LITERALBASE_UINT_BYTE_0  'u'
#define LITERALBASE_UINT_BYTE_1  'i'
#define LITERALBASE_LONG_BYTE    'l'
#define LITERALBASE_ULONG_BYTE_0 'u'
#define LITERALBASE_ULONG_BYTE_1 'l'
#define LITERALBASE_FLOAT_BYTE   'f'
#define LITERALBASE_DOUBLE_BYTE  'd'
#define LITERALBASE_BOOL_BYTE    'b'
#define LITERALBASE_JSON_BYTE    'j'
#define LITERALBASE_BIN_BYTE_0   'b'
#define LITERALBASE_BIN_BYTE_1   'n'
#define LITERALBASE_XML_BYTE     'x'

#define LITERALBASE_STRING_NSSTRING   @"string"
#define LITERALBASE_INT_NSSTRING      @"int"
#define LITERALBASE_UINT_NSSTRING     @"uint"
#define LITERALBASE_LONG_NSSTRING     @"long"
#define LITERALBASE_ULONG_NSSTRING    @"ulong"
#define LITERALBASE_FLOAT_NSSTRING    @"float"
#define LITERALBASE_DOUBLE_NSSTRING   @"double"
#define LITERALBASE_BOOL_NSSTRING     @"bool"
#define LITERALBASE_JSON_NSSTRING     @"json"
#define LITERALBASE_BIN_NSSTRING      @"bin"
#define LITERALBASE_XML_NSSTRING      @"xml"

#define PARSE_PHASE_UNKNOWN 0
#define PARSE_PHASE_VERSION 1
#define PARSE_PHASE_TYPE    2
#define PARSE_PHASE_LITERAL 3
#define PARSE_PHASE_VALUE   4
#define PARSE_PHASE_STUFF   5
#define PARSE_PHASE_DIALECT 6

#define BLOCK 65536

@interface CCPrimitiveSerializer ()

/** 修正数据。 */
+ (NSData *)reviseValue:(NSData *)input;

/** 解析类型。 */
+ (int)parseStuffType:(char *)output stuffType:(CCStuffType)stuffType;

/** 解析字面义。 */
+ (int)parseLiteralBase:(char *)output literal:(CCLiteralBase)literal v3:(BOOL)v3;

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
    [00100]{sub=cloud:string}{pre=2013:int}[ActionDialect@Ambrose]
    [03]{sub=cloud:s}{pre=2013:i}[ActionDialect@Ambrose]
    */

    NSMutableData *stream = [[NSMutableData alloc] init];
    
    // 版本
    BOOL v3 = (primitive.version == 3);
    char version[8] = {0x0};
    if (v3)
    {
        sprintf(version, "%c0%d%c", TOKEN_OPEN_BRACKET, 3, TOKEN_CLOSE_BRACKET);
        [stream appendBytes:version length:4];
    }
    else
    {
        sprintf(version, "%c%03d%02d%c", TOKEN_OPEN_BRACKET, 2, 0, TOKEN_CLOSE_BRACKET);
        [stream appendBytes:version length:7];
    }

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

    char type[4] = {0x0};
    char literal[8] = {0x0};
    int length = 0;
    
    for (NSMutableArray *stuffList in list)
    {
        for (CCStuff *stuff in stuffList)
        {
            [stream appendBytes:TOKEN_OPEN_BRACE_STR length:1];

            length = [CCPrimitiveSerializer parseStuffType:type stuffType:stuff.type];
            [stream appendBytes:type length:length];

            [stream appendBytes:TOKEN_OPERATE_ASSIGN_STR length:1];

            NSData *value = [CCPrimitiveSerializer reviseValue:[stuff getValue]];
            [stream appendData:value];

            [stream appendBytes:TOKEN_OPERATE_DECLARE_STR length:1];

            length = [CCPrimitiveSerializer parseLiteralBase:literal literal:stuff.literalBase v3:v3];
            [stream appendBytes:literal length:length];

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
+ (CCPrimitive *)deserialize:(NSData *)dataStream andTag:(NSString *)tag
{
    /*
    原语序列化格式：
    [version]{sutff}...{stuff}[dialect@tracker]
    示例：
    [00100]{sub=cloud:string}{pre=2013:int}[ActionDialect@Ambrose]
    [03]{sub=cloud:s}{pre=2013:i}[ActionDialect@Ambrose]
    */

    CCPrimitive *primitive = [[CCPrimitive alloc] initWithTag:tag];

    const NSUInteger srcSize = dataStream.length;
    char *src = malloc(srcSize);
    [dataStream getBytes:src length:srcSize];
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
            if (byte == TOKEN_ESCAPE)
            {
                // 读取下一个字符
                char next = src[srcCursor];
                if (next == TOKEN_OPEN_BRACE
                    || next == TOKEN_CLOSE_BRACE
                    || next == TOKEN_OPERATE_ASSIGN
                    || next == TOKEN_OPERATE_DECLARE
                    || next == TOKEN_ESCAPE)
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
                
        case PARSE_PHASE_STUFF:
            if (byte == TOKEN_OPEN_BRACE)
            {
                // 进入解析语素阶段
                phase = PARSE_PHASE_TYPE;
            }
            break;
                
        case PARSE_PHASE_VERSION:
            if (byte == TOKEN_CLOSE_BRACKET)
            {
                // 解析版本结束
                if (bufCursor > 2)
                {
                    primitive.version = 2;
                }
                
                memset(buf, 0x0, bufSize);
                bufCursor = 0;

                phase = PARSE_PHASE_STUFF;
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
            else if (byte == TOKEN_OPEN_BRACKET)
            {
                phase = PARSE_PHASE_VERSION;
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

    for (NSUInteger i = 0, size = input.length; i < size; ++i)
    {
        char c = data[i];

        // 判断并进行转义
        if (c == TOKEN_OPEN_BRACE
            || c == TOKEN_CLOSE_BRACE
            || c == TOKEN_OPERATE_ASSIGN
            || c == TOKEN_OPERATE_DECLARE
            || c == TOKEN_ESCAPE)
        {
            dest[destCoursor] = TOKEN_ESCAPE;
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
+ (int)parseStuffType:(char *)output stuffType:(CCStuffType)stuffType
{
    int length = 0;

    switch (stuffType)
    {
    case CCStuffTypeSubject:
        length = strlen(STUFFTYPE_SUBJECT);
        memcpy(output, STUFFTYPE_SUBJECT, length);
        break;
    case CCStuffTypePredicate:
        length = strlen(STUFFTYPE_PREDICATE);
        memcpy(output, STUFFTYPE_PREDICATE, length);
        break;
    case CCStuffTypeObjective:
        length = strlen(STUFFTYPE_OBJECTIVE);
        memcpy(output, STUFFTYPE_OBJECTIVE, length);
        break;
    case CCStuffTypeAttributive:
        length = strlen(STUFFTYPE_ATTRIBUTIVE);
        memcpy(output, STUFFTYPE_ATTRIBUTIVE, length);
        break;
    case CCStuffTypeAdverbial:
        length = strlen(STUFFTYPE_ADVERBIAL);
        memcpy(output, STUFFTYPE_ADVERBIAL, length);
        break;
    case CCStuffTypeComplement:
        length = strlen(STUFFTYPE_COMPLEMENT);
        memcpy(output, STUFFTYPE_COMPLEMENT, length);
        break;
    default:
        break;
    }
    
    return length;
}
//------------------------------------------------------------------------------
+ (int)parseLiteralBase:(char *)output literal:(CCLiteralBase)literalBase v3:(BOOL)v3
{
    int length = 0;
    switch (literalBase)
    {
    case CCLiteralBaseString:
        if (v3)
        {
            length = strlen(LITERALBASE_STRING_M);
            memcpy(output, LITERALBASE_STRING_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_STRING);
            memcpy(output, LITERALBASE_STRING, length);
        }
        break;
    case CCLiteralBaseJSON:
        if (v3)
        {
            length = strlen(LITERALBASE_JSON_M);
            memcpy(output, LITERALBASE_JSON_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_JSON);
            memcpy(output, LITERALBASE_JSON, length);
        }
        break;
    case CCLiteralBaseInt:
        if (v3)
        {
            length = strlen(LITERALBASE_INT_M);
            memcpy(output, LITERALBASE_INT_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_INT);
            memcpy(output, LITERALBASE_INT, length);
        }
        break;
    case CCLiteralBaseUInt:
        if (v3)
        {
            length = strlen(LITERALBASE_UINT_M);
            memcpy(output, LITERALBASE_UINT_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_UINT);
            memcpy(output, LITERALBASE_UINT, length);
        }
        break;
    case CCLiteralBaseLong:
        if (v3)
        {
            length = strlen(LITERALBASE_LONG_M);
            memcpy(output, LITERALBASE_LONG_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_LONG);
            memcpy(output, LITERALBASE_LONG, length);
        }
        break;
    case CCLiteralBaseULong:
        if (v3)
        {
            length = strlen(LITERALBASE_ULONG_M);
            memcpy(output, LITERALBASE_ULONG_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_ULONG);
            memcpy(output, LITERALBASE_ULONG, length);
        }
        break;
    case CCLiteralBaseBool:
        if (v3)
        {
            length = strlen(LITERALBASE_BOOL_M);
            memcpy(output, LITERALBASE_BOOL_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_BOOL);
            memcpy(output, LITERALBASE_BOOL, length);
        }
        break;
    case CCLiteralBaseBin:
        if (v3)
        {
            length = strlen(LITERALBASE_BIN_M);
            memcpy(output, LITERALBASE_BIN_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_BIN);
            memcpy(output, LITERALBASE_BIN, length);
        }
        break;
    case CCLiteralBaseFloat:
        if (v3)
        {
            length = strlen(LITERALBASE_FLOAT_M);
            memcpy(output, LITERALBASE_FLOAT_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_FLOAT);
            memcpy(output, LITERALBASE_FLOAT, length);
        }
        break;
    case CCLiteralBaseDouble:
        if (v3)
        {
            length = strlen(LITERALBASE_DOUBLE_M);
            memcpy(output, LITERALBASE_DOUBLE_M, length);
        }
        else
        {
            length = strlen(LITERALBASE_DOUBLE);
            memcpy(output, LITERALBASE_DOUBLE, length);
        }
        break;
    default:
        break;
    }
    return length;
}
//------------------------------------------------------------------------------
+ (void)injectStuff:(CCPrimitive *)primitive type:(NSData *)type value:(NSData *)value literal:(NSData *)literal
{
    CCLiteralBase literalBase = CCLiteralBaseBin;

    if (literal.length <= 2)
    {
        char * lbbuf = (char *) literal.bytes;
        
        if (lbbuf[0] == LITERALBASE_STRING_BYTE)
            literalBase = CCLiteralBaseString;
        else if (lbbuf[0] == LITERALBASE_JSON_BYTE)
            literalBase = CCLiteralBaseJSON;
        else if (literal.length == 2 && lbbuf[0] == LITERALBASE_BIN_BYTE_0 && lbbuf[1] == LITERALBASE_BIN_BYTE_1)
            literalBase = CCLiteralBaseBin;
        else if (lbbuf[0] == LITERALBASE_INT_BYTE)
            literalBase = CCLiteralBaseInt;
        else if (lbbuf[0] == LITERALBASE_LONG_BYTE)
            literalBase = CCLiteralBaseLong;
        else if (lbbuf[0] == LITERALBASE_BOOL_BYTE)
            literalBase = CCLiteralBaseBool;
        else if (lbbuf[0] == LITERALBASE_FLOAT_BYTE)
            literalBase = CCLiteralBaseFloat;
        else if (lbbuf[0] == LITERALBASE_DOUBLE_BYTE)
            literalBase = CCLiteralBaseDouble;
        else if (literal.length == 2 && lbbuf[0] == LITERALBASE_UINT_BYTE_0 && lbbuf[1] == LITERALBASE_UINT_BYTE_1)
            literalBase = CCLiteralBaseUInt;
        else if (literal.length == 2 && lbbuf[0] == LITERALBASE_ULONG_BYTE_0 && lbbuf[1] == LITERALBASE_ULONG_BYTE_1)
            literalBase = CCLiteralBaseULong;
        else
            [CCLogger e:@"Error primitive stuff literal base (v3)"];
    }
    else
    {
        NSString *szLiteral = [[NSString alloc] initWithData:literal encoding:NSUTF8StringEncoding];
        if ([szLiteral isEqualToString:LITERALBASE_STRING_NSSTRING])
            literalBase = CCLiteralBaseString;
        else if ([szLiteral isEqualToString:LITERALBASE_JSON_NSSTRING])
            literalBase = CCLiteralBaseJSON;
        else if ([szLiteral isEqualToString:LITERALBASE_BIN_NSSTRING])
            literalBase = CCLiteralBaseBin;
        else if ([szLiteral isEqualToString:LITERALBASE_INT_NSSTRING])
            literalBase = CCLiteralBaseInt;
        else if ([szLiteral isEqualToString:LITERALBASE_LONG_NSSTRING])
            literalBase = CCLiteralBaseLong;
        else if ([szLiteral isEqualToString:LITERALBASE_BOOL_NSSTRING])
            literalBase = CCLiteralBaseBool;
        else if ([szLiteral isEqualToString:LITERALBASE_FLOAT_NSSTRING])
            literalBase = CCLiteralBaseFloat;
        else if ([szLiteral isEqualToString:LITERALBASE_DOUBLE_NSSTRING])
            literalBase = CCLiteralBaseDouble;
        else if ([szLiteral isEqualToString:LITERALBASE_UINT_NSSTRING])
            literalBase = CCLiteralBaseUInt;
        else if ([szLiteral isEqualToString:LITERALBASE_ULONG_NSSTRING])
            literalBase = CCLiteralBaseULong;
        else
            [CCLogger e:@"Error primitive stuff literal base"];
    }

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
    [dialect construct:primitive];
}


@end
