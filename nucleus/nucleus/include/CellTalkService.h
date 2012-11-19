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


/// 状态码
#define CCTS_SUCCESS {'0', '0', '0', '0'}
#define CCTS_FAIL {'0', '0', '0', '1'}
#define CCTS_FAIL_NOCELLET {'0', '0', '1', '0'}


/** 会话监听器。
 * @author Jiangwei Xu
 */
@protocol CCTalkListener <NSObject>
@optional
/** 数据会话。
 */
- (void)dialogue:(NSString *)tag primitive:(CCPrimitive *)primitive;

/** 与对端 Nucleus 建立连接。
 */
- (void)contacted:(NSString *)tag;

/** 与对端 Nucleus 断开连接。
 */
- (void)quitted:(NSString *)tag;

/** 发生错误。
 */
- (void)failed:(NSString *)identifier;

@end


/** 会话服务。
 * @author Jiangwei Xu
 */
@interface CCTalkService : NSObject <CCService>
{
@private
    NSObject *_monitor;
    NSMutableArray *_speakers;          /// Speaker 列表
    NSMutableArray *_lostSpeakers;
    NSUInteger _hbCounts;               /// Speaker 心跳计数
    NSTimer *_daemonTimer;
    NSTimeInterval _tickTime;
}

/// 会话监听器
@property (nonatomic, strong) id<CCTalkListener> listener;

/** 返回单例。
 */
+ (CCTalkService *)sharedSingleton;

/** 启动守护任务。 */
- (void)startDaemon;

/** 停止守护任务。 */
- (void)stopDaemon;

/** 申请 Cellet 服务。
 */
- (BOOL)call:(CCInetAddress *)address identifier:(NSString *)identifier;

/** 挂断 Cellet 服务。
 */
- (void)hangup:(NSString *)identifier;

/** 向 Cellet 发送原语。
 */
- (BOOL)talk:(NSString *)identifier primitive:(CCPrimitive *)primitive;

/** 标记指定 Speaker 为连接丢失。
 */
- (void)markLostSpeaker:(CCSpeaker *)speaker;

@end
