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

#include "CellPrerequisites.h"

// 1.x 版包段数据长度定义
#define PSL_TAG 4
#define PSL_VERSION 4
#define PSL_SN 4
#define PSL_PAYLOAD_LENGTH 8
#define PSL_SEGMENT_NUM 4
#define PSL_SEGMENT_LENGTH 8

// 1.x 版最大包体长度。
#define MAX_PAYLOAD_LENGTH 262144

// 1.x 版字段长度定义
#define PSL_PAYLOADLENGTH_STRINGLENGTH (PSL_BODY_LENGTH + 1)
#define PSL_SEGMENTNUM_STRINGLENGTH (PSL_SEGMENT_NUM + 1)
#define PSL_SEGMENTLENGTH_STRINGLENGTH (PSL_SEGMENT_LENGTH + 1)


// 2.x 版定义
#define PFB_VERSION 1
#define PFB_RES 1
#define PFB_TAG 4
#define PFB_SN 2
#define PFB_SEGMENT_NUM 2
#define PFB_SEGMENT_LENGTH 4


/** 数据包。
 */
@interface CCPacket : NSObject
{
@private
    char _tag[PFB_TAG];
    short _major;
    short _minor;
    short _sn;

    NSMutableArray *_segments;
}

/**
 */
- (id)initWithTag:(char *)tag sn:(short)sn
            major:(short)major minor:(short)minor;

/**
 */
- (int)getTag:(char *)tag;
/**
 */
- (BOOL)compareTag:(const char *)other;

/**
 */
- (short)getMajor;
/**
 */
- (short)getMinor;

/**
 */
- (short)getSequenceNumber;

/**
 */
- (int)getPayloadLength;

/**
 */
- (void)appendSegment:(NSData *)data;

/**
 */
- (NSData *)getSegment:(NSUInteger)index;

/**
 */
- (NSUInteger)numSegments;


#pragma mark Pack/Unpack Methods

/**
 */
+ (NSData *)pack:(CCPacket *)packet;

/**
 */
+ (CCPacket *)unpack:(NSData *)data;

@end
