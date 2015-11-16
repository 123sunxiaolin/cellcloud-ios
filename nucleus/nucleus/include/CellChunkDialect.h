/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2015 Cell Cloud Team (www.cellcloud.net)
 
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
#define CHUNK_SIZE 4096

@class CCChunkDialect;

/**
 * 区块方言委派。
 *
 * @author Jiangwei Xu
 */
@protocol CCChunkDelegate <NSObject>

/**
 * 执行区块时被线程回调的执行方法。
 */
- (void)onProgress:(CCChunkDialect *)dialect andTraget:(NSString *)traget;

@end

/**
 * 块数据方言。
 *
 * @author Jiangwei Xu
 */
@interface CCChunkDialect : CCDialect

/// 代理
@property (nonatomic, assign) id<CCChunkDelegate> delegate;

/// 块签名
@property (nonatomic, strong) NSString *sign;
/// 是否收到回包
@property (nonatomic, assign) BOOL ack;
/// 块索引
@property (nonatomic, assign) int chunkIndex;
/// 块总数
@property (nonatomic, assign) int chunkNum;
/// 块数据
@property (nonatomic, strong) NSData *data;

/// 块长度
@property (nonatomic, assign) int length;
/// 总长度
@property (nonatomic, assign) long totalLength;
/// 用于标识该区块是否能写入缓存队列
/// 如果为 true ，表示已经“污染”，不能进入队列，必须直接发送
@property (nonatomic, assign) BOOL infectant;
///
@property (nonatomic, assign) int readIndex;

/**
 * 指定动作的跟踪器。
 */
- (id)initWithTracker:(NSString *)tracker;

- (id)initWithSign:(NSString *)sign totalLength:(long)totalLength chunkIndex:(int)chunkIndex
          chunkNum:(int)chunkNum data:(NSData *)data length:(int)length;

- (id)initWithTracker:(NSString *)tracker Sign:(NSString *)sign totalLength:(long)totalLength
           chunkIndex:(int)chunkIndex chunkNum:(int)chunkNum data:(NSData *)data length:(int)length;
- (void)fireProgress:(NSString *)target;

- (void)setAckWithSign:(NSString *)sign chunkIndex:(int)chunkIndex chunkNum:(int)chunkNum;

- (BOOL)hasCompleted;

- (BOOL)isLast;

- (int)read:(int)index andData:(NSData *)buffer;

- (int)read:(NSData *)buffer;

- (void)resetRead;

- (void)clearAll;

@end
