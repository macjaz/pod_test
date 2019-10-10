//
//  SakuraLogHelper.h
//  SakuraKit
//
//  Created by 123 on 2018/6/26.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SakuraLogHelper : NSObject

+ (void)logFunc:(const char [])func info:(NSString *)info;
+ (void)setLogFlag:(BOOL)logFlag;

@end
