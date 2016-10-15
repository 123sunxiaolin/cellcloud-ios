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

#import "CellChunkDialectFactory.h"
#import "CellChunkDialect.h"
#import "CellDialectMetaData.h"
#import "CellTalkService.h"
#import "CellUtil.h"
#import "CellLogger.h"

#define CLEAR_THRESHOLD  10 * 1024 * 1024

@interface CCChunkDialectFactory ()
{
    CCDialectMetaData *_metaData;

    // 数据接收缓存，Key: Sign
    NSMutableDictionary *_cacheDic;

    // 数据发送列表映射
    NSMutableDictionary *_listDic;

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
        _listDic = [NSMutableDictionary dictionary];

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
    [_listDic removeAllObjects];
    _cacheMemorySize = 0;
}

//------------------------------------------------------------------------------
- (BOOL)onTalk:(NSString *)identifier andDialect:(CCDialect *)dialect
{
    CCChunkDialect *chunk = (CCChunkDialect *)dialect;

    if (chunk.infectant)
    {
        // 回调已处理
        [chunk fireProgress:identifier];

        // 直接发送
        return YES;
    }

    ChunkList *list = (ChunkList *)[_listDic objectForKey:chunk.sign];
    if (nil != list)
    {
        if (chunk.chunkIndex == 0)
        {
            [list reset:chunk.chunkNum];
        }

        // 写入列表
        [list append:chunk];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [list process];
        });
    }
    else
    {
        ChunkList *newList = [[ChunkList alloc] initWithTarget:identifier andChunkNum:chunk.chunkNum];
        [newList append:chunk];
        [_listDic setObject:newList forKey:chunk.sign];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [newList process];
        });
    }

    return NO;
}

//------------------------------------------------------------------------------
- (BOOL)onDialogue:(NSString *)identifier andDialect:(CCDialect *)dialect
{
    CCChunkDialect *chunk = (CCChunkDialect *)dialect;

    [self write:chunk];

    return YES;
}
//------------------------------------------------------------------------------
- (void)write:(CCChunkDialect *)chunk
{
    Cache *cache = (Cache *)[_cacheDic objectForKey:chunk.sign];
    if (nil != cache)
    {
        [cache offer:chunk];
    }
    else
    {
        Cache *newCache = [[Cache alloc]initWithSign:chunk.sign andCapacity:chunk.chunkNum];
        [newCache offer:chunk];
        [_cacheDic setObject:newCache forKey:chunk.sign];
    }

    // 更新内存大小
    _cacheMemorySize += chunk.data.length;

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
                long long time = LONG_LONG_MAX;
                Cache *selected = nil;

                NSMutableArray *emptyList = [[NSMutableArray alloc]initWithCapacity:2];
                for (Cache *cache in [_cacheDic allValues])
                {
                    if ([cache isEmpty])
                    {
                        [emptyList addObject:cache];
                        continue;
                    }

                    long long ft = cache.timestamp;

                    if (ft < time)
                    {
                        time = ft;
                        selected = cache;
                    }
                }

                if (nil != selected)
                {
                    long size = [selected clear];
                    [_cacheDic removeObjectForKey:selected.sign];

                    // 更新内存大小记录
                    _cacheMemorySize -= size;

                    [CCLogger i:@"Cache memory size: %ld KB", (long)(_cacheMemorySize / 1024)];
                }

                if (0 != emptyList.count)
                {
                    for (Cache *cache in emptyList)
                    {
                        [_cacheDic removeObjectForKey:cache.sign];
                    }
                }

                _clearRunning = NO;
            });
        }
    }
}

//------------------------------------------------------------------------------
- (int)read:(NSString *)sign withIndex:(int)index withData:(NSMutableData *)outPut;
{
    if (index < 0)
    {
        return -1;
    }

    Cache *cache = (Cache *)[_cacheDic objectForKey:sign];
    if (nil != cache)
    {
        CCChunkDialect *cd = [cache getAtIndex:index];
        // Base64 解码
        NSData *buf = [[NSData alloc]initWithBase64EncodedString:cd.data options:0];
        int len = cd.length;

        // 清空
        if (outPut.length > 0)
        {
            [outPut resetBytesInRange:NSMakeRange(0, outPut.length)];
            [outPut setLength:0];
        }

        // 填充数据
        [outPut appendData:buf];

        return len;
    }

    return -1;
}

//------------------------------------------------------------------------------
- (BOOL)checkCompleted:(NSString *)sign
{
    Cache *cache = (Cache *)[_cacheDic objectForKey:sign];
    if (nil != cache)
    {
        return [cache checkCompleted];
    }

    return NO;
}

