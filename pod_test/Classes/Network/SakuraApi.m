//
//  SakuraApi.m
//  SakuraKit
//
//  Created by 移动互联部 on 2018/1/12.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraApi.h"
#import "SakuraHttpUtils.h"
#import "SakuraURLRequestSerialization.h"
#import "SakuraFormData.h"
#import "SakuraLogHelper.h"
#import "SakuraConfig.h"

@implementation SakuraApi

// MARK: - fetchOfflineMessage

+ (void)fetchOfflineMessage:(NSString *)identify withAuthorization:(NSString *)token forDevice:(uint)deviceType completion:(void (^)(BOOL, NSArray * _Nullable, NSError * _Nullable))completionHandler{
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completionHandler(false, nil, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/message/sync?identify=%@&deviceType=%u", SakuraConfig.ApiBase, identify, deviceType];
    NSMutableURLRequest *request = [urlRequestSerialization GetURLRequestSerialization:url withAuthorization:token];
    
    [SakuraHttpClient get:request completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completionHandler(false, nil, error);
        }else{
            NSArray *messageList  = [self arrayObjectWithSIMessage:(NSArray*)repsonse identify:identify];
            completionHandler(true, messageList, nil);
        }
    }];
}


// MARK: - fectHisotoryMessage
+ (void)fetchHistoryMessage:(NSString *)identify withAuthorization:(NSString *)token forDevice:(uint)deviceType completion:(void (^)(NSArray * _Nullable, NSError * _Nullable))completionHandler{
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completionHandler(nil, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/message/history?identify=%@&deviceType=%u&count=200", SakuraConfig.ApiBase, identify, deviceType];
    NSMutableURLRequest *request = [urlRequestSerialization GetURLRequestSerialization:url withAuthorization:token];
    
    [SakuraHttpClient get:request completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, error);
        }else{
            NSArray *messageList  = [self arrayObjectWithSIMessage:(NSArray*)repsonse identify:identify];
            completionHandler(messageList, nil);
        }
    }];
}


// MARK: - 获取消息回执信息
+ (void)fetchReceiptMessage:(NSArray *)messageIds identify:(NSString *)identify withAuthorization:(NSString *)token completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completionHandler {
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completionHandler(nil, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/message/sync/receipts?identify=%@", SakuraConfig.ApiBase, identify];
    NSError *error = nil;
    
    NSMutableURLRequest *request = [urlRequestSerialization UpdateTokenRequestSerialization:url withAuthorization:token withBody:messageIds withError:error];
    
    if(error){ //在body进行序列化的时候出现错误
        completionHandler(false, error);
        return;
    }
    
    [SakuraHttpClient post:request completion:^(BOOL success, NSObject * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionHandler(false, error);
        } else {
            completionHandler((NSDictionary *)response, nil);
        }
    }];
}


// MARK: - updateSyncTime

+ (void)updateSyncTime:(NSString *_Nonnull)identify withAuthorization:(NSString *_Nonnull)token forDevice:(uint)deviceType completion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler{
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completionHandler(false, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/message/sync/time?identify=%@&deviceType=%u", SakuraConfig.ApiBase, identify, deviceType];
    NSError *error = nil;
    NSMutableURLRequest *request = [urlRequestSerialization PutURLRequestSerialization:url withAuthorization:token withBody:nil withError:error];
    
    if(error){ //在body进行序列化的时候出现错误
        completionHandler(false, error);
        return;
    }
    
    [SakuraHttpClient put:request completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completionHandler(false, error);
        } else {
            completionHandler(true, nil);
        }
    }];
    
}

// MARK: - updateDeviceToken

+ (void)updateDeviceToken:(NSString *_Nonnull)identify
        withAuthorization:(NSString *_Nonnull)token
              deviceToken:(NSString * _Nonnull)deviceToken
                forDevice:(uint)deviceType
               useSandbox:(BOOL)useSandbox
               completion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completionHandler(false, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:identify forKey:@"identify"];
    [body setValue:@(deviceType) forKey:@"deviceType"];
    [body setValue:deviceToken forKey:@"deviceToken"];
    NSNumber *sandbox = [NSNumber numberWithInteger:(useSandbox ? 1 : 0)];
    [body setValue:sandbox forKey:@"sandBox"];
    NSError *error = nil;
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/device/token", SakuraConfig.ApiBase];
    NSMutableURLRequest *request = [urlRequestSerialization UpdateTokenRequestSerialization:url withAuthorization:token withBody:body withError:error];
    
    if(error){ //在body进行序列化的时候出现错误
        completionHandler(false, error);
        return;
    }
    [SakuraHttpClient post:request completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completionHandler(false, error);
        } else {
            completionHandler(true, nil);
        }
    }];
}

