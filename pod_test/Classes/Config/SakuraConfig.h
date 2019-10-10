//
//  SakuraConfig.h
//  SakuraKit
//
//  Created by keilon on 2018/7/27.
//  Copyright © 2018年 keilon. All rights reserved.
//

#ifndef SakuraConfig_h
#define SakuraConfig_h

#import <Foundation/Foundation.h>

/**
 * Sakura 常量定义
 */
extern const uint SAKURA_DEVICE_IOS;

/**
 * Sakura 属性配置
 */
@interface SakuraConfig : NSObject

+ (void)setApiBase:(NSString *_Nonnull)url;

+ (void)setFileBase:(NSString *_Nonnull)url;

///Sakura Api Base
+ (NSString *_Nonnull)ApiBase;

///Sakura File Base
+ (NSString *_Nonnull)FileBase;

@end

#endif /* SakuraConfig_h */
