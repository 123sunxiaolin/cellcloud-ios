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

#import "CellChunkDialectFactory.h"
#import "CellChunkDialect.h"
#import "CellDialectMetaData.h"
#import "CellTalkService.h"
#import "CellUtil.h"
#import "CellLogger.h"

#define CLEAR_THRESHOLD  10L * 1024L * 1024L

@interface CCChunkDialectFactory ()
{
    CCDialectMetaData *_metaData;

    // 数据接收缓存，Key: Sign
    NSMutableDictionary *_cacheDic;

    // 数据发送列表映射
    NSMutableDictionary *_listDic;

    long long _cacheMemorySize;
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

        self.maxCacheMemory = CLEAR_THRESHOLD;
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

        if (!list.running)
        {
            list.running = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [list process];
            });
        }
    }
    else
    {
        ChunkList *newList = [[ChunkList alloc] initWithTarget:identifier andChunkNum:chunk.chunkNum];
        [newList append:chunk];
        [_listDic setObject:newList forKey:chunk.sign];

        if (!newList.running)
        {
            newList.running = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [newList process];
            });
        }
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
- (NSArray *)cancel:(NSString *)sign
{
    ChunkList *list = (ChunkList *)[_listDic objectForKey:sign];
    if (nil == list)
    {
        return nil;
    }
    
    [_listDic removeObjectForKey:sign];
    
    return [list getList];
}
//------------------------------------------------------------------------------
- (void)write:(CCChunkDialect *)chunk
{
    if (chunk.chunkIndex == 0)
    {
        [self clear:chunk.sign];
    }

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

    if (_cacheMemorySize > 1024L)
    {
        [CCLogger i:@"Cache memory size: %ld KB", (long)(_cacheMemorySize / 1024L)];
    }
    else
    {
        [CCLogger i:@"Cache memory size: %ld Bytes", _cacheMemorySize];
    }

    if (_cacheMemorySize > self.maxCacheMemory)
    {
        if (!_clearRunning)
        {
            _clearRunning = YES;

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                long long time = LONG_LONG_MAX;
                Cache *selected = nil;

                NSMutableArray *emptyList = [[NSMutableArray alloc] initWithCapacity:2];
                
                while (_cacheMemorySize > self.maxCacheMemory)
                {
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
                        
                        [CCLogger i:@"Cache memory size: %ld KB", (long)(_cacheMemorySize / 1024L)];
                    }
                    
                    if (0 != emptyList.count)
                    {
                        for (Cache *cache in emptyList)
                        {
                            [_cacheDic removeObjectForKey:cache.sign];
                        }
                        
                        [emptyList removeAllObjects];
                    }
                    
                    time = LONG_LONG_MAX;
                    selected = nil;
                }

                _clearRunning = NO;
                emptyList = nil;
            });
        }
    }
}

//------------------------------------------------------------------------------
- (int)read:(NSString *)sign withIndex:(int)index withData:(NSMutableData *)output;
{
    if (index < 0)
    {
        return -1;
    }

    Cache *cache = (Cache *)[_cacheDic objectForKey:sign];
    if (nil != cache)
    {
        CCChunkDialect *cd = [cache getAtIndex:index];
        NSData *buf = cd.data;
        int len = cd.length;

        // 清空
        if (output.length > 0)
        {
            [output resetBytesInRange:NSMakeRange(0, output.length)];
            [output setLength:0];
        }

        // 填充数据
        [output appendData:buf];

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

//------------------------------------------------------------------------------
- (void)cleanup:(BOOL)force
{
    if (force)
    {
        [_cacheDic removeAllObjects];
        _cacheMemorySize = 0;
        return;
    }
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:2];
    for (Cache *cache in [_cacheDic allValues])
    {
        if ([cache checkCompleted])
        {
            [list addObject:cache];
        }
    }

    if (0 != list.count)
    {
        for (Cache *cache in list)
        {
            long size = [cache clear];
            _cacheMemorySize -= size;

            [_cacheDic removeObjectForKey:cache.sign];
        }

        [list removeAllObjects];
    }

    list = nil;
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
        /*for (int i = 0; i < _dataQueue.count; ++i)
        {
            CCChunkDialect *cur = [_dataQueue objectAtIndex:i];
            if (chunk.chunkIndex == cur.chunkIndex)
            {
                // 找到索引匹配的 Chunk
                [_dataQueue setObject:chunk atIndexedSubscript:chunk.chunkIndex];
                return;
            }
        }*/

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
    
    // 单位为毫秒的数据发送间隔
    int _interval;
    
    // 重试次数
    int _retry;
}

@end

@implementation ChunkList

@synthesize timestamp = _timestamp;
@synthesize target = _target;
@synthesize chunkNum = _chunkNum;
@synthesize running = _running;

- (id)initWithTarget:(NSString *)target andChunkNum:(int)chunkNum
{
    self = [super init];
    if (self)
    {
        _timestamp = [CCUtil currentTimeMillis];
        _target = target;
        _chunkNum = chunkNum;
        _index = -1;
        _running = NO;
        _list = [[NSMutableArray alloc]initWithCapacity:chunkNum];
        _interval = 100;
        _retry = 2;
    }
    return self;
}
//------------------------------------------------------------------------------
- (void)append:(CCChunkDialect *)chunk
{
    // 标识为已污染
    chunk.infectant = YES;

    @synchronized (_list) {
        [_list addObject:chunk];
    }

    if (chunk.chunkIndex == 0)
    {
        double t = (CHUNK_SIZE / 1024.0f) / (chunk.speedInKB + 0.0f) * 1000.0f;
        if (t >= 10.0f)
        {
            _interval = round(t) + 1;
        }
        else
        {
            _interval = 10;
        }
    }
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
    _running = NO;
    _interval = 100;
    _retry = 2;

    @synchronized (_list) {
        [_list removeAllObjects];
    }
}
//------------------------------------------------------------------------------
- (void)process
{
    CCChunkDialect *chunk = nil;

    ++_index;

    @synchronized (_list) {
        if (_index < _list.count)
        {
            chunk = [_list objectAtIndex:_index];
        }
    }

    if (nil != chunk)
    {
        BOOL ret = [[CCTalkService sharedSingleton] talk:_target dialect:chunk];

        if (ret)
        {
            if (_index + 1 == _chunkNum)
            {
                [chunk fireCompleted:_target];
                
                _running = NO;
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_interval * 1000ll * NSEC_PER_USEC)),
                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self process];
                });
            }
        }
        else
        {
            // 修正索引
            --_index;

            [chunk fireFailed:_target];
            
            _running = NO;
        }
    }
    else
    {
        // 修正索引
        --_index;
        
        if (_retry > 0)
        {
            // 未找到数据，重试
            
            --_retry;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_interval * 1000ll * NSEC_PER_USEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                           [self process];
                       });
        }
        else
        {
            _running = NO;
        }
    }
}
//------------------------------------------------------------------------------
- (NSArray *)getList
{
    return _list;
}

@end
