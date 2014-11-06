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

/** 内核角色。
 */
typedef enum _CCNucleusRole
{
    /// 计算节点
    CCRoleNode = 0x01,

    /// 存储
    CCRoleStorage = 0x02,

    /// 网关
    CCRoleGate = 0x04,

    /// 消费
    CCRoleConsumer = 0x08
} CCNucleusRole;


/** 内核设备平台类型。
 */
typedef enum _CCNucleusDevice
{
    /// 手机
    CCDevicePhone = 1,
    
    /// 平板
    CCDeviceTablet = 3,

    /// 台式机
    CCDeviceDesktop = 5,

    /// 服务器
    CCDeviceServer = 7
} CCNucleusDevice;

@interface CCNucleusConfig : NSObject

@property (assign) CCNucleusRole role;
@property (assign) CCNucleusDevice device;

/** 初始化。
 */
- (id)init;

/** 初始化。
 */
- (id)init:(CCNucleusRole)role device:(CCNucleusDevice)device;

@end
