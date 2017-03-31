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

#import "CellPacket.h"
#import "CellUtil.h"

/**
 * ------------- 2.X 版本数据格式定义 ------------
 * 数据包字段，单位 byte：
 *
 * +--|-00-|-01-|-02-|-03-|-04-|-05-|-06-|-07-+
 * |--+---------------------------------------+
 * |01| VER| RES|        TAG        |    SN   |
 * |--+---------------------------------------+
 * |02|   SMN   |       SML{1}      |   ...   |
 * |--+---------------------------------------+
 * |03|   ...   |       SML{n}      |
 * |--+---------------------------------------+
 * |04|               SMD{1}                  |
 * |--+---------------------------------------+
 * |05|                ... ...                |
 * |--+---------------------------------------+
 * |06|               SMD{n}                  |
 * |--+---------------------------------------+
 *
 * 说明：
 * VER - 版本描述
 * RES - 保留位
 * TAG - 包标签
 * SN - 包序号
 * SMN - 数据段数量
 * SML - 每段数据段的长度
 * SMD - 每段数据段的负载数据
 * 动态包格式，从 SML 开始为动态长度
 *
 */

// 128 KB
#define PACK_BUF_SIZE 131072

@implementation CCPacket

//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        memset(_tag, 0x0, sizeof(_tag));
        _major = 2;
        _minor = 0;
        _sn = 1;
        _segments = nil;
    }

    return self;
}
//------------------------------------------------------------------------------
- (id)initWithTag:(char *)tag sn:(short)sn major:(short)major minor:(short)minor
{
    if ((self = [super init]))
    {
        memset(_tag, 0x0, sizeof(_tag));

        memcpy(_tag, tag, PFB_TAG);
        _major = major;
        _minor = minor;
        _sn = sn;
        _segments = nil;
    }

    return self;
}
//------------------------------------------------------------------------------
- (int)getTag:(char *)tag
{
    memcpy(tag, _tag, PFB_TAG);
    return PFB_TAG;
}
//------------------------------------------------------------------------------
- (BOOL)compareTag:(const char *)other
{
    for (uint i = 0; i < PFB_TAG; ++i)
    {
        if (_tag[i] != other[i])
        {
            return FALSE;
        }
    }

    return TRUE;
}
//------------------------------------------------------------------------------
- (short)getMajor
{
    return _major;
}
//------------------------------------------------------------------------------
- (short)getMinor
{
    return _minor;
}
//------------------------------------------------------------------------------
- (short)getSequenceNumber
{
    return _sn;
}
//------------------------------------------------------------------------------
- (int)getPayloadLength
{
    if (nil == _segments)
    {
        return 0;
    }

    int len = 0;

    if (_major == 2)
    {
        for (int i = 0; i < _segments.count; ++i)
        {
            len += PFB_SEGMENT_LENGTH;
            len += [((NSData *)[_segments objectAtIndex:i]) length];
        }
    }
    else
    {
        len = PSL_SEGMENT_NUM;

        for (int i = 0; i < _segments.count; ++i)
        {
            len += PSL_SEGMENT_LENGTH;
            len + [((NSData *)[_segments objectAtIndex:i]) length];
        }
    }

    return len;
}
//------------------------------------------------------------------------------
- (void)appendSegment:(NSData *)data
{
    if (nil == _segments)
    {
        _segments = [[NSMutableArray alloc] init];
    }

    [_segments addObject:data];
}
//------------------------------------------------------------------------------
- (NSData *)getSegment:(NSUInteger)index
{
    if (nil == _segments || index >= _segments.count)
    {
        return nil;
    }

    return [_segments objectAtIndex:index];
}
//------------------------------------------------------------------------------
- (NSUInteger)numSegments
{
    if (nil == _segments)
    {
        return 0;
    }

    return _segments.count;
}

#pragma mark Pack/Unpack Methods

