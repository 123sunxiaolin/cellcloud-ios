/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2012 Cell Cloud Team - cellcloudproject@gmail.com
 
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
    NSUInteger _hbCounts;               /// Speaker 心跳计数
}

// 守护定时器处理器。
- (void)handleDaemonTimer:(NSTimer *) timer;

@end


@implementation CCTalkService

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
        _hbCounts = 0;
        // 默认重试间隔：10 秒
        self.retryInterval = 10;

        // 添加默认方言工厂
        [[CCDialectEnumerator sharedSingleton] addFactory:[[CCActionDialectFactory alloc] init]];
    }

    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    [_speakers removeAllObjects];
}

#pragma mark Service Protocol

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
}

#pragma mark -

//------------------------------------------------------------------------------
- (void)startDaemon
{
    if (nil != _daemonTimer)
    {
        [_daemonTimer invalidate];
        _daemonTimer = nil;
    }

    _daemonTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                    target:self
                                                    selector:@selector(handleDaemonTimer:)
                                                    userInfo:nil
                                                    repeats:TRUE];
}
//------------------------------------------------------------------------------
- (void)stopDaemon
{
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

    ++_hbCounts;
    if (_hbCounts >= 12)
    {
        // 60 秒一次心跳，计数器周期是 5 秒
        if (_speakers.count > 0)
        {
            for (CCSpeaker *spr in _speakers)
            {
                [spr heartbeat];
            }
        }

        _hbCounts = 0;
    }

    @synchronized (_monitor) {
        // 检查丢失连接的 Speaker
        if (nil != _lostSpeakers && [_lostSpeakers count] > 0)
        {
            NSMutableArray *discardedItems = [NSMutableArray array];

            for (CCSpeaker *spr in _lostSpeakers)
            {
                if (_tickTime - spr.timestamp >= self.retryInterval)
                {
                    [CCLogger d:@"Retry call cellet %@ at %@:%d"
                        , spr.identifier
                        , spr.address.host
                        , spr.address.port];

                    [discardedItems addObject:spr];

                    [spr call:spr.address];
                }
            }

            [_lostSpeakers removeObjectsInArray:discardedItems];
        }
    }

    date = nil;
}

#pragma mark Client Interfaces

//------------------------------------------------------------------------------
- (BOOL)call:(NSString *)identifier hostAddress:(CCInetAddress *)address
{
    CCSpeaker *current = nil;
    for (CCSpeaker *speaker in _speakers)
    {
        if ([speaker.identifier isEqualToString:identifier])
        {
            current = speaker;
            break;
        }
    }

    if (nil == current)
    {
        current = [[CCSpeaker alloc] initWithIdentifier:identifier];
        [_speakers addObject:current];
    }
    else
    {
        @synchronized (_monitor) {
            if (nil != _lostSpeakers && [_lostSpeakers count] > 0)
            {
                if ([_lostSpeakers containsObject:current])
                {
                    [_lostSpeakers removeObject:current];
                }
            }
        }
    }

    BOOL ret = [current call:address];
    return ret;
}
//------------------------------------------------------------------------------
- (void)hangUp:(NSString *)identifier
{
    CCSpeaker *current = nil;
    for (CCSpeaker *speaker in _speakers)
    {
        if ([speaker.identifier isEqualToString:identifier])
        {
            current = speaker;
            break;
        }
    }

    if (nil != current)
    {
        [current hangUp];
        [_speakers removeObject:current];
    }

    @synchronized(_monitor) {
        if (nil != _lostSpeakers && [_lostSpeakers count] > 0)
        {
            for (CCSpeaker *speaker in _lostSpeakers)
            {
                if ([speaker.identifier isEqualToString:identifier])
                {
                    [_lostSpeakers removeObject:speaker];
                    break;
                }
            }
        }
    }
}
//------------------------------------------------------------------------------
- (void)suspend:(NSString *)identifier duration:(NSTimeInterval)duration
{
    @synchronized(_monitor) {
        for (CCSpeaker *speaker in _speakers)
        {
            if ([speaker.identifier isEqualToString:identifier])
            {
                [speaker suspend:duration];
                break;
            }
        }
    }
}
//------------------------------------------------------------------------------
- (void)resume:(NSString *)identifier startTime:(NSTimeInterval)startTime
{
    @synchronized(_monitor) {
        for (CCSpeaker *speaker in _speakers)
        {
            if ([speaker.identifier isEqualToString:identifier])
            {
                [speaker resume:startTime];
                break;
            }
        }
    }
}
//------------------------------------------------------------------------------
- (BOOL)talk:(NSString *)identifier primitive:(CCPrimitive *)primitive
{
    CCSpeaker *speaker = nil;
    for (CCSpeaker *s in _speakers)
    {
        if ([s.identifier isEqualToString:identifier])
        {
            speaker = s;
            break;
        }
    }

    if (nil == speaker)
    {
        return FALSE;
    }

    // 发送原语
    return [speaker speak:primitive];
}
//------------------------------------------------------------------------------
- (BOOL)talk:(NSString *)identifier dialect:(CCDialect *)dialect
{
    CCPrimitive *primitive = [dialect translate];
    return [self talk:identifier primitive:primitive];
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

#pragma mark Server Interfaces

@end
