//
//  SakuraFormNSData.h
//  SakuraKit
//
//  Created by 123 on 2018/5/10.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SakuraFormData : NSObject

//multipartFormData need boundary
+ (NSData *)voiceData:(NSData *)data withRequest:(NSMutableURLRequest *)request;
+ (NSData *)imageData:(NSData *)data withRequest:(NSMutableURLRequest *)request;
+ (NSData *)videoData:(NSData *)data withRequest:(NSMutableURLRequest *)request;

@end
