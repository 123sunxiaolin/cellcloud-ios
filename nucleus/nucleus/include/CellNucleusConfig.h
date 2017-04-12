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

/*!
 @brief 内核角色定义。
 */
typedef enum _CCNucleusRole
{
    /*! 计算节点。 */
    CCRoleNode = 0x01,

    /*! 网关节点。 */
    CCRoleGate = 0x02,

    /*! 消费端。 */
    CCRoleConsumer = 0x04

} CCNucleusRole;


/*!
 @brief 内核设备平台类型。
 */
typedef enum _CCNucleusDevice
{
    /*! 移动设备。 */
    CCDeviceMobile = 1,
    
    /*! 平板设备。 */
    CCDeviceTablet = 3,

    /*! 桌面设备。 */
    CCDeviceDesktop = 5,

    /*! 服务器。 */
    CCDeviceServer = 7

} CCNucleusDevice;


/*!
 @brief 内核设备平台类型。
 */
@interface CCNucleusConfig : NSObject

/*! 内核角色定义。 */
@property (nonatomic, assign) CCNucleusRole role;
/*! 内核设备类型定义。 */
@property (nonatomic, assign) CCNucleusDevice device;

/*!
 @brief 初始化。
 */
- (id)init;

/*!
 @brief 指定角色和设备类型进行初始化。
 
 @param role 指定角色定义。
 @param device 指定设备类型。
 */
- (id)initWithRole:(CCNucleusRole)role andDevice:(CCNucleusDevice)device;

@end
