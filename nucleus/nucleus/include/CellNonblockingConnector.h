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

#import "CellMessageConnector.h"
#import "GCDAsyncSocket.h"

/*!
 @brief 非阻塞消息连接器。
 
 @author Ambrose Xu
 */
@interface CCNonblockingConnector : CCMessageConnector <GCDAsyncSocketDelegate>

/*!
 @brief 使用数据记号初始化。
 
 @param delegate 消息事件委派。
 @param headMark 数据报文头。
 @param headLength 数据报文头的长度。
 @param tailMark 数据报文尾。
 @param tailLength 数据报文尾的长度。
 */
- (id)init:(id<CCMessageHandler>)delegate
        headMark:(char *)headMark headLength:(size_t)headLength
        tailMark:(char *)tailMark tailLength:(size_t)tailLength;

@end
