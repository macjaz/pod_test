//
//  SakuraTaskDelegate.h
//  SakuraKit
//
//  Created by 123 on 2018/5/7.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^SakuraHttpClientProgressBlock)(float progress);
typedef void (^SakuraHttpClientCompleteBlock)(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error);

@interface SakuraTaskDelegate : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (nonatomic, copy, nullable) NSString  *filePath;
@property (nonatomic, copy, nullable) SakuraHttpClientProgressBlock  uploadProgressBlock;
@property (nonatomic, copy, nullable) SakuraHttpClientProgressBlock  downloadProgressBlock;
@property (nonatomic, copy, nullable) SakuraHttpClientCompleteBlock  completionHandler;

- (instancetype _Nonnull)initWithTask:(NSURLSessionTask *_Nullable)task;

@end
