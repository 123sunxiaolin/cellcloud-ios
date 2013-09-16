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

#import "CellPacket.h"

#define PACK_BUF_SIZE 131072

@implementation CCPacket

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        memset(_tag, 0x0, sizeof(_tag));
        _major = 0;
        _minor = 0;
        _sn = 1;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithTag:(char *)tag sn:(UInt16)sn major:(UInt16)major minor:(UInt16)minor
{
    if ((self = [super init]))
    {
        memset(_tag, 0x0, sizeof(_tag));

        memcpy(_tag, tag, PSL_TAG);
        _major = major;
        _minor = minor;
        _sn = sn;
    }

    return self;
}
//------------------------------------------------------------------------------
- (UInt16)getTag:(char *)tag
{
    memcpy(tag, _tag, PSL_TAG);
    return PSL_TAG;
}
//------------------------------------------------------------------------------
- (BOOL)compareTag:(const char *)other
{
    for (UInt16 i = 0; i < PSL_TAG; ++i)
    {
        if (_tag[i] != other[i])
            return FALSE;
    }
    
    return TRUE;
}
//------------------------------------------------------------------------------
- (void)setVersion:(UInt16)major minor:(UInt16)minor
{
    _major = major;
    _minor = minor;
}
//------------------------------------------------------------------------------
- (void)setSN:(UInt16)sn
{
    _sn = sn;
}
//------------------------------------------------------------------------------
- (void)setBody:(NSData *)data
{
    if (nil != _body)
    {
        _body = nil;
    }

    _body = [[NSData alloc] initWithData:data];
}
//------------------------------------------------------------------------------
- (NSData *)getBody
{
    return _body;
}
//------------------------------------------------------------------------------
- (void)appendSubsegment:(NSData *)data
{
    if (nil == _subsegments)
    {
        _subsegments = [[NSMutableArray alloc] init];
    }

    [_subsegments addObject:data];
}
//------------------------------------------------------------------------------
- (NSData *)getSubsegment:(NSUInteger)index
{
    if (nil == _subsegments || index >= _subsegments.count)
    {
        return nil;
    }

    return [_subsegments objectAtIndex:index];
}


#pragma mark Pack/Unpack Methods

