//
//  SakuraTypes_Utils.m
//  SakuraKit
//
//  Created by keilon on 2018/1/8.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import <objc/runtime.h>
#import "SakuraTypes+Helpers.h"
#import "MessageBody.pbobjc.h"
#import "MessageType.pbobjc.h"
#import "TextMessage.pbobjc.h"
#import "ImageMessage.pbobjc.h"
#import "VoiceMessage.pbobjc.h"
#import "VideoMessage.pbobjc.h"
#import "ShortVideoMessage.pbobjc.h"
#import "CustomMessage.pbobjc.h"
#import "NewsMessage.pbobjc.h"
#import "FileMessage.pbobjc.h"
#import "SystemMessage.pbobjc.h"
#import "RecallMessage.pbobjc.h"
#import "RemindMessage.pbobjc.h"
#import "SakuraLogHelper.h"

const SIMessageStatus SI_MESSAGE_STATUS_UPLOADING    = 1;     // 上传中，对于语音，图片等
const SIMessageStatus SI_MESSAGE_STATUS_SENDING      = 2;     // 发送中
const SIMessageStatus SI_MESSAGE_STATUS_SENT         = 3;     // 发送成功
const SIMessageStatus SI_MESSAGE_STATUS_FAILED       = 4;     // 发送失败
const SIMessageStatus SI_MESSAGE_STATUS_NEEDREPEAT   = 5;     // 由于网络问题没有发送出去,需要再次尝试
const SIMessageStatus SI_MESSAGE_STATUS_CREATING     = 6;     // 创建中,草稿
const SIMessageStatus SI_MESSAGE_STATUS_ARRIVED      = 7;     // 已送达
const SIMessageStatus SI_MESSAGE_STATUS_UPLOADFAILED = 8;     // 上传失败，对于语音，图片等
const SIMessageStatus SI_MESSAGE_STATUS_UNREAD       = 10;    // 未读
const SIMessageStatus SI_MESSAGE_STATUS_READ         = 11;    // 已读
const SIMessageStatus SI_MESSAGE_STATUS_UNKNOW       = 0;     // 不存在此消息

const SIMessageRecvState SI_MESSAGE_RECV_DELIVERED = 0x01; //已送达（消息已经送达至接收方）
const SIMessageRecvState SI_MESSAGE_RECV_DISPLAYED = 0x02; //已读
const SIMessageRecvState SI_MESSAGE_RECV_ACCEPTED  = 0x04; //已接收

@implementation SIMessageBody

