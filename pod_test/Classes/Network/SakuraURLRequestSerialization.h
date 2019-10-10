//
//  SakuraURLRequestSerialization.h
//  SakuraKit
//
//  Created by 123 on 2018/5/10.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SakuraURLRequestSerialization : NSObject

//初始化一个下载的请求
- (NSMutableURLRequest *_Nonnull)downloadURLRequestSerialization:(NSString *_Nonnull)urlString
                                               withAuthorization:(NSString *_Nonnull)token;

//初始化一个voiceRequest请求
- (NSMutableURLRequest *_Nonnull)audioURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token;

//初始化一个imageRequest请求
- (NSMutableURLRequest *_Nonnull)imageURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token;

//初始化一个videoRequest请求
- (NSMutableURLRequest *_Nonnull)shortvideoURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token;

//初始化一个getUrlRequest的请求
- (NSMutableURLRequest *_Nonnull)GetURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token;

//初始化一个putUrlRequest的请求
- (NSMutableURLRequest *_Nonnull)PutURLRequestSerialization:(NSString *_Nonnull)urlString
                                          withAuthorization:(NSString *_Nonnull)token
                                                   withBody:(NSDictionary *_Nullable)requestBody
                                                  withError:(NSError *_Nullable)error;

//初始化一个updateTokenUrlRequest的请求
- (NSMutableURLRequest *_Nonnull)UpdateTokenRequestSerialization:(NSString *_Nonnull)urlString
                                               withAuthorization:(NSString *_Nonnull)token
                                                        withBody:(NSObject *_Nullable)requestBody
                                                       withError:(NSError *_Nullable)error;

@end
