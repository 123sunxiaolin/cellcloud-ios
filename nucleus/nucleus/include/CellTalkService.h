/*
 ------------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2014 Cell Cloud Team - www.cellcloud.net
 
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
#include "CellTalkDefinition.h"

/**
 * 会话监听器。
 *
 * @author Jiangwei Xu
 */
@protocol CCTalkListener <NSObject>
@optional
/** 与内核进行会话。
 */
- (void)dialogue:(NSString *)identifier primitive:(CCPrimitive *)primitive;

/** 与对端内核建立连接。
 */
- (void)contacted:(NSString *)identifier tag:(NSString *)tag;

/** 与对端内核断开连接。
 */
- (void)quitted:(NSString *)identifier tag:(NSString *)tag;

/** 发生错误。
 */
- (void)failed:(CCTalkServiceFailure *)failure;

@end

/**
 * 会话代理。
 *
 * @author Jiangwei Xu
 */
@protocol CCTalkDelegate <NSObject>

/** 发送回调。
 */
- (BOOL)doTalk:(NSString *)identifier withDialect:(CCDialect *)dialect;

/** 已经发送回调。
 */
- (void)didTalk:(NSString *)identifier withDialect:(CCDialect *)dialect;

/** 接收回调。
 */
- (BOOL)doDialogue:(NSString *)identifier withDialect:(CCDialect *)dialect;

/** 已经接收回调。
 */
- (void)didDialogue:(NSString *)identifier withDialect:(CCDialect *)dialect;

@end


/**
 * 会话服务。
 *
 * @author Jiangwei Xu
 */
@interface CCTalkService : NSObject <CCService>

/// 会话监听器
@property (nonatomic, strong) id<CCTalkListener> listener;

/// 会话代理
@property (nonatomic, assign) id<CCTalkDelegate> delegate;

/** 返回单例。
 */
+ (CCTalkService *)sharedSingleton;

/** 启动守护任务。 */
- (void)startDaemon;

/** 启动后台守护任务 */
- (void)backgroundKeepAlive;

/** 停止守护任务。 */
- (void)stopDaemon;

/**
 * 申请指定的 Cellet 服务。
 */
- (BOOL)call:(NSArray *)identifiers hostAddress:(CCInetAddress *)address;

/**
 * 申请指定的 Cellet 服务。
 */
- (BOOL)call:(NSArray *)identifiers hostAddress:(CCInetAddress *)address capacity:(CCTalkCapacity *)capacity;

/**
 * 挂断指定的 Cellet 服务。
 */
- (void)hangUp:(NSString *)identifier;

/**
 * 向 Cellet 发送原语。
 */
- (BOOL)talk:(NSString *)identifier primitive:(CCPrimitive *)primitive;

/**
 * 向 Cellet 发送方言。
 */
- (BOOL)talk:(NSString *)identifier dialect:(CCDialect *)dialect;

/**
 * 是否已经与 Cellet 建立服务。
 */
- (BOOL)isCalled:(NSString *)identifier;

/** 标记指定 Speaker 为连接丢失。
 */
- (void)markLostSpeaker:(CCSpeaker *)speaker;

@end
