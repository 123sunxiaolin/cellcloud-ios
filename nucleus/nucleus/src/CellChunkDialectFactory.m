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

#import "CellChunkDialectFactory.h"
#import "CellChunkDialect.h"
#import "CellDialectMetaData.h"
#import "CellTalkService.h"
#import "CellUtil.h"
#import "CellLogger.h"

#define CLEAR_THRESHOLD  100 * 1024 * 1024

@interface CCChunkDialectFactory ()
{
    CCDialectMetaData *_metaData;
    NSMutableDictionary *_cacheDic;
    NSMutableDictionary *_queueDic;
    
    long _cacheMemorySize;
    BOOL _clearRunning;
}

@end

@implementation CCChunkDialectFactory

//------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
    {
        _metaData = [[CCDialectMetaData alloc] initWithName:CHUNK_DIALECT_NAME description:@"Chunk Dialect"];
        _cacheDic = [NSMutableDictionary dictionary];
        _queueDic = [NSMutableDictionary dictionary];
        
        _cacheMemorySize = 0;
        _clearRunning = NO;
    }
    
    return self;
}

//------------------------------------------------------------------------------
-  (CCDialectMetaData *)getMetaData
{
    return _metaData;
}

//------------------------------------------------------------------------------
- (CCDialect *)create:(NSString *)tracker
{
    return [[CCChunkDialect alloc] initWithTracker:tracker];
}

//------------------------------------------------------------------------------
- (void)shutdown
{
    [_cacheDic removeAllObjects];
    _cacheMemorySize = 0;
}

//------------------------------------------------------------------------------
- (BOOL)onTalk:(NSString *)identifier andDialect:(CCDialect *)dialect
{
    CCChunkDialect *chunk = (CCChunkDialect *)dialect;
    if (chunk.chunkIndex == 0 || chunk.infectant || chunk.ack)
    {
        //直接发送
        
        //回调已处理
        [chunk fireProgress:identifier];
        return YES;
    }
    else
    {
        Queue *queue = (Queue *)[_queueDic objectForKey:chunk.sign];
        if (nil != queue)
        {
            //写入队列
            [queue enqueue:chunk];
            //劫持，由队列发送
            return NO;
        }
        else
        {
            queue = [[Queue alloc]initWithTarget:identifier andChunkNum:chunk.chunkNum];
            [queue enqueue:chunk];
            [_queueDic setObject:queue forKey:chunk.sign];
            // 劫持，由队列发送
            return false;
        }
    }
    return YES;
}

