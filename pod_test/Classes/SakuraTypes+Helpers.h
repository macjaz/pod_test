//
//  SakuraTypes+Utils.h
//  SakuraKit
//
//  Created by keilon on 2018/1/8.
//  Copyright © 2018年 keilon. All rights reserved.
//

#ifndef SakuraTypes_Utils_h
#define SakuraTypes_Utils_h

#import "SakuraTypes.h"
#import "ChatMessageReq.pbobjc.h"
#import "ChatMessageNotify.pbobjc.h"
#import "GroupMessageReq.pbobjc.h"
#import "GroupMessageNotify.pbobjc.h"
#import "SystemMessageNotify.pbobjc.h"
#import "CustomerMessageReq.pbobjc.h"
#import "CustomerMessageReplyNotify.pbobjc.h"
#import "ReceiveStateMessageReq.pbobjc.h"
#import "ReceiveStateMessageNotify.pbobjc.h"
#import "SessionStateMessageReq.pbobjc.h"
#import "SessionStateMessageNotify.pbobjc.h"

@interface SIMessage ()

+ (instancetype)initWithChatMessageReq:(ChatMessageReq *)msg;
+ (instancetype)initWithChatMessageNotify:(ChatMessageNotify *)msg;
+ (instancetype)initWithGroupMessageReq:(GroupMessageReq *)msg;
+ (instancetype)initWithGroupMessageNotify:(GroupMessageNotify *)msg;
+ (instancetype)initWithSystemMessageNotify:(SystemMessageNotify *)msg;
+ (instancetype)initWithCustomerMessageReq:(CustomerMessageReq *)msg;
+ (instancetype)initWithCustomerMessageReplyNotify:(CustomerMessageReplyNotify *)msg;

- (MessageBody *)toMessageBody;
- (NSString *)generateSessionId:(NSString *)one and:(NSString *)another;
- (SIMessageBody *)generateSIMessageBody:(MessageBody *)msgBody;

@end

@interface SIMessageRecvEvent ()

+ (instancetype)initWithRecvStateReq:(ReceiveStateMessageReq *)msg;
+ (instancetype)initWithRecvStateNotify:(ReceiveStateMessageNotify *)msg;

@end

@interface SISessionStateEvent ()

+ (instancetype)initWithSessionStateReq:(SessionStateMessageReq *)msg;
+ (instancetype)initWithSessionStateNotify:(SessionStateMessageNotify *)msg;

@end

@interface SISession ()

- (NSString *)generateSessionId:(NSString *)one and:(NSString *)another;

@end

#endif /* SakuraTypes_Utils_h */
