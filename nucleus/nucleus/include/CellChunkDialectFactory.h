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

#import "CellDialectFactory.h"

/*!
 @brief 块数据传输方言工厂。

 @author Ambrose Xu
 */
@interface CCChunkDialectFactory : CCDialectFactory

/*!
 @brief 写入数据到缓存区。

 @param chunk 指定待写入数据的区块。
 */
- (void)write:(CCChunkDialect *)chunk;

/*!
 @brief 检查指定记号的区块是否接收完成。

 @param sign 指定待检查的区块记号。
 @return 如果已经接收了整个区块返回 <code>YES</code> 。
 */
- (BOOL)checkCompleted:(NSString *)sign;

/*!
 @brief 读取指定标记区块在指定索引位置的数据。

 @param sign 指定区块的标记。
 @param index 指定区块的索引。
 @param output 指定输出的数据。
 @return 返回读取的数据长度。
 */
- (int)read:(NSString *)sign withIndex:(int)index withData:(NSMutableData *)output;

/*!
 @brief 从内存中清空指定记号的所有区块。
 
 @param sign 指定待清空的记号。
 */
- (void)clear:(NSString *)sign;

@end



/*!
 @brief 内部缓存。
 */
@interface Cache : NSObject

@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSMutableArray *dataQueue;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, assign) long dataSize;

- (id)initWithSign:(NSString *)sign andCapacity:(int)capacity;

- (void)offer:(CCChunkDialect *)chunk;

- (CCChunkDialect *)getAtIndex:(int)index;

- (BOOL)checkCompleted;

- (long)clear;

- (BOOL)isEmpty;

@end



/*!
 @brief 发送清单。
 */
@interface ChunkList : NSObject

@property (nonatomic, assign) long long timestamp;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign) int chunkNum;

- (id)initWithTarget:(NSString *)target andChunkNum:(int)chunkNum;;

- (void)append:(CCChunkDialect *)chunk;

- (BOOL)isComplete;

- (void)reset:(int)chunkNum;

- (void)process;

@end