+ (instancetype _Nullable)bodyWithJson:(NSString * _Nullable)data
                              withType:(SIMessageType) type {
    
    NSData *getJsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *bodyDict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error: &jsonError];
    
    switch (type) {
        case SI_MESSAGE_TEXT: {
            SIMessageBody *this = [[SITextBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_IMAGE: {
            SIMessageBody *this = [[SIImageBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_VOICE: {
            SIMessageBody *this = [[SIVoiceBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_VIDEO: {
            SIMessageBody *this = [[SIVideoBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_SHORTVIDEO: {
            SIMessageBody *this = [[SIShortvideoBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_NEWS: {
            SIMessageBody *this = [[SINewsBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_FILE: {
            SIMessageBody *this = [[SIFileBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_CUSTOM: {
            SIMessageBody *this = [[SICustomBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_SYSTEM: {
            SIMessageBody *this = [[SISystemBody alloc] init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_RECALL: {
            SIMessageBody *this = [[SIRecallBody alloc]init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
        case SI_MESSAGE_REMIND: {
            SIRemindBody *this = [[SIRemindBody alloc]init];
            [this setValuesForKeysWithDictionary:bodyDict];
            return this;
        }
    }
}

- (void)addPropsForClassHierarchy:(NSMutableDictionary*)propsDictionary {
    
    Class superClass = self.superclass;
    
    while(superClass && [NSObject class] != superClass) {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(superClass, &count);
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
            if ([self valueForKey:key] != nil) {
                [propsDictionary setObject:[self valueForKey:key] forKey:key];
            }
        }
        free(properties);
        
        superClass = [superClass superclass];
    }
    
}

- (NSString *_Nullable)toJson {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    //add inherited property
    [self addPropsForClassHierarchy:dict];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([self valueForKey:key] != nil) {
            [dict setObject:[self valueForKey:key] forKey:key];
        }
    }
    free(properties);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation SITextBody
@end

@implementation SIImageBody
@end

@implementation SIVoiceBody
@end

@implementation SIVideoBody
@end

@implementation SIShortvideoBody
@end

@implementation SINewsBody
@end

@implementation SIFileBody
@end

@implementation SICustomBody
@end

@implementation SISystemBody
@end


@implementation SIRecallBody
@end

@implementation SIRemindBody
@end

@implementation SIMessageRecvEvent

- (instancetype)init {
    return [super init];
}
+ (instancetype)initWithRecvStateReq:(ReceiveStateMessageReq *)msg {
    SIMessageRecvEvent *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    if ([msg.sessionType isEqualToString:@"CHAT"]) {
        this.sessionType = SI_SESSION_CHAT;
    } else if ([msg.sessionType isEqualToString:@"GROUP"]) {
        this.sessionType = SI_SESSION_GROUP;
    } else if ([msg.sessionType isEqualToString:@"SYSTEM"]) {
        this.sessionType = SI_SESSION_SYSTEM;
    }
    this.senderId = msg.from;
    this.receiverId = msg.to;
    this.recvState = msg.eventType;
    this.targetMessageId = msg.eventTargetId;
    this.domain = msg.domain;
    
    return this;
}

+ (instancetype)initWithRecvStateNotify:(ReceiveStateMessageNotify *)msg {
    SIMessageRecvEvent *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    if ([msg.sessionType isEqualToString:@"CHAT"]) {
        this.sessionType = SI_SESSION_CHAT;
    } else if ([msg.sessionType isEqualToString:@"GROUP"]) {
        this.sessionType = SI_SESSION_GROUP;
    } else if ([msg.sessionType isEqualToString:@"SYSTEM"]) {
        this.sessionType = SI_SESSION_SYSTEM;
    }
    this.senderId = msg.from;
    this.receiverId = msg.to;
    this.recvState = msg.eventType;
    this.targetMessageId = msg.eventTargetId;
    this.domain = msg.domain;
    
    return this;
}

@end

@implementation SISessionStateEvent

- (instancetype)init {
    return [super init];
}
+ (instancetype)initWithSessionStateReq:(SessionStateMessageReq *)msg {
    SISessionStateEvent *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    if ([msg.sessionType isEqualToString:@"CHAT"]) {
        this.sessionType = SI_SESSION_CHAT;
        this.sessionMain = msg.to; //单聊会话同步，sessionMain 和 to 一致
    } else if ([msg.sessionType isEqualToString:@"GROUP"]) {
        this.sessionType = SI_SESSION_GROUP;
        this.sessionMain = msg.sessionId;
    } else if ([msg.sessionType isEqualToString:@"SYSTEM"]) {
        this.sessionType = SI_SESSION_SYSTEM;
        this.sessionMain = msg.sessionId;
    }
    this.senderId = msg.from;
    this.state = msg.state;
    this.domain = msg.domain;
    this.extra = msg.extra;
    
    return this;
}

+ (instancetype)initWithSessionStateNotify:(SessionStateMessageNotify *)msg{
    SISessionStateEvent *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    if ([msg.sessionType isEqualToString:@"CHAT"]) {
        this.sessionType = SI_SESSION_CHAT;
        this.sessionMain = msg.from; //单聊会话事件 sessionMain 和 from 一致
    } else if ([msg.sessionType isEqualToString:@"GROUP"]) {
        this.sessionType = SI_SESSION_GROUP;
         this.sessionMain = msg.sessionId;
    } else if ([msg.sessionType isEqualToString:@"SYSTEM"]) {
        this.sessionType = SI_SESSION_SYSTEM;
         this.sessionMain = msg.sessionId;
    }
    this.senderId = msg.from;
    this.state = msg.state;
    this.domain = msg.domain;
    this.extra = msg.extra;
    
    return this;
}
@end

@implementation SIMessage

- (instancetype)init {
    return [super init];
}

- (NSString *)generateSessionId:(NSString *)one and:(NSString *)another {
    if (NSOrderedAscending == [one compare:another]) {
        return [NSString stringWithFormat:@"%@%@", one, another];
    } else {
        return [NSString stringWithFormat:@"%@%@", another, one];
    }
}

- (SIMessageBody *)generateSIMessageBody:(MessageBody *)msgBody {
    switch (msgBody.messageType) {
        case MessageType_Text: {
            SITextBody *body = [[SITextBody alloc] init];
            body.content =  msgBody.textMessage.content;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_Image: {
            SIImageBody *body = [[SIImageBody alloc] init];
            body.mediaId = msgBody.imageMessage.mediaId;
            body.thumbMediaId = msgBody.imageMessage.thumbMediaId;
            body.height = msgBody.imageMessage.height;
            body.width = msgBody.imageMessage.width;
            body.size = msgBody.imageMessage.size;
            body.title = msgBody.imageMessage.title;
            body.type = msgBody.imageMessage.type;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_File: {
            SIFileBody *body = [[SIFileBody alloc] init];
            body.mediaId = msgBody.fileMessage.mediaId;
            body.size = msgBody.fileMessage.size;
            body.title = msgBody.fileMessage.title;
            body.type = msgBody.fileMessage.type;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_News: {
            SINewsBody *body = [[SINewsBody alloc] init];
            body.desc = msgBody.newsMessage.description_p;
            body.linkurl = msgBody.newsMessage.URL;
            body.title = msgBody.newsMessage.title;
            body.picurl = msgBody.newsMessage.picurl;
            body.extra = msgBody.extra;

            return body;
        }
        case  MessageType_Video: {
            SIVideoBody *body = [[SIVideoBody alloc] init];
            body.duration = msgBody.videoMessage.duration;
            body.mediaId = msgBody.videoMessage.mediaId;
            body.size = msgBody.videoMessage.size;
            body.thumbMediaId = msgBody.videoMessage.thumbMediaId;
            body.height = msgBody.videoMessage.height;
            body.width = msgBody.videoMessage.width;
            body.title = msgBody.videoMessage.title;
            body.type = msgBody.videoMessage.type;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_Voice: {
            SIVoiceBody *body = [[SIVoiceBody alloc] init];
            body.duration = msgBody.voiceMessage.duration;
            body.mediaId = msgBody.voiceMessage.mediaId;
            body.size = msgBody.voiceMessage.size;
            body.type = msgBody.voiceMessage.type;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_Custom: {
            SICustomBody *body = [[SICustomBody alloc] init];
            body.type = msgBody.customMessage.type;
            body.body = msgBody.customMessage.body;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_System: {
            SISystemBody *body = [[SISystemBody alloc] init];
            body.content = msgBody.systemMessage.content;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_Shortvideo: {
            SIShortvideoBody *body = [[SIShortvideoBody alloc] init];
            body.mediaId = msgBody.shortVideoMessage.mediaId;
            body.size = msgBody.shortVideoMessage.size;
            body.thumbMediaId = msgBody.shortVideoMessage.thumbMediaId;
            body.duration = msgBody.shortVideoMessage.duration;
            body.height = msgBody.shortVideoMessage.height;
            body.width = msgBody.shortVideoMessage.width;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_Recall: {
            SIRecallBody *body = [[SIRecallBody alloc]init];
            body.messageId = msgBody.recallMessage.messageId;
            body.extra = msgBody.extra;

            return body;
        }
        case MessageType_Remind: {
            SIRemindBody *body = [[SIRemindBody alloc]init];
            body.content = msgBody.remindMessage.content;
            body.identifies = [msgBody.remindMessage.identifies componentsSeparatedByString:@","];
            body.extra = msgBody.extra;

            return body;
        }
        default: {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"收到一条新消息，格式暂时不支持, type = %d", msgBody.messageType]];
            return nil;
        }
    }
}

- (MessageBody *)toMessageBody {
    MessageBody *body = [[MessageBody alloc] init];
    body.extra = _messageBody.extra;
    body.requestEvent = _requestEvent;
    switch (_messageType) {
        case SI_MESSAGE_TEXT: {
            body.messageType = MessageType_Text;
            body.textMessage.content = ((SITextBody*)_messageBody).content;
            break;
        }
        case SI_MESSAGE_IMAGE: {
            body.messageType = MessageType_Image;
            SIImageBody *image = (SIImageBody*)_messageBody;
            body.imageMessage.mediaId = image.mediaId;
            body.imageMessage.thumbMediaId = image.thumbMediaId;
            body.imageMessage.height = image.height;
            body.imageMessage.width = image.width;
            body.imageMessage.size = image.size;
            body.imageMessage.title = image.title;
            body.imageMessage.type = image.type;
            break;
        }
        case SI_MESSAGE_VOICE: {
            body.messageType = MessageType_Voice;
            SIVoiceBody *voice = (SIVoiceBody*)_messageBody;
            body.voiceMessage.duration = voice.duration;
            body.voiceMessage.size = voice.size;
            body.voiceMessage.mediaId = voice.mediaId;
            body.voiceMessage.type = voice.type;
            break;
        }
        case SI_MESSAGE_VIDEO: {
            body.messageType = MessageType_Video;
            SIVideoBody *video = (SIVideoBody*)_messageBody;
            body.videoMessage.duration = video.duration;
            body.videoMessage.mediaId = video.mediaId;
            body.videoMessage.size = video.size;
            body.videoMessage.thumbMediaId = video.thumbMediaId;
            body.videoMessage.title = video.title;
            body.videoMessage.type = video.type;
            body.videoMessage.height = video.height;
            body.videoMessage.width = video.width;
            break;
        }
        case SI_MESSAGE_SHORTVIDEO: {
            body.messageType = MessageType_Shortvideo;
            SIShortvideoBody * shortvideo = (SIShortvideoBody*)_messageBody;
            body.shortVideoMessage.duration = shortvideo.duration;
            body.shortVideoMessage.mediaId = shortvideo.mediaId;
            body.shortVideoMessage.size = shortvideo.size;
            body.shortVideoMessage.thumbMediaId = shortvideo.thumbMediaId;
            body.shortVideoMessage.height = shortvideo.height;
            body.shortVideoMessage.width = shortvideo.width;
            break;
        }
        case SI_MESSAGE_NEWS: {
            body.messageType = MessageType_News;
            SINewsBody *news = (SINewsBody*)_messageBody;
            body.newsMessage.description_p = news.desc;
            body.newsMessage.picurl = news.picurl;
            body.newsMessage.title = news.title;
            body.newsMessage.URL = news.linkurl;
            break;
        }
        case SI_MESSAGE_FILE: {
            body.messageType = MessageType_File;
            SIFileBody *file = (SIFileBody*)_messageBody;
            body.fileMessage.mediaId = file.mediaId;
            body.fileMessage.type = file.type;
            body.fileMessage.size = file.size;
            body.fileMessage.title  = file.title;
            break;
        }
        case SI_MESSAGE_CUSTOM: {
            body.messageType = MessageType_Custom;
            SICustomBody *custom = (SICustomBody*)_messageBody;
            body.customMessage.type = custom.type;
            body.customMessage.body = custom.body;
            break;
        }
        case SI_MESSAGE_SYSTEM: {
            body.messageType = MessageType_System;
            SISystemBody *system = (SISystemBody*)_messageBody;
            body.systemMessage.content = system.content;
            break;
        }
        case SI_MESSAGE_RECALL: {
            body.messageType = MessageType_Recall;
            SIRecallBody *recall = (SIRecallBody *)_messageBody;
            body.recallMessage.messageId = recall.messageId;
            break;
        }
        case SI_MESSAGE_REMIND: {
            body.messageType = MessageType_Remind;
            SIRemindBody *remind = (SIRemindBody *)_messageBody;
            body.remindMessage.content = remind.content;
            body.remindMessage.identifies = [[remind.identifies valueForKey:@"description"] componentsJoinedByString:@","];
            break;
        }
    }
    return body;
}

+ (instancetype)initWithChatMessageReq:(ChatMessageReq *)msg {
    SIMessage *this = [[self alloc] init];
    this.sessionId = [this generateSessionId:msg.from and:msg.to];
    this.sessionMain = msg.to;
    this.sessionLabel = msg.targetLabel;
    this.sessionType = SI_SESSION_CHAT;
    this.senderId = msg.from;
    this.senderLabel = msg.sourceLabel;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}

+ (instancetype)initWithChatMessageNotify:(ChatMessageNotify *)msg {
    SIMessage *this = [[self alloc] init];
    this.sessionId = [this generateSessionId:msg.from and:msg.to];
    this.sessionMain = msg.from;
    this.sessionLabel = msg.sourceLabel;
    this.sessionType = SI_SESSION_CHAT;
    this.senderId = msg.from;
    this.senderLabel = msg.sourceLabel;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}

+ (instancetype)initWithGroupMessageReq:(GroupMessageReq *)msg {
    SIMessage *this = [[self alloc] init];
    this.sessionId = msg.groupId;
    this.sessionMain = msg.groupId;
    this.sessionLabel = msg.targetLabel;
    this.sessionType = SI_SESSION_GROUP;
    this.senderId = msg.from;
    this.senderLabel = msg.sourceLabel;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}

+ (instancetype)initWithGroupMessageNotify:(GroupMessageNotify *)msg {
    SIMessage *this = [[self alloc] init];
    this.sessionId = msg.groupId;
    this.sessionMain = msg.groupId;
    this.sessionLabel = msg.targetLabel;
    this.sessionType = SI_SESSION_GROUP;
    this.senderId = msg.from;
    this.senderLabel = msg.sourceLabel;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}

+ (instancetype)initWithSystemMessageNotify:(SystemMessageNotify *)msg {
    // 用户接收的系统通知
    SIMessage *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    this.sessionMain = msg.sessionId;
    this.sessionLabel = msg.sessionLabel;
    this.sessionType = SI_SESSION_SYSTEM;
    this.sessionCategory = msg.sessionType;
    this.senderId = msg.sessionId;
    this.senderLabel = msg.sessionLabel;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageSourceType = @"SYSTEM";
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}

+ (instancetype)initWithCustomerMessageReq:(CustomerMessageReq *)msg {
    // 用户发送的客服消息请求
    SIMessage *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    this.sessionMain = msg.sessionId;
    this.sessionLabel = msg.sessionLabel;
    this.sessionType = SI_SESSION_SYSTEM;
    // 客服消息协议属于系统会话，其中的 sessionType 表示系统会话具体分类
    this.sessionCategory = msg.sessionType;
    this.senderLabel = msg.fromLabel;
    this.senderId = msg.from;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageSourceType = @"CUSTOMER";
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}

+ (instancetype)initWithCustomerMessageReplyNotify:(CustomerMessageReplyNotify *)msg {
    // 用户接收的客服消息应答
    SIMessage *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    this.sessionMain = msg.sessionId;
    this.sessionLabel = msg.sessionLabel;
    this.sessionType = SI_SESSION_SYSTEM;
    // 客服消息协议属于系统会话，其中的 sessionType 表示系统会话具体分类
    this.sessionCategory = msg.sessionType;
    this.senderId = msg.sessionId;
    this.senderLabel = msg.sessionLabel;
    this.messageId = msg.messageId;
    this.messageType = msg.body.messageType;
    this.messageSourceType = @"CUSTOMER";
    this.messageBody = [this generateSIMessageBody:msg.body];
    this.messageTS = [[NSDate date] timeIntervalSince1970];
    this.domain = msg.domain;
    this.requestEvent = msg.body.requestEvent;
    return this;
}


@end

@implementation SISession

- (instancetype)init {
    return [super init];
}

- (NSString *)generateSessionId:(NSString *)one and:(NSString *)another {
    if (NSOrderedAscending == [one compare:another]) {
        return [NSString stringWithFormat:@"%@%@", one, another];
    } else {
        return [NSString stringWithFormat:@"%@%@", another, one];
    }
}

+ (instancetype)initWithSIMessage:(SIMessage *)msg {
    SISession *this = [[self alloc] init];
    this.sessionId = msg.sessionId;
    this.sessionMain = msg.sessionMain;
    this.sessionLabel = msg.sessionLabel;
    this.sessionType = msg.sessionType;
    this.sessionCategory = msg.sessionCategory;
    this.lastSenderId = msg.senderId;
    this.lastSenderLabel = msg.senderLabel;
    this.lastMessageId = msg.messageId;
    this.lastMessageType = msg.messageType;
    this.lastMessageSourceType = msg.messageSourceType;
    this.lastMessageBody = msg.messageBody;
    this.lastMessageTS = msg.messageTS;
    return this;
}

@end
