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

#include "CellPrerequisites.h"

// 包段数据长度定义。
#define PSL_TAG 4
#define PSL_VERSION 4
#define PSL_SN 4
#define PSL_BODY_LENGTH 8
#define PSL_SUBSEGMENT_NUM 4
#define PSL_SUBSEGMENT_LENGTH 8

// 最大包体长度。
#define PACKET_MAX_BODYLENGTH 262144

#define PSL_BODYLENGTH_STRINGLENGTH (PSL_BODY_LENGTH + 1)
#define PSL_SUBSEGMENTNUM_STRINGLENGTH (PSL_SUBSEGMENT_NUM + 1)
#define PSL_SUBSEGMENTLENGTH_STRINGLENGTH (PSL_SUBSEGMENT_LENGTH + 1)


/** 数据包。
 */
@interface CCPacket : NSObject
{
@private
    char _tag[PSL_TAG + 1];
    UInt16 _major;
    UInt16 _minor;
    UInt16 _sn;

    NSData *_body;
    NSMutableArray *_subsegments;
}

/**
 */
- (id)initWithTag:(char *)tag sn:(UInt16)sn
            major:(UInt16)major minor:(UInt16)minor;

/**
 */
- (UInt16)getTag:(char *)tag;
/**
 */
- (BOOL)compareTag:(const char *)other;

/**
 */
- (void)setVersion:(UInt16)major minor:(UInt16)minor;

/**
 */
- (void)setSN:(UInt16)sn;

/**
 */
- (void)setBody:(NSData *)data;
/**
 */
- (NSData *)getBody;

/**
 */
- (void)appendSubsegment:(NSData *)data;

/**
 */
- (NSData *)getSubsegment:(NSUInteger)index;


#pragma mark Pack/Unpack Methods

/**
 */
+ (NSData *)pack:(CCPacket *)packet;

/**
 */
+ (CCPacket *)unpack:(NSData *)data;

@end
