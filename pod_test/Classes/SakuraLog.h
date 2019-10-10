//
//  SakuraLog.h
//  SakuraKit
//
//  Created by 123 on 2018/11/28.
//  Copyright © 2018 keilon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SakuraLog : NSObject

//获取单例
+ (instancetype) sharedInstance;

//写入日志
- (void)logFunc:(NSString *)module logInfo:(NSString *)logInfo;

@end

NS_ASSUME_NONNULL_END
