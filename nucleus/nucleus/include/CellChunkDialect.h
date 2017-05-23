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

#import "CellDialect.h"

#define CHUNK_DIALECT_NAME @"ChunkDialect"
#define CHUNK_SIZE 2048

@class CCChunkDialect;

/*!
 @brief 区块方言委派。
 */
@protocol CCChunkDelegate <NSObject>

/*!
 @brief 区块数据正在处理时回调。

 @param chunkDialect 区块方言。
 @param target 区块的传送目标。
 */
- (void)onProgress:(CCChunkDialect *)dialect andTraget:(NSString *)traget;

/*!
 @brief 区块数据处理完成时回调。
 
 @param chunkDialect 区块方言。
 @param target 区块的传送目标。
 */
- (void)onCompleted:(CCChunkDialect *)dialect andTarget:(NSString *)target;

/*!
 @brief 区块数据处理失败时回调。
 
 @param chunkDialect 区块方言。
 @param target 区块的传送目标。
 */
- (void)onFailed:(CCChunkDialect *)dialect andTarget:(NSString *)target;

@end


/*!
 @brief 块数据方言。

 @author Ambrose Xu
 */
@interface CCChunkDialect : CCDialect

/*! 事件委派。 */
@property (nonatomic, assign) id<CCChunkDelegate> delegate;

/*! 整块记号。用于标记整个块。 */
@property (nonatomic, strong, readonly) NSString *sign;
/*! 整块总长度。 */
@property (nonatomic, assign, readonly) long long totalLength;
/*! 整块总数量。 */
@property (nonatomic, assign, readonly) int chunkNum;
/*! 当前块索引。 */
@property (nonatomic, assign, readonly) int chunkIndex;
/*! 当前块数据。 */
@property (nonatomic, strong, readonly) NSData *data;
/*! 当前块长度。 */
@property (nonatomic, assign, readonly) int length;
/*! 数据传输速率。 */
@property (nonatomic, assign) long speedInKB;

/*!
 用于标识该区块是否能写入缓存队列。
 如果为 <code>YES</code> ，表示已经“污染”，不能进入队列，必须直接发送。
 */
@property (nonatomic, assign) BOOL infectant;

// 顺序读操作的索引。
@property (nonatomic, assign) int readIndex;

/*!
 @brief 指定跟踪器初始化。
 
 @param tracker 指定追踪器。
 */
- (id)initWithTracker:(NSString *)tracker;

/*!
 @brief 指定区块信息初始化。
 
 @param sign 指定整块的记号。
 @param totalLength 指定整块的总长度。
 @param chunkIndex 指定当前块索引。
 @param chunkNum 指定总块数量。
 @param data 指定当前块数据。
 @param length 指定当前块的数据长度。
 */
- (id)initWithSign:(NSString *)sign totalLength:(long)totalLength chunkIndex:(int)chunkIndex
          chunkNum:(int)chunkNum data:(NSData *)data length:(int)length;

/*!
 @brief 指定区块信息初始化。
 
 @param tracker 指定追踪器。
 @param sign 指定整块的记号。
 @param totalLength 指定整块的总长度。
 @param chunkIndex 指定当前块索引。
 @param chunkNum 指定总块数量。
 @param data 指定当前块数据。
 @param length 指定当前块的数据长度。
 */
- (id)initWithTracker:(NSString *)tracker sign:(NSString *)sign totalLength:(long)totalLength
           chunkIndex:(int)chunkIndex chunkNum:(int)chunkNum data:(NSData *)data length:(int)length;

/*!
 @brief 触发正在处理数据事件。
 */
- (void)fireProgress:(NSString *)target;

/*!
 @brief 触发整块数据块接收完成事件。
 */
- (void)fireCompleted:(NSString *)target;

/*!
 @brief 触发发生故障事件。
 */
- (void)fireFailed:(NSString *)target;

/*!
 @brief 取消当前记号对应的所有区块的发送。
 */
- (NSArray *)cancel;

/*!
 @brief 此块所属记号的区块是否全部接收完毕。
 
 @return 如果整个区块数据接收完毕返回 <code>YES</code> 。
 */
- (BOOL)hasCompleted;

/*!
 @brief 此区块是否是最后一个区块。

 @return 如果是最后一个区块返回 <code>YES</code> 。
 */
- (BOOL)isLast;

/*!
 @brief 读取指定块的数据。

 @param index 指定读取区块的索引。
 @param buffer 指定接收读取数据的数组。
 @return 返回读取数据的长度，如果读取失败返回 <code>-1</code> 。
 */
- (int)read:(int)index andData:(NSMutableData *)buffer;

/*!
 @brief 自动计数方式依次读取区块数据。

 @param buffer 指定接收读取数据的数组。
 @return 返回读取数据的长度，如果读取失败返回 <code>-1</code> 。
 */
- (int)read:(NSMutableData *)buffer;

/*!
 @brief 重置读数据索引。
 */
- (void)resetRead;

/*!
 清空此区块所属记号的整块数据。
 */
- (void)clearAll;

@end
