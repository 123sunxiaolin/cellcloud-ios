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
        _speakers = [[NSMutableArray alloc] init];
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
    return FALSE;
}
//------------------------------------------------------------------------------
- (void)shutdown
{
    
}

#pragma mark -

//------------------------------------------------------------------------------
- (void)startSchedule
{
    
}
//------------------------------------------------------------------------------
- (void)stopSchedule
{
    
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
    
}

#pragma mark Server Interfaces

@end
