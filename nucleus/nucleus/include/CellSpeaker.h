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

#include "CellPrerequisites.h"
#import "CellMessageService.h"

/** 对话者描述类。
 */
@interface CCSpeaker : NSObject <CCMessageHandler>
{
@private
    NSString *_identifier;
    CCNonblockingConnector *_connector;

    CCNucleusTag *_remoteTag;
    
    NSObject *_monitor;
}

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) CCNucleusTag *remoteTag;
@property (nonatomic, assign) BOOL called;

/** 初始化。 */
- (id)initWithIdentifier:(NSString *)identifier;

/** 向指定地址请求 Cellet 服务。 */
- (BOOL)call:(CCInetAddress *)address;

/** 中断与 Cellet 服务。 */
- (void)hangup;

/** 是否已经调用了 Cellet 。 */
- (BOOL)isCalled;

/** 向 Cellet 发送原语。 */
- (void)speak:(CCPrimitive *)primitive;

/** 心跳。 */
- (void)heartbeat;

@end