//------------------------------------------------------------------------------
- (BOOL)onDialogue:(NSString *)identifier andDialect:(CCDialect *)dialect
{
    CCChunkDialect *chunk = (CCChunkDialect *)dialect;
    
    if (chunk.ack)
    {
        //收到ACK，发送下一个
        NSString *sign = chunk.sign;
        Queue *queue = (Queue *)[_queueDic objectForKey:chunk.sign];
        if (nil != queue)
        {
            //更新应答索引
            queue.ackIndex = chunk.chunkIndex;
            //发送下一条数据
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CCChunkDialect *response = queue.dequeue;
                if (nil != response)
                {
                    [[CCTalkService sharedSingleton] talk:identifier dialect:response];
                }
            });
            
            //检查
            if (queue.ackIndex == chunk.chunkNum - 1)
            {
                [self checkAndClearQueue];
            }
            
        }
        else
        {
            [CCLogger w:@"Can NOT find chunk : %@", sign];
        }
        //应答包，劫持
        return NO;
    }
    else
    {
        //回送确认
        NSString *sign = chunk.sign;
        CCChunkDialect *ack = [[CCChunkDialect alloc]initWithTracker:chunk.tracker];
        [ack setAckWithSign:sign chunkIndex:chunk.chunkIndex chunkNum:chunk.chunkNum];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[CCTalkService sharedSingleton] talk:identifier dialect:ack];
        });
        //不劫持
        return YES;
    }
}
//------------------------------------------------------------------------------
- (void)write:(CCChunkDialect *)chunk
{
    NSString *tag = chunk.ownerTag;
    if (nil != [_cacheDic objectForKey:tag] ) {
        Cache *cache = (Cache *)[_cacheDic objectForKey:tag];
        [cache offer:chunk];
    }
    else
    {
        Cache *cache = [[Cache alloc]initWithTag:tag];
        [cache offer: chunk];
        [_cacheDic setObject:cache forKey:tag];
    }
    
    //更新内存大小
    _cacheMemorySize += chunk.length;
    
    if (_cacheMemorySize > 1024)
    {
        [CCLogger i:@"Cache memory size: %ld KB", (long)(_cacheMemorySize / 1024)];
    }
    else
    {
        [CCLogger i:@"Cache memory size: %ld Bytes", _cacheMemorySize];
    }
    
    if (_cacheMemorySize > CLEAR_THRESHOLD)
    {
        if (!_clearRunning)
        {
            _clearRunning = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                long time = LONG_LONG_MAX;
                Cache *selected = nil;
                NSMutableArray *emptyList = [[NSMutableArray alloc]initWithCapacity:2];
                for (Cache *cache in [_cacheDic allValues])
                {
                    if ([cache isEmpty])
                    {
                        [emptyList addObject:cache];
                        continue;
                    }
                    
                    long long ft = [cache getFirstTime];
                    
                    if (ft < time)
                    {
                        time = ft;
                        selected = cache;
                    }
                }
                
                if (nil != selected)
                {
                    long size = [selected clearFirst];
                    _cacheMemorySize -= size;
                    
                    [CCLogger i:@"Cache memory size: %ld KB", (long)(_cacheMemorySize / 1024)];
                }
                
                if (0 != emptyList.count)
                {
                    for (Cache *cache in emptyList)
                    {
                        [_cacheDic removeObjectForKey:cache.tag];
                    }
                }
                
                _clearRunning = NO;
            });
        }
    }
}

//------------------------------------------------------------------------------
- (int)read:(NSString *)tag withSign:(NSString *)sign withIndex:(int)index
   withData:(NSData *)outPut;
{
    if (index < 0)
    {
        return -1;
    }
    
    Cache *cache = (Cache *)[_cacheDic objectForKey:tag];
    if (nil != cache)
    {
        CCChunkDialect *cd = [cache getChunk:sign atIndex:index];
        NSData *buf = cd.data;
        int len = cd.length;
        outPut = [NSData dataWithData:buf];
        return len;
    }
    return -1;
}

//------------------------------------------------------------------------------
- (BOOL)checkCompleted:(NSString *)tag withSign:(NSString *)sign
{
    Cache *cache = (Cache *)[_cacheDic objectForKey:tag];
    if (nil != cache)
    {
        return [cache checkCompleted:sign];
    }
    return NO;
}

//------------------------------------------------------------------------------

- (void)clear:(NSString *)tag withSign:(NSString *)sign
{
    Cache *cache = (Cache *)[_cacheDic objectForKey:tag];
    if (nil != cache)
    {
        //计算缓存大小变化值
        long size = cache.dataSize;
        
        //进行缓存清理
        [cache clear:sign];
        long ds = size - cache.dataSize;
        _cacheMemorySize -= ds;

        //移除空缓存
        if ([cache isEmpty])
        {
            [_cacheDic removeObjectForKey:tag];
        }
    }
}

#pragma  mark - Private Method
//------------------------------------------------------------------------------
- (void)checkAndClearQueue
{
    NSMutableArray *deleteList = [[NSMutableArray alloc]initWithCapacity:2];
    
    for (NSString *sign in _queueDic)
    {
        Queue *queue = [_queueDic objectForKey:sign];
        if (queue.ackIndex >= 0 && queue.chunkNum - 1 == queue.ackIndex)
        {
            //删除
            [deleteList addObject:sign];
        }
    }
    
    if (0 != deleteList.count)
    {
        for (NSString *sign in deleteList)
        {
            [_queueDic removeObjectForKey:sign];
            
            [CCLogger d:@"Clear chunk factory queue: %@", sign];
        }
        
        [deleteList removeAllObjects];
    }
    deleteList = nil;
}

@end

/**
 * 内部缓存
 */

