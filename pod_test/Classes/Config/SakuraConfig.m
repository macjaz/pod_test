//
//  SakuraConfig.m
//  SakuraKit
//
//  Created by keilon on 2018/7/27.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraConfig.h"

const uint SAKURA_DEVICE_IOS = 4;

@implementation SakuraConfig

static NSString* _apiBase  = @"https://api.im.group.taikang.com";
static NSString* _fileBase = @"https://fs.im.group.taikang.com";

+ (void)setApiBase:(NSString *_Nonnull)url {
    _apiBase = url;
}

+ (void)setFileBase:(NSString *_Nonnull)url {
    _fileBase = url;
}

///Sakura Api Base
+ (NSString *_Nonnull)ApiBase {
    
    return [NSString stringWithFormat:@"%@/api/v1", _apiBase];
}

///Sakura File Base
+ (NSString *_Nonnull)FileBase {
    
    return [NSString stringWithFormat:@"%@/api/v1/file", _fileBase];
}

@end
