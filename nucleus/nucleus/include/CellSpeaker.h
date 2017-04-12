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

#include "CellPrerequisites.h"
#import "CellMessageService.h"

/*!
 @brief 对话者状态。
 */
typedef enum _CCSpeakerState
{
    /*! 无对话。 */
    CCSpeakerStateHangUp = 1,

    /*! 正在请求服务。 */
    CCSpeakerStateCalling,

    /*! 已经请求服务。 */
    CCSpeakerStateCalled

} CCSpeakerState;

/*!
 @brief 对话者描述类。

 @author Ambrose Xu
 */
@interface CCSpeaker : NSObject <CCMessageHandler>

/*! 此对话者请求的 Cellet 标识清单。 */
@property (nonatomic, strong, readonly) NSArray *identifiers;
/*! 访问地址。 */
@property (nonatomic, strong, readonly) CCInetAddress *address;
/*! 服务器端的内核标签。 */
@property (nonatomic, strong, readonly) CCNucleusTag *remoteTag;
/*! 对话者协商的能力描述。 */
@property (nonatomic, strong) CCTalkCapacity *capacity;
/*! 最近一次心跳的时间戳。 */
@property (nonatomic, assign) NSTimeInterval timestamp;
/*! 状态。 */
@property (atomic, assign) CCSpeakerState state;
/*! 重连次数。 */
@property (nonatomic, assign) int retryCount;
/*! 是否已经达到最大重连次数，重连结束。 */
@property (nonatomic, assign) BOOL retryEnd;

/*!
 @brief 指定连接地址初始化。
 
 @param address 指定连接地址。
 */
- (id)initWith:(CCInetAddress *)address;

/*!
 @brief 指定连接地址和能力协商初始化。
 
 @param address 指定连接地址。
 @param capacity 指定能力协商。
 */
- (id)initWithAddress:(CCInetAddress *)address andCapacity:(CCTalkCapacity *)capacity;

/*!
 @brief 向指定地址请求 Cellet 服务。
 
 @param identifiers 指定请求的 Cellet 标识清单。
 @return 如果请求被发出返回 <code>YES</code> 。
 */
- (BOOL)call:(NSArray *)identifiers;

/*!
 @brief 对当前的会话请求进行重新连接。
 
 @return 如果请求被发出返回 <code>YES</code> 。
 */
- (BOOL)recall;

/*!
 @brief 中断与 Cellet 服务。
 */
- (void)hangUp;

/*!
 @brief 是否已经调用了 Cellet 。
 
 @return 如果已经调用了 Cellet 返回 <code>YES</code> 。
 */
- (BOOL)isCalled;

/*!
 @brief 向 Cellet 发送原语。
 
 @param identifier 指定接收数据的 Cellet 标识。
 @param primitive 指定待发送的原语。
 */
- (BOOL)speak:(NSString *)identifier primitive:(CCPrimitive *)primitive;

/*!
 @brief 发送心跳。
 
 @return 如果成功发送心跳返回 <code>YES</code> 。
 */
- (BOOL)heartbeat;

/** 触发重连结束事件。 */
- (void)fireRetryEnd;

@end
