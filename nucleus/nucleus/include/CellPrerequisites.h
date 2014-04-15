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

#ifndef CellPrerequisites_h
#define CellPrerequisites_h

#import <Foundation/Foundation.h>

#pragma mark Servie Protocol

/** 标准服务接口。
 * @author Jiangwei Xu
 */
@protocol CCService <NSObject>

/** 启动服务。 */
- (BOOL)startup;

/** 关闭服务。 */
- (void)shutdown;

@end



// Common Group

@class CCCryptology;
@class CCInetAddress;
@class CCMessage;
@class CCMessageConnector;
@class CCMessageService;
@class CCNonblockingConnector;
@class CCPacket;
@class CCSession;


// Core Group

@class CCLogger;
@class CCLoggerManager;
@class CCNucleus;
@class CCNucleusConfig;
@class CCNucleusTag;
@class CCVersion;

// Talk Group

@class CCDialect;
@class CCDialectFactory;
@class CCDialectMetaData;
@class CCActionDialect;
@class CCActionDialectFactory;
@class CCPrimitive;
@class CCSubjectStuff;
@class CCPredicateStuff;
@class CCObjectiveStuff;
@class CCAttributiveStuff;
@class CCAdverbialStuff;
@class CCComplementStuff;
@class CCTalkCapacity;
@class CCTalkService;
@class CCSpeaker;
@class CCTalkServiceFailure;

#endif // CellPrerequisites_h
