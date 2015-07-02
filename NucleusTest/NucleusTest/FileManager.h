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

#import <Foundation/Foundation.h>

@class  CCChunkDialect;

@protocol FileManagerDelegate <NSObject>

/*! 发送处理中
 * \param file
 * \param receiver
 * \param processed
 * \param total
 */
- (void)onSendProgress:(NSData *)file andReceiver:(NSString *)receiver andProcessed:(long)processed andTotal:(long)total;

/*! 接收处理中
 * \param file
 * \param sender
 * \param processed
 * \param total
 */
- (void)onReceiveProgress:(NSData *)file andSender:(NSString *)sender andProcessed:(long)processed andTotal:(long)total;

@end

@interface FileManager : NSObject

@property (nonatomic, assign) id<FileManagerDelegate> delegate;

@property (nonatomic, strong) NSMutableData *fileData;

+ (FileManager *)sharedSingleton;

- (BOOL)sendFile:(NSString *)fileName
andCelletIdentifier:(NSString *)identifier
         andFile:(NSData *)file
       andSender:(NSString *)sender
     andReceiver:(NSString *)receiver;


- (void)receiveChunk:(CCChunkDialect *)dialect;

@end