@interface Cache ()
{
    NSMutableDictionary *_data;
    NSMutableArray *_signQueue;
    NSMutableArray *_signTimeQueue;
}

@end

@implementation Cache

@synthesize tag = _tag;
@synthesize dataSize = _dataSize;

- (id)initWithTag:(NSString *)tag
{
    self = [super init];
    if (self)
    {
        _tag = tag;
        _data = [NSMutableDictionary dictionary];
        _signQueue = [[NSMutableArray alloc]initWithCapacity:1];
        _signTimeQueue = [[NSMutableArray alloc]initWithCapacity:1];
        _dataSize = 0;
    }
    return self;
}

- (void)offer:(CCChunkDialect *)chunk
{
    NSMutableArray *list = [_data objectForKey:chunk.sign];
    if (nil != list)
    {
        [list addObject:chunk];
        //更新数据大小
        _dataSize += chunk.length;
    }
    else
    {
        list = [[NSMutableArray alloc]initWithCapacity:2];
        [list addObject:chunk];
        //更新数据大小
        _dataSize += chunk.length;
        [_data setObject:list forKey:chunk.sign];
        [_signQueue addObject:chunk.sign];
        NSNumber *time = [NSNumber numberWithLongLong:[CCUtil currentTimeMillis]];
        [_signTimeQueue addObject:time];
    }
}

- (CCChunkDialect *)getChunk:(NSString *)sign atIndex:(int)index
{
    NSMutableArray *list = [_data objectForKey:sign];
    CCChunkDialect *chunk = nil;
    if (nil != list)
    {
        chunk = (CCChunkDialect *)[list objectAtIndex:index];
    }
    return chunk;
}

- (BOOL)checkCompleted:(NSString *)sign
{
    NSMutableArray *list = [_data objectForKey:sign];
    if (nil != list)
    {
        CCChunkDialect *chunk = (CCChunkDialect *)[list objectAtIndex:0];
        if (chunk.chunkNum == list.count)
        {
            return YES;
        }
    }
    return NO;
}

- (long)clear:(NSString *)sign
{
    long size = 0;
    NSMutableArray *list = [_data objectForKey:sign];
    [_data removeObjectForKey:sign];
    if (nil != list)
    {
        for (CCChunkDialect *chunk in list)
        {
            _dataSize -= chunk.length;
            size += chunk.length;
        }
    }
    
    int index = [_signQueue indexOfObject:sign];
    if (index >= 0)
    {
        [_signQueue removeObjectAtIndex:index];
        [_signTimeQueue removeObjectAtIndex:index];
    }
    return size;
}

- (BOOL)isEmpty
{
    return !_data.count;
}

- (long long)getFirstTime
{
    NSNumber *num = [_signTimeQueue objectAtIndex:0];
    return num.longLongValue;
}

- (long)clearFirst
{
    NSString *sign = nil;
    sign = [_signTimeQueue objectAtIndex:0];
    return [self clear:sign];
}

@end

/**
 * 对列
 *
 */

@interface Queue ()
{
    NSString *_target;
    NSMutableArray *_queue;
}
@end

@implementation Queue

@synthesize ackIndex = _ackIndex;
@synthesize chunkNum = _chunkNum;

- (id)initWithTarget:(NSString *)target andChunkNum:(int)chunkNum
{
    self = [super init];
    if (self)
    {
        _target = target;
        _chunkNum = chunkNum;
        _queue = [[NSMutableArray alloc]initWithCapacity:2];
    }
    return self;
}

- (void)enqueue:(CCChunkDialect *)chunk
{
    //标识为已污染
    chunk.infectant = YES;
    [_queue addObject:chunk];
    
}

- (CCChunkDialect *)dequeue
{
    if (_queue.count == 0)
    {
        return nil;
    }
    CCChunkDialect *first = [_queue objectAtIndex:0];
    if (nil != first)
    {
        [_queue removeObject:first];
    }
    return first;
}

- (int)size
{
    return _queue.count;
}

- (long)remainingChunkLength
{
    if (_queue.count == 0)
    {
        return 0;
    }
    
    long remaining = 0;
    for (CCChunkDialect *chunk in _queue)
    {
        remaining += chunk.length;
    }
    return remaining;
}
@end
