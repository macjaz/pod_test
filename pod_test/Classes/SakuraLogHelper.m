//
//  SakuraLogHelper.m
//  SakuraKit
//
//  Created by 123 on 2018/6/26.
//  Copyright © 2018年 keilon. All rights reserved.
//


#import "SakuraLogHelper.h"
#import <objc/runtime.h>
#import "SakuraLog.h"

@interface SakuraLogHelper()

@property (class, nonatomic, assign) BOOL logFlag;

@end

@implementation SakuraLogHelper

static bool _logFlag = NO;

+ (void)logFunc:(const char [])func info:(NSString *)info {
    
    if (SakuraLogHelper.logFlag) {
        NSLog(@"[SakuraKit]%s%@\n", func, info);
        [[SakuraLog sharedInstance]logFunc:[[NSString alloc] initWithUTF8String:func] logInfo:info];
    }
}

+ (BOOL)logFlag {
    return _logFlag;
}

+ (void)setLogFlag:(BOOL)logFlag {
    _logFlag = logFlag;
}





@end