// MARK: - arrayObjectWithSIMessage

+ (NSArray*)arrayObjectWithSIMessage:(NSArray *)array
                            identify:(NSString *)selfId
{
    NSMutableArray * imMmessgae = [[NSMutableArray array] init];
    for (NSDictionary * dic in array) {
        SIMessage *message = [[SIMessage alloc] init];
        message.messageId = dic[@"messageId"];
        message.messageTS = [dic[@"timestamp"] doubleValue]/1000;
        message.domain = dic[@"domain"];
        message.sessionId = dic[@"sessionId"];
        NSString * str = dic[@"sessionType"];
        
        if ([str isEqualToString:@"CHAT"]) {
            message.sessionType = SI_SESSION_CHAT;
            message.senderId = dic[@"fromId"];
            message.senderLabel = dic[@"fromLabel"];
            if ([dic[@"fromId"] isEqualToString: selfId]) {
                message.sessionMain = dic[@"toId"];
                message.sessionLabel = dic[@"toLabel"];
            } else {
                message.sessionMain = dic[@"fromId"];
                message.sessionLabel = dic[@"fromLabel"];
            }
        } else if ([str isEqualToString:@"GROUP"]) {
            message.sessionType = SI_SESSION_GROUP;
            message.sessionMain = dic[@"toId"];
            message.sessionLabel = dic[@"toLabel"];
            message.senderId = dic[@"fromId"];
            message.senderLabel = dic[@"fromLabel"];
        } else if ([str isEqualToString:@"SYSTEM"]) {
            message.sessionType = SI_SESSION_SYSTEM;
            message.sessionMain = dic[@"sessionId"];
            message.sessionLabel = dic[@"sessionLabel"];
            message.senderId = dic[@"fromId"];
            message.senderLabel = dic[@"fromLabel"];
            message.sessionCategory = dic[@"systemMessageSessionType"];
            message.messageSourceType = dic[@"systemMessageType"];
            
        } else {
            [SakuraLogHelper logFunc:__FUNCTION__ info:@"invalid session type"];
        }
        [self parseMessageBody:dic[@"messageContent"] messageHolder:message];
        [imMmessgae addObject:message];
    }
    
    return imMmessgae;
}