//------------------------------------------------------------------------------
+ (NSData *)pack:(CCPacket *)packet
{
    if ([packet getMajor] == 2)
    {
        // 计算数据长度
        int payloadSize = [packet getPayloadLength];
        int totalSize = PFB_VERSION + PFB_RES + PFB_TAG + PFB_SN + PFB_SEGMENT_NUM + payloadSize;
        char *data = malloc(totalSize);
        int cursor = 0;

        // 填写 VER
        char version[PFB_VERSION] = { 0 };
        version[0] = (char)[packet getMajor];
        memcpy(data, version, PFB_VERSION);
        // 更新游标
        cursor += PFB_VERSION;

        // 填写 RES
        char res[PFB_RES] = { 0 };
        res[0] = (char)[packet getMinor];
        memcpy(data + cursor, res, PFB_RES);
        // 更新游标
        cursor += PFB_RES;

        // 填写 TAG
        char tag[PFB_TAG] = { 0 };
        [packet getTag:tag];
        memcpy(data + cursor, tag, PFB_TAG);
        // 更新游标
        cursor += PFB_TAG;

        // 填写 SN
        char sn[PFB_SN] = { 0 };
        [CCUtil shortToBytes:sn input:[packet getSequenceNumber]];
        memcpy(data + cursor, sn, PFB_SN);
        cursor += PFB_SN;

        // 填写 SMN
        short smn = [packet numSegments];
        char bSMN[PFB_SEGMENT_NUM] = { 0 };
        [CCUtil shortToBytes:bSMN input:smn];
        memcpy(data + cursor, bSMN, PFB_SEGMENT_NUM);
        cursor += PFB_SEGMENT_NUM;

        if (smn > 0)
        {
            // 填写动态的数据段长度
            for (short i = 0; i < smn; ++i)
            {
                int length = [[packet getSegment:i] length];
                char len[PFB_SEGMENT_LENGTH] = { 0 };
                [CCUtil intToBytes:len input:length];
                memcpy(data + cursor, len, PFB_SEGMENT_LENGTH);
                cursor += PFB_SEGMENT_LENGTH;
            }

            // 填写动态的数据段数据
            for (short i = 0; i < smn; ++i)
            {
                NSData *segment = [packet getSegment:i];
                int length = [segment length];
                memcpy(data + cursor, [segment bytes], length);
                cursor += length;
            }
        }

        return [NSData dataWithBytes:data length:cursor];
    }
    else
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

        NSUInteger bodyLength = 0;
        
        // 计算 Body 段长度
        if (nil != packet->_segments)
        {
            // 加入子段描述段的长度
            bodyLength += PSL_SEGMENT_NUM;
            bodyLength += (PSL_SEGMENT_LENGTH * packet->_segments.count);

            for (NSData *sub in packet->_segments)
            {
                bodyLength += sub.length;
            }
        }

        // Body length
        char szLen[PSL_PAYLOAD_LENGTH + 1] = {0x0};
        sprintf(szLen, "%08lu", (unsigned long)bodyLength);
        memcpy(buf + cursor, szLen, PSL_PAYLOAD_LENGTH);
        cursor += PSL_PAYLOAD_LENGTH;

        if (bodyLength > 0 && cursor + bodyLength <= PACK_BUF_SIZE)
        {
            if (nil != packet->_segments)
            {
                // 子段数量
                char szBuf[PSL_SEGMENT_LENGTH + 1] = {0x0};
                sprintf(szBuf, "%04lu", (unsigned long)packet->_segments.count);
                memcpy(buf + cursor, szBuf, PSL_SEGMENT_NUM);
                cursor += PSL_SEGMENT_NUM;

                // 各子段长度
                for (NSData *sub in packet->_segments)
                {
                    memset(szBuf, 0x0, sizeof(szBuf));
                    sprintf(szBuf, "%08lu", (unsigned long)sub.length);
                    memcpy(buf + cursor, szBuf, PSL_SEGMENT_LENGTH);
                    cursor += PSL_SEGMENT_LENGTH;
                }

                // 各子段数据
                for (NSData *sub in packet->_segments)
                {
                    memcpy(buf + cursor, [sub bytes], [sub length]);
                    cursor += [sub length];
                }
            }
        }

        NSData *data = [[NSData alloc] initWithBytes:buf length:cursor];
        return data;
    }
}
//------------------------------------------------------------------------------
+ (CCPacket *)unpack:(NSData *)data
{
    char *buf = [data bytes];
    if (buf[0] == 2)
    {
        int cursor = 0;

        // 解析版本号
        short major = buf[0];
        short minor = buf[1];
        // 更新游标
        cursor = 2;

        // 解析 TAG
        char tag[PFB_TAG] = { 0 };
        memcpy(tag, buf + cursor, PFB_TAG);
        // 更新游标
        cursor += PFB_TAG;

        // 解析 SN
        char bSN[PFB_SN] = { 0 };
        memcpy(bSN, buf + cursor, PFB_SN);
        short sn = [CCUtil bytesToShort:bSN];
        // 更新游标
        cursor += PFB_SN;

        // 解析 SMN
        char bSMN[PFB_SEGMENT_NUM] = { 0 };
        memcpy(bSMN, buf + cursor, PFB_SEGMENT_NUM);
        short smn = [CCUtil bytesToShort:bSMN];
        // 更新游标
        cursor += PFB_SEGMENT_NUM;

        // 创建数据包
        CCPacket *packet = [[CCPacket alloc] initWithTag:tag sn:sn major:major minor:minor];

        if (smn > 0)
        {
            // 解析动态数据段长度
            int payloadCursor = cursor + (smn * PFB_SEGMENT_LENGTH);
            for (short i = 0; i < smn; ++i)
            {
                char bLen[PFB_SEGMENT_LENGTH] = { 0 };
                memcpy(bLen, buf + cursor, PFB_SEGMENT_LENGTH);
                int len = [CCUtil bytesToInt:bLen];
                char *payload = malloc(len);
                memcpy(payload, buf + payloadCursor, len);

                NSData *segment = [NSData dataWithBytes:payload length:len];
                [packet appendSegment:segment];

                // 更新游标
                cursor += PFB_SEGMENT_LENGTH;
                payloadCursor += len;

                free(payload);
            }
        }

        
        return packet;
    }
    else
    {
        // Tag
        NSRange range = NSMakeRange(0, PSL_TAG);
        char tag[PSL_TAG + 1] = {0x0};
        [data getBytes:tag range:range];

        char szBuf[PSL_PAYLOAD_LENGTH + 1] = {0x0};

        // Version
        range = NSMakeRange(PSL_TAG, 2);
        [data getBytes:szBuf range:range];
        uint minor = atoi(szBuf);

        memset(szBuf, 0x0, sizeof(szBuf));
        range = NSMakeRange(PSL_TAG + 2, 2);
        [data getBytes:szBuf range:range];
        uint major = atoi(szBuf);

        // SN
        memset(szBuf, 0x0, sizeof(szBuf));
        range = NSMakeRange(PSL_TAG + PSL_VERSION, PSL_SN);
        [data getBytes:szBuf range:range];
        uint sn = atoi(szBuf);

        NSUInteger cursor = PSL_TAG + PSL_VERSION + PSL_SN;
        if (cursor > data.length)
        {
            // 数据长度错误
            return nil;
        }

        CCPacket *packet = [[CCPacket alloc] initWithTag:tag
                                                      sn:sn
                                                   major:major
                                                   minor:minor];
        
        memset(szBuf, 0x0, sizeof(szBuf));
        range = NSMakeRange(cursor, PSL_PAYLOAD_LENGTH);
        [data getBytes:szBuf range:range];
        NSUInteger bls = atoi(szBuf);

        cursor += PSL_PAYLOAD_LENGTH;

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
        range = NSMakeRange(cursor, PSL_SEGMENT_NUM);
        [data getBytes:szBuf range:range];
        int ssNum = atoi(szBuf);

        if (ssNum > 0)
        {
            // 进行分段解析
            // 更新游标位置
            cursor += PSL_SEGMENT_NUM;
            // 解析子段长度
            NSMutableArray *lenList = [[NSMutableArray alloc] initWithCapacity:ssNum];
            for (int i = 0; i < ssNum; ++i)
            {
                memset(szBuf, 0x0, sizeof(szBuf));
                range = NSMakeRange(cursor, PSL_SEGMENT_LENGTH);
                [data getBytes:szBuf range:range];
                int nLen = atoi(szBuf);
                NSNumber *len = [NSNumber numberWithInt:nLen];
                [lenList addObject:len];
                
                cursor += PSL_SEGMENT_LENGTH;
            }
            // 解析子段数据
            for (int i = 0; i < ssNum; ++i)
            {
                NSNumber *len = [lenList objectAtIndex:i];
                range = NSMakeRange(cursor, [len unsignedIntegerValue]);
                NSData *ssData = [data subdataWithRange:range];
                [packet appendSegment:ssData];
                cursor += [len unsignedIntValue];
            }
        }

        return packet;
    }
}

@end
