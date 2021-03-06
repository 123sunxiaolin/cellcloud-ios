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

#import "CellTalkService.h"
#import "CellSpeaker.h"
#import "CellPrimitive.h"
#import "CellDialect.h"
#import "CellDialectEnumerator.h"
#import "CellActionDialectFactory.h"
#import "CellChunkDialectFactory.h"
#import "CellTalkCapacity.h"
#import "CellInetAddress.h"
#import "CellLogger.h"

// Private
@interface CCTalkService ()
{
@private
    NSTimer *_daemonTimer;
    NSTimeInterval _tickTime;
    NSObject *_monitor;

    NSMutableArray *_speakers;          /// Speaker 列表
    NSMutableArray *_lostSpeakers;
    NSUInteger _hbCount;               /// Speaker 心跳计数
}

// 守护定时器处理器。
- (void)handleDaemonTimer:(NSTimer *) timer;

@end


@implementation CCTalkService

@synthesize delegate = _delegate;

/// 实例
static CCTalkService *sharedInstance = nil;

//------------------------------------------------------------------------------
+ (CCTalkService *)sharedSingleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCTalkService alloc] init];
    });
    return sharedInstance;
}
//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _monitor = [[NSObject alloc] init];
        _speakers = [NSMutableArray array];
        _hbCount = 0;

        // 添加默认方言工厂
        [[CCDialectEnumerator sharedSingleton] addFactory:[[CCActionDialectFactory alloc] init]];
        [[CCDialectEnumerator sharedSingleton] addFactory:[[CCChunkDialectFactory alloc] init]];
        
        //TODO
        _delegate = [CCDialectEnumerator sharedSingleton];
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    [_speakers removeAllObjects];
//    [_speakerMap removeAllObjects];
}

#pragma mark - Service Protocol

//------------------------------------------------------------------------------
- (BOOL)startup
{
    [self startDaemon];

    return TRUE;
}
//------------------------------------------------------------------------------
- (void)shutdown
{
    [self stopDaemon];

    [[CCDialectEnumerator sharedSingleton] shutdownAll];
}

#pragma mark - Common Methods

//------------------------------------------------------------------------------
- (void)startDaemon
{
    if (nil != _daemonTimer)
    {
        [_daemonTimer invalidate];
        _daemonTimer = nil;
    }

    _daemonTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                    target:self
                                                    selector:@selector(handleDaemonTimer:)
                                                    userInfo:nil
                                                    repeats:TRUE];
}
//------------------------------------------------------------------------------
- (void)backgroundKeepAlive
{
    [self heartbeat];
}
//------------------------------------------------------------------------------
- (void)stopDaemon
{
    _hbCount = 0;

    if (nil != _daemonTimer)
    {
        [_daemonTimer invalidate];
        _daemonTimer = nil;
    }
}
//------------------------------------------------------------------------------
- (void)handleDaemonTimer:(NSTimer *)timer
{
    NSDate *date = [NSDate date];
    _tickTime = date.timeIntervalSince1970;

    ++_hbCount;
    if (_hbCount >= 18)
    {
        // 180 秒一次心跳，计数器周期是 10 秒
        [self heartbeat];
        
        _hbCount = 0;
    }

    @synchronized (_monitor) {
        // 检查丢失连接的 Speaker
        if (nil != _lostSpeakers && [_lostSpeakers count] > 0)
        {
            NSMutableArray *discardedItems = [[NSMutableArray alloc] initWithCapacity:1];

            for (CCSpeaker *spr in _lostSpeakers)
            {
                if (nil != spr)
                {
                    // 最大重连次数
                    if (spr.retryCount >= spr.capacity.retry)
                    {
                        if (!spr.retryEnd)
                        {
                            spr.retryEnd = TRUE;
                            [spr fireRetryEnd];
                        }
                        else
                        {
                            continue;
                        }
                    }
                    else
                    {
                        spr.retryEnd = FALSE;
                    }
                    
                    if (nil != spr.capacity && _tickTime - spr.timestamp >= spr.capacity.retryDelay)
                    {
                        [CCLogger d:@"Retry call cellet at %@:%d"
                         , spr.address.host
                         , spr.address.port];
                        
                        [discardedItems addObject:spr];
                        
                        ++spr.retryCount;
                        
                        [spr recall];
                    }
                }
            }

            if (discardedItems.count > 0)
            {
                [_lostSpeakers removeObjectsInArray:discardedItems];
            }
        }
    }

    date = nil;
}

#pragma mark - Private Method

//------------------------------------------------------------------------------
- (void)heartbeat
{
    if (_speakers.count > 0)
    {
        for (CCSpeaker *spr in _speakers)
        {
            if ([spr heartbeat])
            {
                [CCLogger d:@"Speaker heartbeat to %@:%d"
                    , spr.address.host
                    , spr.address.port];
            }
            else
            {
                [CCLogger w:@"Speaker heartbeat failed - %@:%d"
                    , spr.address.host
                    , spr.address.port];
            }
        }
    }
}

#pragma mark - Client Interfaces

