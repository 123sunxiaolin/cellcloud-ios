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

// Private
@interface CCTalkService (Private)

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
        _speakers = [[NSMutableArray alloc] init];
        _hbCounts = 0;
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

    _daemonTimer = [NSTimer scheduledTimerWithTimeInterval:2
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
    if (_hbCounts >= 10)
    {
        // 20 秒一次心跳，计数器周期是 2 秒
        if (_speakers.count > 0)
        {
            for (CCSpeaker *spr in _speakers)
            {
                [spr heartbeat];
            }
        }

        _hbCounts = 0;
    }

    date = nil;
}

#pragma mark Client Interfaces

//------------------------------------------------------------------------------
- (BOOL)call:(CCInetAddress *)address identifier:(NSString *)identifier
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

    BOOL ret = [current call:address];
    return ret;
}
//------------------------------------------------------------------------------
- (void)hangup:(NSString *)identifier
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
        [current hangup];
        [_speakers removeObject:current];
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
    [speaker speak:primitive];
    
    return TRUE;
}
//------------------------------------------------------------------------------
- (void)markLostSpeaker:(CCSpeaker *)speaker
{
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
            _lostSpeakers = [[NSMutableArray alloc] init];
            [_lostSpeakers addObject:speaker];
        }
    }
}

#pragma mark Server Interfaces

@end
