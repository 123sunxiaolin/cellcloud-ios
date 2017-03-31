/*
 -----------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2015 Cell Cloud Team - cellcloudproject@gmail.com
 
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
 -----------------------------------------------------------------------------
 */

#import "FileManager.h"
#import "Cell.h"
#import <math.h>

#define THRESHOLD_FILE_LENGTH 5 * 1024 * 1024

@implementation FileManager

@synthesize delegate = _delegate;
@synthesize fileData = _fileData;

/// 实例
static FileManager *sharedInstance = nil;

//------------------------------------------------------------------------------
+ (FileManager *)sharedSingleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FileManager alloc] init];
    });
    return sharedInstance;
}
//------------------------------------------------------------------------------
- (id)init
{
    if ((self = [super init]))
    {
        _fileData = [[NSMutableData alloc]initWithCapacity:CHUNK_SIZE];
    }
    
    return self;
}

//------------------------------------------------------------------------------
- (BOOL)sendFile:(NSString *)fileName
andCelletIdentifier:(NSString *)identifier
         andFile:(NSData *)file
       andSender:(NSString *)sender
     andReceiver:(NSString *)receiver
{
    long fileLength = file.length;
    if (fileLength > THRESHOLD_FILE_LENGTH)
    {
        return NO;
    }
    
    // TODO 断点续传
    int chunkNum = (fileLength <= CHUNK_SIZE) ? 1 : (int)floor(fileLength / CHUNK_SIZE);
    if (fileLength > CHUNK_SIZE && fileLength % CHUNK_SIZE != 0)
    {
        chunkNum += 1;
    }

    // 生成 Tracker
    NSString *tracker = [NSString stringWithFormat:@"%@,%@",sender, receiver];
    
    int len = 0;
    long processed = 0;
    int chunkIndex = 0;
    for (int i = 0; i < chunkNum; ++i)
    {
        NSData *subData = nil;
        if (i * CHUNK_SIZE <= file.length )
        {
            if ((i + 1) * CHUNK_SIZE > file.length)
            {
                len = (int)(file.length - i * CHUNK_SIZE);
                subData = [file subdataWithRange:NSMakeRange(i * CHUNK_SIZE, len)];
            }
            else
            {
                len = CHUNK_SIZE;
                subData = [file subdataWithRange:NSMakeRange(i * CHUNK_SIZE, len)];
            }
            processed += len;
        }
        chunkIndex = i;
        CCChunkDialect *chunk = [[CCChunkDialect alloc] initWithTracker:tracker sign:fileName totalLength:file.length chunkIndex:chunkIndex chunkNum:chunkNum data:subData length:len];
        [[CCTalkService sharedSingleton] talk:identifier dialect:chunk];
        
        if (nil != _delegate)
        {
            [_delegate onSendProgress:subData andReceiver:receiver andProcessed:processed andTotal:fileLength];
        }
        
    }
    
    return YES;
}

//------------------------------------------------------------------------------
- (void)receiveChunk:(CCChunkDialect *)dialect
{
    NSString *fileName = dialect.sign;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:fileName];

    //NSData *tmp = dialect.data;//[[NSData alloc] initWithBase64EncodedString:dialect.data options:0];
    [_fileData appendData:dialect.data];

    long processed = 0;
    long total = dialect.totalLength;
    int index = dialect.chunkIndex;
    
    if (index + 1 == dialect.chunkNum)
    {
        processed = total;
    }
    else
    {
        processed = (index + 1) * CHUNK_SIZE;
    }
    
    NSString *trackerInfo = dialect.tracker;
    
    NSRange range = [trackerInfo rangeOfString:@","];
    NSString *sender = nil;
    NSString *receiver = nil;
    if (range.length)
    {
        sender = [trackerInfo substringWithRange:NSMakeRange(0, range.location)];
        receiver = [trackerInfo substringWithRange:NSMakeRange(range.location + 1, trackerInfo.length - range.location - 1)];
    }
    
    if (nil != _delegate)
    {
        [_delegate onReceiveProgress:_fileData andSender:sender andProcessed:processed andTotal:total];
    }
    
    if ([dialect hasCompleted])
    {
        [fm createFileAtPath:path contents:_fileData attributes:nil];
    }
}

@end
