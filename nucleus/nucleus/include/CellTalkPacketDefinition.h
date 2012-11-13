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

#ifndef CellTalkPacketDefinition_h
#define CellTalkPacketDefinition_h

#define TPT_B1 'C'
#define TPT_B2 'T'

// 连接询问验证
#define TPT_INTERROGATE_B3 'I'
#define TPT_INTERROGATE_B4 'T'
#define TPT_INTERROGATE {TPT_B1, TPT_B2, TPT_INTERROGATE_B3, TPT_INTERROGATE_B4}

// 请求验证密文结果
#define TPT_CHECK_B3 'C'
#define TPT_CHECK_B4 'K'
#define TPT_CHECK {TPT_B1, TPT_B2, TPT_CHECK_B3, TPT_CHECK_B4}

// 设置为代理访问
#define TPT_PROXY_B3 'P'
#define TPT_PROXY_B4 'X'
#define TPT_PROXY {TPT_B1, TPT_B2, TPT_PROXY_B3, TPT_PROXY_B4}

// 代理请求的透明数据
#define TPT_TRAN_B3 'T'
#define TPT_TRAN_B4 'R'
#define TPT_TRAN {TPT_B1, TPT_B2, TPT_TRAN_B3, TPT_TRAN_B4}

// 请求 Cellet 服务
#define TPT_REQUEST_B3 'R'
#define TPT_REQUEST_B4 'Q'
#define TPT_REQUEST {TPT_B1, TPT_B2, TPT_REQUEST_B3, TPT_REQUEST_B4}

// Cellet 对话
#define TPT_DIALOGUE_B3 'D'
#define TPT_DIALOGUE_B4 'L'
#define TPT_DIALOGUE {TPT_B1, TPT_B2, TPT_DIALOGUE_B3, TPT_DIALOGUE_B4}

// 网络心跳
#define TPT_HEARTBEAT_B3 'H'
#define TPT_HEARTBEAT_B4 'B'
#define TPT_HEARTBEAT {TPT_B1, TPT_B2, TPT_HEARTBEAT_B3, TPT_HEARTBEAT_B4}

#endif // CellTalkPacketDefinition_h

