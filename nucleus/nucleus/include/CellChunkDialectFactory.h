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

#import "CellDialectFactory.h"

/**
 * 块数据传输方言工厂。
 *
 * @author Jiangwei Xu
 */
@interface CCChunkDialectFactory : CCDialectFactory

- (void)write:(CCChunkDialect *)chunk;

- (BOOL)checkCompleted:(NSString *)tag withSign:(NSString *)sign;

- (int)read:(NSString *)tag withSign:(NSString *)sign withIndex:(int)index withData:(NSData *)outPut;

- (void)clear:(NSString *)tag withSign:(NSString *)sign;

@end

/**
 * 内部缓存。
 */
@interface Cache : NSObject

@property (nonatomic, strong) NSString *tag;

@property (nonatomic, assign) long dataSize;

- (id)initWithTag:(NSString *)tag;

- (void)offer:(CCChunkDialect *)chunk;

- (CCChunkDialect *)getChunk:(NSString *)sign atIndex:(int)index;

- (BOOL)checkCompleted:(NSString *)sign;

- (long)clear:(NSString *)sign;

- (BOOL)isEmpty;

- (long long)getFirstTime;

- (long)clearFirst;

@end

/**
 * 队列
 */

@interface Queue : NSObject

@property (nonatomic, assign) int ackIndex;

@property (nonatomic, assign) int chunkNum;

- (id)initWithTarget:(NSString *)target andChunkNum:(int)chunkNum;;

- (void)enqueue:(CCChunkDialect *)chunk;

- (CCChunkDialect *)dequeue;

- (int)size;

- (long)remainingChunkLength;

@end
