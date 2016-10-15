/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2016 Cell Cloud Team (www.cellcloud.net)
 
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

/**
 * 块数据传输方言工厂。
 *
 * @author Jiangwei Xu
 */
@interface CCChunkDialectFactory : CCDialectFactory

- (void)write:(CCChunkDialect *)chunk;

- (BOOL)checkCompleted:(NSString *)sign;

- (int)read:(NSString *)sign withIndex:(int)index withData:(NSMutableData *)outPut;

- (void)clear:(NSString *)sign;

@end



/**
 * 内部缓存。
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



/**
 * 发送清单。
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
