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
@property (nonatomic, assign, readonly) long totalLength;
/*! 整块总数量。 */
@property (nonatomic, assign, readonly) int chunkNum;
/*! 当前块索引。 */
@property (nonatomic, assign, readonly) int chunkIndex;
/*! 当前块数据。 */
@property (nonatomic, strong, readonly) NSData *data;
/*! 当前块长度。 */
@property (nonatomic, assign, readonly) int length;

/*!
 用于标识该区块是否能写入缓存队列。
 如果为 <code>YES</code> ，表示已经“污染”，不能进入队列，必须直接发送。
 */
@property (nonatomic, assign) BOOL infectant;

// 顺序读操作的索引。
@property (nonatomic, assign) int readIndex;

/*!
 @brief 指定动作的跟踪器初始化。
 */
- (id)initWithTracker:(NSString *)tracker;

- (id)initWithSign:(NSString *)sign totalLength:(long)totalLength chunkIndex:(int)chunkIndex
          chunkNum:(int)chunkNum data:(NSData *)data length:(int)length;

- (id)initWithTracker:(NSString *)tracker sign:(NSString *)sign totalLength:(long)totalLength
           chunkIndex:(int)chunkIndex chunkNum:(int)chunkNum data:(NSData *)data length:(int)length;

- (void)fireProgress:(NSString *)target;

- (void)fireCompleted:(NSString *)target;

- (void)fireFailed:(NSString *)target;

- (BOOL)hasCompleted;

- (BOOL)isLast;

- (int)read:(int)index andData:(NSMutableData *)buffer;

- (int)read:(NSMutableData *)buffer;

- (void)resetRead;

- (void)clearAll;

@end