//------------------------------------------------------------------------------
+ (NSData *)pack:(CCPacket *)packet
{
    uint32_t cursor = 0;
    char buf[PACK_BUF_SIZE] = {0x0};

    // Tag
    memcpy(buf, packet->_tag, PSL_TAG);
    cursor += PSL_TAG;

    // Version
    char version[PSL_VERSION + 1] = {0x0};
    sprintf(version, "%02d%02d", packet->_minor, packet->_major);
    memcpy(buf + cursor, version, PSL_VERSION);
    cursor += PSL_VERSION;

    // SN
    char sn[PSL_SN + 1] = {0x0};
    sprintf(sn, "%04d", packet->_sn);
    memcpy(buf + cursor, sn, PSL_SN);
    cursor += PSL_SN;

    uint32_t bodyLength = 0;
    
    // 计算 Body 段长度
    if (nil != packet->_subsegments)
    {
        // 加入子段描述段的长度
        bodyLength += PSL_SUBSEGMENT_NUM;
        bodyLength += (PSL_SUBSEGMENT_LENGTH * packet->_subsegments.count);

        for (NSData *sub in packet->_subsegments)
        {
            bodyLength += sub.length;
        }
    }
    else if (nil != packet->_body)
    {
        bodyLength = packet->_body.length;
    }

    // Body length
    char szLen[PSL_BODY_LENGTH + 1] = {0x0};
    sprintf(szLen, "%08d", bodyLength);
    memcpy(buf + cursor, szLen, PSL_BODY_LENGTH);
    cursor += PSL_BODY_LENGTH;

    if (bodyLength > 0 && cursor + bodyLength <= PACK_BUF_SIZE)
    {
        if (nil != packet->_subsegments)
        {
            // 子段数量
            char szBuf[PSL_SUBSEGMENT_LENGTH + 1] = {0x0};
            sprintf(szBuf, "%04d", packet->_subsegments.count);
            memcpy(buf + cursor, szBuf, PSL_SUBSEGMENT_NUM);
            cursor += PSL_SUBSEGMENT_NUM;

            // 各子段长度
            for (NSData *sub in packet->_subsegments)
            {
                memset(szBuf, 0x0, sizeof(szBuf));
                sprintf(szBuf, "%08d", sub.length);
                memcpy(buf + cursor, szBuf, PSL_SUBSEGMENT_LENGTH);
                cursor += PSL_SUBSEGMENT_LENGTH;
            }

            // 各子段数据
            for (NSData *sub in packet->_subsegments)
            {
                memcpy(buf + cursor, [sub bytes], [sub length]);
                cursor += [sub length];
            }
        }
        else if (nil != packet->_body)
        {
            memcpy(buf + cursor, [packet->_body bytes], packet->_body.length);
            cursor += packet->_body.length;
        }
    }

    NSData *data = [[NSData alloc] initWithBytes:buf length:cursor];
    return data;
}
//------------------------------------------------------------------------------
+ (CCPacket *)unpack:(NSData *)data
{
    // Tag
    NSRange range = NSMakeRange(0, PSL_TAG);
    char tag[PSL_TAG + 1] = {0x0};
    [data getBytes:tag range:range];

    char szBuf[PSL_BODY_LENGTH + 1] = {0x0};

    // Version
    range = NSMakeRange(PSL_TAG, 2);
    [data getBytes:szBuf range:range];
    UInt16 minor = atoi(szBuf);

    memset(szBuf, 0x0, sizeof(szBuf));
    range = NSMakeRange(PSL_TAG + 2, 2);
    [data getBytes:szBuf range:range];
    UInt16 major = atoi(szBuf);

    // SN
    memset(szBuf, 0x0, sizeof(szBuf));
    range = NSMakeRange(PSL_TAG + PSL_VERSION, PSL_SN);
    [data getBytes:szBuf range:range];
    UInt16 sn = atoi(szBuf);
    
    NSUInteger cursor = PSL_TAG + PSL_VERSION + PSL_SN;
    if (cursor > data.length)
    {
        // 数据长度错误
        return nil;
    }

    CCPacket *packet = [[CCPacket alloc] initWithTag:tag
                    sn:sn major:major minor:minor];

    memset(szBuf, 0x0, sizeof(szBuf));
    range = NSMakeRange(cursor, PSL_BODY_LENGTH);
    [data getBytes:szBuf range:range];
    NSUInteger bls = atoi(szBuf);

    cursor += PSL_BODY_LENGTH;

    if (cursor == data.length)
    {
        // Body 长度段后没有数据
        return packet;
    }

    if (cursor + bls > data.length)
    {
        // Body 段长度错误
        return nil;
    }

    // 获取分段数
    memset(szBuf, 0x0, sizeof(szBuf));
    range = NSMakeRange(cursor, PSL_SUBSEGMENT_NUM);
    [data getBytes:szBuf range:range];
    int ssNum = atoi(szBuf);

    if (0 == ssNum)
    {
        // 该数据包未采用分段数据，直接设置 Body 数据
        range = NSMakeRange(cursor, data.length - cursor);
        NSData *bodyData = [data subdataWithRange:range];
        [packet setBody:bodyData];
    }
    else
    {
        // 进行分段解析
        // 更新游标位置
        cursor += PSL_SUBSEGMENT_NUM;
        // 解析子段长度
        NSMutableArray *lenList = [[NSMutableArray alloc] initWithCapacity:ssNum];
        for (int i = 0; i < ssNum; ++i)
        {
            memset(szBuf, 0x0, sizeof(szBuf));
            range = NSMakeRange(cursor, PSL_SUBSEGMENT_LENGTH);
            [data getBytes:szBuf range:range];
            int nLen = atoi(szBuf);
            NSNumber *len = [NSNumber numberWithInt:nLen];
            [lenList addObject:len];
            
            cursor += PSL_SUBSEGMENT_LENGTH;
        }
        // 解析子段数据
        for (int i = 0; i < ssNum; ++i)
        {
            NSNumber *len = [lenList objectAtIndex:i];
            range = NSMakeRange(cursor, [len unsignedIntegerValue]);
            NSData *ssData = [data subdataWithRange:range];
            [packet appendSubsegment:ssData];
            cursor += [len unsignedIntValue];
        }
    }

    return packet;
}

@end