//------------------------------------------------------------------------------
- (BOOL)call:(NSArray *)identifiers hostAddress:(CCInetAddress *)address
{
    CCTalkCapacity *capacity = [[CCTalkCapacity alloc] init];
    return [self call:identifiers hostAddress:address capacity:capacity];
}
//------------------------------------------------------------------------------
- (BOOL)call:(NSArray *)identifiers hostAddress:(CCInetAddress *)address capacity:(CCTalkCapacity *)capacity
{
    __block BOOL contains = YES;

    for (CCSpeaker *speaker in _speakers)
    {
        for (NSString *identifier in identifiers)
        {
            contains = YES;

            [speaker.identifiers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:identifier])
                {
                    // 列表里已经有对应的 Cellet，不允许再次 Call
                    contains = NO;
                    *stop = YES;
                }
            }];

            if (NO == contains)
            {
                return NO;
            }
        }
    }

    CCSpeaker *speaker = [[CCSpeaker alloc] initWithAddress:address andCapacity:capacity];
    [_speakers addObject:speaker];

//    for (NSString *identifier in identifiers)
//    {
//        [_speakerMap setValue:speaker forKey:identifier];
//    }

    /* FIXME 1/6/15 Ambrose
    @synchronized (_monitor) {
        if (nil != _lostSpeakers && [_lostSpeakers count] > 0)
        {
            if ([_lostSpeakers containsObject:current])
            {
                [_lostSpeakers removeObject:current];
            }
        }
    }
    */

    BOOL ret = [speaker call:identifiers];
    return ret;
}
//------------------------------------------------------------------------------
- (void)hangUp:(NSString *)identifier
{
    __block CCSpeaker *current = nil;

    for (CCSpeaker *speaker in _speakers)
    {
        [speaker.identifiers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:identifier])
            {
                current = speaker;
                *stop = YES;
            }
        }];

        if (nil != current)
        {
            break;
        }
    }

    if (nil != current)
    {
        [current hangUp];
    }

    @synchronized(_monitor) {
        if (nil != _lostSpeakers && [_lostSpeakers count] > 0)
        {
            for (CCSpeaker *speaker in _lostSpeakers)
            {
                [speaker.identifiers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isEqualToString:identifier])
                    {
                        [_lostSpeakers removeObject:speaker];
                        *stop = YES;
                    }
                }];
            }
        }
    }

    if (nil != current)
    {
        [_speakers removeObject:current];
    }
}
//------------------------------------------------------------------------------
- (BOOL)talk:(NSString *)identifier primitive:(CCPrimitive *)primitive
{
    __block CCSpeaker *speaker = nil;

    for (CCSpeaker *s in _speakers)
    {
        [s.identifiers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:identifier])
            {
                speaker = s;
                *stop = YES;
            }
        }];

        if (nil != speaker)
        {
            break;
        }
    }

    if (nil == speaker)
    {
        return NO;
    }

    // 发送原语
    return [speaker speak:identifier primitive:primitive];
}
//------------------------------------------------------------------------------
- (BOOL)talk:(NSString *)identifier dialect:(CCDialect *)dialect
{
    //通知代理
    if (nil != _delegate)
    {
        BOOL ret = [_delegate doTalk:identifier withDialect:dialect];
        
        if (!ret)
        {
            //代理劫持
            return YES;
        }
    }
    
    CCPrimitive *primitive = [dialect reconstruct];
    if (nil != primitive)
    {
        BOOL ret = [self talk:identifier primitive:primitive];
        
        //发送成功
        if (ret && nil != _delegate)
        {
            [_delegate didTalk:identifier withDialect:dialect];
        }
        return ret;
    }
    return NO;
}
//------------------------------------------------------------------------------
- (BOOL)isCalled:(NSString *)identifier
{
    __block CCSpeaker *speaker = nil;

    @synchronized(_monitor) {
        for (CCSpeaker *s in _speakers)
        {
            [s.identifiers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:identifier])
                {
                    speaker = s;
                    *stop = YES;
                }
            }];

            if (nil != speaker)
            {
                break;
            }
        }
    }

    if (nil == speaker)
    {
        return NO;
    }

    return [speaker isCalled];
}
//------------------------------------------------------------------------------
- (BOOL)isCalled:(NSString *)identifier timeout:(int64_t)timeoutInMillis
{
    __block CCSpeaker *speaker = nil;

    @synchronized(_monitor) {
        for (CCSpeaker *s in _speakers)
        {
            [s.identifiers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:identifier])
                {
                    speaker = s;
                    *stop = YES;
                }
            }];
            
            if (nil != speaker)
            {
                break;
            }
        }
    }

    if (nil == speaker)
    {
        return NO;
    }

    return [speaker isCalledWithLatency:timeoutInMillis];
}
//------------------------------------------------------------------------------
- (void)markLostSpeaker:(CCSpeaker *)speaker
{
    speaker.timestamp = _tickTime;

    @synchronized(_monitor) {
        if (nil != _lostSpeakers)
        {
            if (![_lostSpeakers containsObject:speaker])
            {
                [_lostSpeakers addObject:speaker];
            }
        }
        else
        {
            _lostSpeakers = [NSMutableArray array];
            [_lostSpeakers addObject:speaker];
        }
    }
}

#pragma mark - Server Interfaces

@end