//------------------------------------------------------------------------------
- (void)clear:(NSString *)sign
{
    Cache *cache = (Cache *)[_cacheDic objectForKey:sign];
    if (nil != cache)
    {
        // 清理缓存
        long size = [cache clear];

        // 计算缓存大小变化值
        _cacheMemorySize -= size;

        // 移除空缓存
        [_cacheDic removeObjectForKey:sign];
    }
}

#pragma  mark - Private Method
//------------------------------------------------------------------------------
/*- (void)checkAndClearQueue
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
}*/

@end



@implementation Cache

@synthesize sign = _sign;
@synthesize dataQueue = _dataQueue;
@synthesize timestamp = _timestamp;
@synthesize dataSize = _dataSize;

- (id)initWithSign:(NSString *)sign andCapacity:(int)capacity
{
    self = [super init];
    if (self)
    {
        _sign = sign;
        _dataQueue = [[NSMutableArray alloc]initWithCapacity:capacity];
        for (int i = 0; i < capacity; ++i)
        {
            [_dataQueue addObject:[[CCChunkDialect alloc] init]];
        }
        _dataSize = 0;
    }
    return self;
}
//------------------------------------------------------------------------------
- (void)offer:(CCChunkDialect *)chunk
{
    @synchronized (_dataQueue)
    {
        for (int i = 0; i < _dataQueue.count; ++i)
        {
            CCChunkDialect *cur = [_dataQueue objectAtIndex:i];
            if (chunk.chunkIndex == cur.chunkIndex)
            {
                // 找到索引匹配的 Chunk
                [_dataQueue setObject:chunk atIndexedSubscript:chunk.chunkIndex];
                return;
            }
        }

        [_dataQueue setObject:chunk atIndexedSubscript:chunk.chunkIndex];

        // 更新数据大小
        _dataSize += chunk.data.length;
    }

    _timestamp = [CCUtil currentTimeMillis];
}
//------------------------------------------------------------------------------
- (CCChunkDialect *)getAtIndex:(int)index
{
    @synchronized (_dataQueue)
    {
        if (index >= _dataQueue.count)
        {
            return nil;
        }

        return (CCChunkDialect *)[_dataQueue objectAtIndex:index];
    }
}
//------------------------------------------------------------------------------
- (BOOL)checkCompleted
{
    @synchronized (_dataQueue)
    {
        for (int i = 0; i < _dataQueue.count; ++i)
        {
            CCChunkDialect *chunk = (CCChunkDialect *)[_dataQueue objectAtIndex:i];
            if (chunk.chunkIndex < 0)
            {
                return NO;
            }
        }
    }

    return YES;
}
//------------------------------------------------------------------------------
- (long)clear
{
    long size = _dataSize;
    @synchronized (_dataQueue)
    {
        [_dataQueue removeAllObjects];
        _dataSize = 0;
    }
    return size;
}
//------------------------------------------------------------------------------
- (BOOL)isEmpty
{
    return (0 == _dataQueue.count);
}

@end




/**
 * 发送队列。
 */
@interface ChunkList ()
{
    NSInteger _index;
    NSMutableArray *_list;
}

@end

@implementation ChunkList

@synthesize timestamp = _timestamp;
@synthesize target = _target;
@synthesize chunkNum = _chunkNum;

- (id)initWithTarget:(NSString *)target andChunkNum:(int)chunkNum
{
    self = [super init];
    if (self)
    {
        _timestamp = [CCUtil currentTimeMillis];
        _target = target;
        _chunkNum = chunkNum;
        _index = -1;
        _list = [[NSMutableArray alloc]initWithCapacity:chunkNum];
    }
    return self;
}
//------------------------------------------------------------------------------
- (void)append:(CCChunkDialect *)chunk
{
    // 标识为已污染
    chunk.infectant = YES;

    [_list addObject:chunk];
}
//------------------------------------------------------------------------------
- (BOOL)isComplete
{
    return ((_index + 1) == _chunkNum);
}
//------------------------------------------------------------------------------
- (void)reset:(int)chunkNum
{
    _timestamp = [CCUtil currentTimeMillis];
    _chunkNum = chunkNum;
    _index = -1;

    [_list removeAllObjects];
}
//------------------------------------------------------------------------------
- (void)process
{
    CCChunkDialect *chunk = nil;

    ++_index;

    if (_index < _list.count)
    {
        chunk = [_list objectAtIndex:_index];
    }

    if (nil != chunk)
    {
        BOOL ret = [[CCTalkService sharedSingleton] talk:_target dialect:chunk];

        if (ret)
        {
            if (_index + 1 == _chunkNum)
            {
                [chunk fireCompleted:_target];
            }
        }
        else
        {
            // 修正索引
            --_index;

            [chunk fireFailed:_target];
        }
    }
    else
    {
        // 修正索引
        --_index;
    }
}

@end
