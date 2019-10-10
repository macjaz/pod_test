//
//  SakuraHttpUtils.h
//  SakuraKit
//
//  Created by keilon on 2018/1/11.
//  Copyright © 2018年 keilon. All rights reserved.
//

#ifndef SakuraHttpUtils_h
#define SakuraHttpUtils_h

#import <Foundation/Foundation.h>
#import "SakuraTaskDelegate.h"

@interface SakuraHttpClient : NSObject

/*!
 * 封装http post请求
 *
 * @param request           请求的request
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *           block-NSObject 响应结果（json反序列化后的结果，类型为NSArray或者NSDictionary）参考[NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization)
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)post:(NSURLRequest *_Nonnull)request
  completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler;



/*!
 * 封装http put请求
 *
 * @param request           请求的request
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *           block-NSObject 响应结果（json反序列化后的结果，类型为NSArray或者NSDictionary）参考[NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization)
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)put:(NSURLRequest *_Nonnull)request
 completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler;



/*!
 * 封装http get请求
 *
 * @param request           请求的request
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *           block-NSObject 响应结果（json反序列化后的结果，类型为NSArray或者NSDictionary）参考[NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization)
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)get:(NSURLRequest *_Nonnull)request
 completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler;



/*!
 * 封装http上传文件请求
 *
 * @param urlRequest        请求的request
 * @param formData          文件formdata
 * @param taskProgress      上传进度回调
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *           block-NSObject 响应结果（json反序列化后的结果，类型为NSArray或者NSDictionary）参考[NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization)
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)upload:(NSURLRequest *_Nonnull)urlRequest
      withForm:(NSData *_Nonnull)formData
      progress:(SakuraHttpClientProgressBlock _Nullable)taskProgress
    completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler;


/*!
 * 封装http下载文件请求
 *
 * @param urlRequest        请求的request
 * @param filePath          下载文件存放的地址
 * @param taskProgress      下载的进度回调
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *           block-NSObject 响应结果（json反序列化后的结果，类型为NSArray或者NSDictionary）参考[NSJSONSerialization](https://developer.apple.com/documentation/foundation/nsjsonserialization)
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)download:(NSURLRequest *_Nonnull)urlRequest
          toPath:(NSString *_Nullable)filePath
      progress:(SakuraHttpClientProgressBlock _Nullable)taskProgress
    completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler;

@end

#endif /* SakuraHttpUtils_h */