+ (void)parseMessageBody:(NSString *)jsonStr
           messageHolder:(SIMessage *)message {
    NSData *getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *bodyDict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error: &jsonError];
    if (jsonError) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"%@", jsonError.description]];
        return ;
    }
    
    if ([bodyDict[@"messageType"] isEqualToString: @"TEXT"]) {
        SITextBody *body = [[SITextBody alloc] init];
        body.content = bodyDict[@"textMessage"][@"content"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_TEXT;
        message.messageBody = body;
    } else if ([bodyDict[@"messageType"] isEqualToString: @"IMAGE"]) {
        SIImageBody *body = [[SIImageBody alloc] init];
        body.mediaId = bodyDict[@"imageMessage"][@"mediaId"];
        body.thumbMediaId = bodyDict[@"imageMessage"][@"thumbMediaId"];
        body.title = bodyDict[@"imageMessage"][@"title"];
        body.size = [bodyDict[@"imageMessage"][@"size"] longLongValue];
        body.height = [bodyDict[@"imageMessage"][@"height"] intValue];
        body.width = [bodyDict[@"imageMessage"][@"width"] intValue];
        body.type = bodyDict[@"imageMessage"][@"type"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_IMAGE;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"VIDEO"]) {
        SIVideoBody *body = [[SIVideoBody alloc] init];
        body.mediaId = bodyDict[@"videoMessage"][@"mediaId"];
        body.thumbMediaId = bodyDict[@"videoMessage"][@"thumbMediaId"];
        body.title = bodyDict[@"videoMessage"][@"title"];
        body.size = [bodyDict[@"videoMessage"][@"size"] longLongValue];
        body.duration = [bodyDict[@"videoMessage"][@"duration"] intValue];
        body.type = bodyDict[@"videoMessage"][@"type"];
        body.height = [bodyDict[@"videoMessage"][@"height"] intValue];
        body.width = [bodyDict[@"videoMessage"][@"width"] intValue];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_VIDEO;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"VOICE"]) {
        SIVoiceBody *body = [[SIVoiceBody alloc] init];
        body.mediaId = bodyDict[@"voiceMessage"][@"mediaId"];
        body.size = [bodyDict[@"voiceMessage"][@"size"] longLongValue];
        body.duration = [bodyDict[@"voiceMessage"][@"duration"] intValue];
        body.type = bodyDict[@"voiceMessage"][@"type"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_VOICE;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"SHORTVIDEO"]) {
        SIShortvideoBody *body = [[SIShortvideoBody alloc] init];
        body.mediaId = bodyDict[@"shortVideoMessage"][@"mediaId"];
        body.size = [bodyDict[@"shortVideoMessage"][@"size"] longLongValue];
        body.duration = [bodyDict[@"shortVideoMessage"][@"duration"] intValue];
        body.thumbMediaId = bodyDict[@"shortVideoMessage"][@"thumbMediaId"];
        body.height = [bodyDict[@"shortVideoMessage"][@"height"] intValue];
        body.width = [bodyDict[@"shortVideoMessage"][@"width"] intValue];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_SHORTVIDEO;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"NEWS"]) {
        SINewsBody *body = [[SINewsBody alloc] init];
        body.title = bodyDict[@"newsMessage"][@"title"];
        body.desc = bodyDict[@"newsMessage"][@"description"];
        body.linkurl = bodyDict[@"newsMessage"][@"url"] ;
        body.picurl = bodyDict[@"newsMessage"][@"picurl"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_NEWS;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"FILE"]) {
        SIFileBody *body = [[SIFileBody alloc] init];
        body.title = bodyDict[@"fileMessage"][@"title"];
        body.mediaId = bodyDict[@"fileMessage"][@"mediaId"];
        body.size = [bodyDict[@"fileMessage"][@"size"] longLongValue];
        body.type = bodyDict[@"fileMessage"][@"type"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_FILE;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"CUSTOM"]) {
        SICustomBody *body = [[SICustomBody alloc] init];
        body.body = bodyDict[@"customMessage"][@"body"];
        body.type = bodyDict[@"customMessage"][@"type"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_CUSTOM;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"SYSTEM"]) {
        SISystemBody *body = [[SISystemBody alloc] init];
        body.content = bodyDict[@"systemMessage"][@"content"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_SYSTEM;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"RECALL"]) {
        SIRecallBody *body = [[SIRecallBody alloc]init];
        body.messageId = bodyDict[@"recallMessage"][@"messageId"];
        body.extra = bodyDict[@"extra"];
        message.messageType = SI_MESSAGE_RECALL;
        message.messageBody = body;
    } else if([bodyDict[@"messageType"] isEqualToString:@"REMIND"]) {
        SIRemindBody *body = [[SIRemindBody alloc]init];
        body.extra = bodyDict[@"extra"];
        NSString *identifies = bodyDict[@"remindMessage"][@"identifies"];
        body.identifies = [identifies componentsSeparatedByString:@","];
        body.content = bodyDict[@"remindMessage"][@"content"];
        message.messageType = SI_MESSAGE_REMIND;
        message.messageBody = body;
    }
    else {
        [SakuraLogHelper logFunc:__FUNCTION__ info:@"invalid message type"];
        return ;
    }
}

// MARK: - updateAppSetBadge

+ (void)updateBadge:(NSString *)identify
  withAuthorization:(NSString *_Nonnull)token
          forDevice:(uint)deviceType
           setBadge:(NSInteger)badge
         completion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler{
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completionHandler(false, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:@(badge) forKey:@"badge"];
    [body setValue:@(deviceType) forKey:@"deviceType"];
    [body setValue:identify forKey:@"identify"];
    
    
    NSError *error = nil;
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/device/badge", SakuraConfig.ApiBase];
    NSMutableURLRequest *request = [urlRequestSerialization PutURLRequestSerialization:url withAuthorization:token withBody:body withError:error];
    
    [SakuraHttpClient put:request completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completionHandler(false, error);
        } else {
            completionHandler(true, nil);
        }
    }];
}

