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


/*!
 @brief 数据包。
 
 @author Ambrose Xu
 */
@interface CCPacket : NSObject
{
@private
    /// 包标签。
    char _tag[PFB_TAG];
    /// 包的主版本号。
    short _major;
    /// 包的副版本号。
    short _minor;
    /// 包序号。
    short _sn;

    /// 存储包字段的数组。
    NSMutableArray *_segments;
}

/*!
 @brief 指定包标签、包序号和包版本初始化。
 
 @param tag 包的标签。
 @param sn 包的序号。
 @param major 包的主版本号。
 @param minor 包的副版本号。
 */
- (id)initWithTag:(char *)tag sn:(short)sn
            major:(short)major minor:(short)minor;

/*!
 @brief 获得包的标签。
 
 @param tag 输出参数，存储包标签数据。
 @return 返回包标签数据的长度。
 */
- (int)getTag:(char *)tag;

/*!
 @brief 比较该包的标签和指定的标签。
 
 @param other 待比较的标签数据。
 @return 如果包标签与指定的标签相同返回 <code>YES</code> 。
 */
- (BOOL)compareTag:(const char *)other;

/*!
 @brief 获得主版本号。
 */
- (short)getMajor;

/*!
 @brief 获得副版本号。
 */
- (short)getMinor;

/*!
 @brief 获得包序号。
 */
- (short)getSequenceNumber;

/*!
 @brief 获得包的有效负载长度。
 
 @return 返回包的有效负载数据的长度。如果返回 <code>0</code> 说明该包只有包头，没有携带负载数据。
 */
- (int)getPayloadLength;

/*!
 @brief 向数据包追加新的数据段。
 
 @param data 指定追加的数据。
 */
- (void)appendSegment:(NSData *)data;

/*!
 @brief 获得指定索引的数据段数据。
 
 @param index 指定索引。
 */
- (NSData *)getSegment:(NSUInteger)index;

/*!
 @brief 返回数据包内的数据段数量。
 */
- (NSUInteger)numSegments;


#pragma mark Pack/Unpack Methods

/*!
 @brief 将数据包打包为字节数据流。
 */
+ (NSData *)pack:(CCPacket *)packet;

/*!
 @brief 将字节数据流解包为数据包对象。
 */
+ (CCPacket *)unpack:(NSData *)data;

@end
