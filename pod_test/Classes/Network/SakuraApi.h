//
//  SakuraApi.h
//  SakuraKit
//
//  Created by keilon on 2018/1/12.
//  Copyright © 2018年 keilon. All rights reserved.
//

#ifndef SakuraApi_h
#define SakuraApi_h

#import <Foundation/Foundation.h>
#import "SakuraTypes.h"

typedef void(^FinishBlock)(int progress);

@interface SakuraApi : NSObject

/*!
 * 离线消息拉取接口
 *
 * @param identify          用户identify
 * @param token             用户授权token
 * @param deviceType        设备类型
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *            block-NSArray 离线消息列表，是`SIMessage`类型的数组
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)fetchOfflineMessage:(NSString *_Nonnull)identify
          withAuthorization:(NSString *_Nonnull)token
                  forDevice:(uint)deviceType
                 completion:(void (^_Nullable)(BOOL success, NSArray * _Nullable messageList, NSError * _Nullable error))completionHandler;



/*!
 * 历史消息拉取接口
 *
 * @param identify          用户identify
 * @param token             用户授权token
 * @param deviceType        设备类型
 * @param completionHandler 回调block
 *            block-NSArray 历史消息列表，是`SIMessage`类型的数组
 *            block-NSError 包含请求错误信息（没有值表示已经正确拉取）
 */
+ (void)fetchHistoryMessage:(NSString *_Nonnull)identify withAuthorization:(NSString *_Nonnull)token forDevice:(uint)deviceType completion:(void (^_Nullable)(NSArray * _Nullable, NSError * _Nullable))completionHandler;



/*!
 * 获取消息回执信息接口
 *
 * @param messageIds        需要获取的回执信息的消息ID数组
 * @param identify          用户identify
 * @param token             用户授权token
 * @param completionHandler 回调block
 *            block-NSArray 历史消息列表，是`SIMessage`类型的数组
 *            block-NSError 包含请求错误信息（没有值表示已经正确拉取）
 */
+ (void)fetchReceiptMessage:(NSArray *_Nonnull)messageIds identify:(NSString *_Nonnull)identify withAuthorization:(NSString *_Nonnull)token completion:(void (^_Nullable)(NSDictionary * _Nullable, NSError * _Nullable))completionHandler;

/*!
 * 更新消息同步时间接口
 *
 * @param identify          用户identify
 * @param token             用户授权token
 * @param deviceType        设备类型
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)updateSyncTime:(NSString *_Nonnull)identify
     withAuthorization:(NSString *_Nonnull)token
             forDevice:(uint)deviceType
            completion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler;

/*!
 * 更新用户设备token接口
 *
 * @param identify          用户identify
 * @param token             用户授权token
 * @param deviceType        设备类型
 * @param useSandbox        是否使用沙盒环境
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)updateDeviceToken:(NSString *_Nonnull)identify
        withAuthorization:(NSString *_Nonnull)token
              deviceToken:(NSString *_Nonnull)deviceToken
                forDevice:(uint)deviceType
               useSandbox:(BOOL)useSandbox
               completion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
/*!
 * 更新用户应用角标接口
 *
 * @param identify          用户identify
 * @param token             用户授权token
 * @param deviceType        设备类型
 * @param badge             新的角标值
 * @param completionHandler 回调block
 *               block-BOOL 请求成功标识
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)updateBadge:(NSString *_Nonnull)identify
        withAuthorization:(NSString *_Nonnull)token
                forDevice:(uint)deviceType
                 setBadge:(NSInteger)badge
               completion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler;

/*!
 * 上传图片接口
 *
 * @param data              图片二进制
 * @param token             用户授权token
 * @param progressBlock     回调progressBlock
 *            progress      上传进度
 
 * @param completion        回调block
 *            block-NSArray 图片消息body，是`SIImageBody`类型的数组
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)uploadImage:(NSData *_Nonnull)data
  withAuthorization:(NSString *_Nonnull)token
           progress:(void (^_Nullable)(float progress))progressBlock
         completion:(void (^_Nullable)(BOOL success, SIImageBody * _Nullable body, NSError *_Nullable error))completion;


/*!
 * 上传音频接口
 *
 * @param data              音频二进制
 * @param token             用户授权token
 * @param progressBlock     回调progressBlock
 *            progress      上传进度
 
 * @param completion        回调block
 *            block-NSArray 音频消息body，是`SIVoiceBody`类型的数组
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)uploadAudio:(NSData *_Nonnull)data
  withAuthorization:(NSString *_Nonnull)token
           progress:(void (^_Nullable)(float progress))progressBlock
         completion:(void (^_Nullable)(BOOL success, SIVoiceBody * _Nullable body, NSError *_Nullable error))completion;


/*!
 * 上传视频接口
 *
 * @param data              视频二进制
 * @param token             用户授权token
 * @param progressBlock     回调progressBlock
 *            progress      上传进度
 
 * @param completion        回调block
 *            block-NSArray 视频消息body，是`SIVideoBody`类型的数组
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)uploadVideo:(NSData *_Nonnull)data
  withAuthorization:(NSString *_Nonnull)token
           progress:(void (^_Nullable)(float progress))progressBlock
         completion:(void (^_Nullable)(BOOL success, SIShortvideoBody * _Nullable body, NSError *_Nullable error))completion;


/*!
 * 下载文件接口
 *
 * @param urlString         文件的资源地址
 * @param token             用户授权token
 * @param filePath          下载存放的沙盒文件地址
 * @param progressBlock     回调progressBlock
 *            progress      上传进度
 
 * @param completion        回调block
 *            block-NSArray 文件body，是`NSDATA`类型的数组
 *            block-NSError 包含请求错误信息（当请求成功标识为false时才有值）
 */
+ (void)downloadFile:(NSString *_Nonnull)urlString
   withAuthorization:(NSString *_Nonnull)token
              toPath:(NSString *_Nullable)filePath
             progress:(void (^_Nullable)(float progress))progressBlock
           completion:(void (^_Nullable)(BOOL success, NSData * _Nullable data, NSError *_Nullable error))completion;
@end

#endif /* SakuraApi_h */