+ (void)uploadImage:(NSData *_Nonnull)data
  withAuthorization:(NSString *_Nonnull)token
           progress:(void (^_Nullable)(float progress))progressBlock
         completion:(void (^_Nullable)(BOOL success, SIImageBody * _Nullable body, NSError *_Nullable error))completion {
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completion(false, nil, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSMutableURLRequest *request = [urlRequestSerialization imageURLRequestSerialization:SakuraConfig.FileBase withAuthorization:token];
    NSData *formData = [SakuraFormData imageData:data withRequest:request];
    
    [SakuraHttpClient upload:request withForm:formData progress:progressBlock completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completion(false, nil, error);
        } else {
            //包装SIImageBody
            NSDictionary *dicbody = (NSDictionary *)repsonse;
            SIImageBody *body = [[SIImageBody alloc] init];
            body.mediaId = dicbody[@"fileId"];
            body.thumbMediaId = [NSString stringWithFormat:@"thumb%@", dicbody[@"fileId"]];
            body.size = [dicbody[@"size"] longLongValue];
            body.height = [dicbody[@"height"] intValue];
            body.width = [dicbody[@"width"] intValue];
            //返回包装后的body
            completion(true, body, nil);
        }
    }];
}


+ (void)uploadAudio:(NSData *_Nonnull)data
  withAuthorization:(NSString *_Nonnull)token
           progress:(void (^_Nullable)(float progress))progressBlock
         completion:(void (^_Nullable)(BOOL success, SIVoiceBody * _Nullable body, NSError *_Nullable error))completion {
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completion(false, nil, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSMutableURLRequest *request = [urlRequestSerialization audioURLRequestSerialization:SakuraConfig.FileBase withAuthorization:token];
    NSData *formData = [SakuraFormData voiceData:data withRequest:request];
    [SakuraHttpClient upload:request withForm:formData progress:progressBlock completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completion(false, nil, error);
        } else {
            //包装SIVoiceBody
            NSDictionary *dicbody = (NSDictionary *)repsonse;
            SIVoiceBody *body = [[SIVoiceBody alloc] init];
            body.mediaId = dicbody[@"fileId"];
            body.size = data.length;
            //返回包装后的body
            completion(true, body, nil);
        }
    }];
    
}


+ (void)uploadVideo:(NSData *_Nonnull)data
  withAuthorization:(NSString *_Nonnull)token
           progress:(void (^_Nullable)(float progress))progressBlock
         completion:(void (^_Nullable)(BOOL success, SIShortvideoBody * _Nullable body, NSError *_Nullable error))completion {
    
    if (!token) {
        NSDictionary *userInfo = @{@"desc": @"token is missing"};
        completion(false, nil, [NSError errorWithDomain:@"SakuraApi" code:-1  userInfo:userInfo]);
        return;
    }
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSMutableURLRequest *request = [urlRequestSerialization shortvideoURLRequestSerialization:SakuraConfig.FileBase withAuthorization:token];
    NSData *formData = [SakuraFormData videoData:data withRequest:request];
    [SakuraHttpClient upload:request withForm:formData progress:progressBlock completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completion(false, nil, error);
        } else {
            //包装SIVideoBody
            NSDictionary *dicbody = (NSDictionary *)repsonse;
            SIShortvideoBody *body = [[SIShortvideoBody alloc] init];
            body.mediaId = dicbody[@"fileId"];
            body.thumbMediaId = [NSString stringWithFormat:@"thumb%@", dicbody[@"fileId"]];
            body.size = [dicbody[@"size"] longLongValue];
            body.height = [dicbody[@"height"] intValue];
            body.width = [dicbody[@"width"] intValue];
            //返回包装后的body
            completion(true, body, nil);
        }
    }];
    
}


+ (void)downloadFile:(NSString *_Nonnull)urlString
   withAuthorization:(NSString *_Nonnull)token
              toPath:(NSString *_Nullable)filePath
            progress:(void (^_Nullable)(float progress))progressBlock
          completion:(void (^_Nullable)(BOOL success, NSData * _Nullable data, NSError *_Nullable error))completion {
    
    SakuraURLRequestSerialization *urlRequestSerialization = [[SakuraURLRequestSerialization alloc]init];
    NSMutableURLRequest *request = [urlRequestSerialization downloadURLRequestSerialization:urlString withAuthorization:token];
    [SakuraHttpClient download:request toPath:filePath progress:progressBlock completion:^(BOOL success, NSObject * _Nullable repsonse, NSError * _Nullable error) {
        if (error) {
            completion(false, nil, error);
        } else {
            completion(true, (NSData*)repsonse, nil);
        }
    }];
}


@end
