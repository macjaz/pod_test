//
//  SakuraMessage.m
//  SakuraKit
//
//  Created by keilon on 2018/1/5.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraIO.h"
#import "SakuraMessage.h"
#import "SakuraApi.h"
#import "SakuraTypes+Helpers.h"
#import "ProtocolType.pbobjc.h"
#import "ConnectReq.pbobjc.h"
#import "ConnectReqAck.pbobjc.h"
#import "HeartbeatReq.pbobjc.h"
#import "HeartbeatReqAck.pbobjc.h"
#import "DisconnectNotify.pbobjc.h"
#import "SakuraReachability.h"
#import "SakuraLogHelper.h"
#import "SakuraConfig.h"

#define DISPATCH_MAIN_ASYNC(...) dispatch_async(dispatch_get_main_queue(), (__VA_ARGS__))
#define DISPATCH_GLOBAL_ASYNC(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), (__VA_ARGS__))

@interface SakuraMessage () <SakuraIODelegate>

///appId
@property(nonatomic, strong) NSString * _Nullable appId;
///用户token
@property(nonatomic, strong) NSString * _Nullable token;
///用户identify
@property(nonatomic, strong) NSString * _Nullable identify;
///会话的标签
@property(nonatomic, strong) NSString * _Nullable label;
///消息服务器host
@property(nonatomic, strong) NSString * _Nullable msgHost;
///消息服务器port
@property(nonatomic) unsigned int msgPort;
///文件服务器host
@property(nonatomic, strong) NSString * _Nullable fileHost;
///文件服务器port
@property(nonatomic) unsigned int filePort;
///socket
@property(nonatomic, strong) SakuraIO * _Nullable io;
///heartBeat timer
@property(nonatomic, strong) NSTimer * _Nullable heartBeatTimer;
///connect status
@property(nonatomic) SIConnStatus connStatus;
///network reachability
@property(nonatomic, strong) SakuraReachability * _Nullable hostReachability;

@end

@implementation SakuraMessage

static id _sharedInstance;

+ (instancetype)sharedInstance {
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    NSAssert(_sharedInstance == nil, @"Only one instance of SakuraMessage should be created. Use +[SakuraMessage sharedInstance] instead.");
    self = [super init];
    return self;
}

+ (void)setEnableLog:(BOOL)logFlag {
    [SakuraLogHelper setLogFlag:logFlag];
}

+ (void)configSakura:(NSString * _Nonnull)identify
               label:(NSString * _Nonnull)label
               token:(NSString * _Nonnull)token
               appId:(NSString * _Nonnull)appId
           msgServer:(NSDictionary * _Nonnull)msgServer {
    
    NSAssert(appId && identify && label && token, @"Miss Parameter, please check your Parameters like appId, identify, label, token");
    NSAssert([msgServer objectForKey:@"ip"] && [msgServer objectForKey:@"port"], @"msgServer configuration error");
    
    SakuraMessage * this = [SakuraMessage sharedInstance];
    this.appId = appId;
    this.identify = identify;
    this.label = label;
    this.token = token;
    this.msgHost = msgServer[@"ip"];
    this.msgPort = [(NSString *)(msgServer[@"port"]) componentsSeparatedByString:@","][0].intValue;
    
    this.connStatus = SI_CONN_DISCONNECT;
}

+ (void)clearConfigSakura{
    
    SakuraMessage * this = [SakuraMessage sharedInstance];
    this.appId = nil;
    this.identify = nil;
    this.label = nil;
    this.token = nil;
    this.msgHost = nil;
    this.msgPort = 0;
    [this changeConnStatus:SI_CONN_DISCONNECT];
    if (this.io) {
        [this.io close];
        this.io = nil;
    }
}

+ (void)configServer:(NSString * _Nonnull)apiBase
            fileBase:(NSString * _Nonnull)fileBase {
    [SakuraConfig setApiBase: apiBase];
    [SakuraConfig setFileBase: fileBase];
}

+ (void)connectSakura {
    SakuraMessage * this = [SakuraMessage sharedInstance];
    
    NSAssert(this.appId && this.identify && this.label && this.token && this.msgHost && this.msgPort , @"Miss Parameter, please check your Parameters like appId, identify, label, token, msgHost, msgPort");
    //init Reachability
    [this initReachability];
    [this doConnect];
}


+ (BOOL)disconnectSakura {
    SakuraMessage * this = [SakuraMessage sharedInstance];
    [this changeConnStatus:SI_CONN_DISCONNECT];
    [this destroyHeartBeatTimer];
    [this destroyReachability];
    
    if (!this.io) {
        return false;
    }
    
    //    [SakuraApi updateSyncTime:this.identify withAuthorization:this.token forDevice:SI_DEVICE_IOS completion:^(BOOL success, NSError * _Nullable error) {
    //        if (!success) {
    //            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"更新消息同步时间失败，%@", error.description]];
    //        }
    //    }];
    
    return [this.io close];
}

+ (void)registerDeviceToken:(NSData *_Nullable)deviceToken {
    [SakuraMessage registerDeviceToken:deviceToken useSandbox:false];
}

+ (void)registerDeviceToken:(NSData *_Nullable)deviceToken
                 useSandbox:(BOOL)useSandbox; {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    SakuraMessage * this = [SakuraMessage sharedInstance];
    [SakuraApi updateDeviceToken:this.identify withAuthorization:this.token deviceToken:token forDevice:SAKURA_DEVICE_IOS useSandbox:useSandbox completion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"更新deviceToken失败，%@", error.description]];
        }
    }];
}


+ (BOOL)setBadge:(NSInteger)value{
    SakuraMessage *this = [SakuraMessage sharedInstance];
    [SakuraApi updateBadge:this.identify withAuthorization:this.token forDevice:SAKURA_DEVICE_IOS setBadge:value completion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"更新badge失败，%@", error.description]];
        }
    }];
    
    return true;
}

+ (void)resetBadge {
    [SakuraMessage setBadge:0];
}

+ (NSString *_Nonnull)getImageResource: (NSString * _Nonnull)mediaId {
    return [NSString stringWithFormat:@"%@/%@", SakuraConfig.FileBase, mediaId];
}

+ (NSString *_Nonnull)getVideoResource: (NSString * _Nonnull)mediaId{
    return [NSString stringWithFormat:@"%@/%@", SakuraConfig.FileBase, mediaId];
}


+ (SISession *_Nullable)createSession:(SISessionType )sessionType
                          sessionMain:(NSString * _Nonnull)sessionMain {
    SISession* session = [[SISession alloc] init];
    session.sessionType = sessionType;
    session.sessionMain = sessionMain;
    switch (sessionType) {
        case SI_SESSION_CHAT: {
            session.sessionId = [session generateSessionId:sessionMain and:[SakuraMessage sharedInstance].identify];
            return session;
        }
        case SI_SESSION_GROUP: {
            session.sessionId = sessionMain;
            return session;
        }
        case SI_SESSION_SYSTEM: {
            session.sessionId = sessionMain;
            return session;
        }
        default: {
            [SakuraLogHelper logFunc:__FUNCTION__ info:@"session type error"];
            return nil;
        }
    }
}

- (void)doConnect {
    
    @synchronized (self) {
        if (_connStatus == SI_CONN_CONNECTING) {
            [SakuraLogHelper logFunc:__FUNCTION__ info:@"connecting, no need to do connect"];
            return;
        }
        
        if (!_msgHost || (_msgPort == 0)) {
            [SakuraLogHelper logFunc:__FUNCTION__ info:@"sakura miss connect parameter"];
            return;
        }
        
        [self changeConnStatus:SI_CONN_CONNECTING];
    }
    
    [SakuraLogHelper logFunc:__FUNCTION__ info:@"connecting..."];
    [self destroyHeartBeatTimer];
    
    if (_io) {
        [_io close];
        _io = nil;
    }
    
    _io = [SakuraIO ioWithHost:_msgHost on:_msgPort];
    _io.delegate = self;
    
    [_io connect];
    
}

- (void)reconnect {
    
    //网络不可用，设置为 DISCONNECT 后返回
    if (_hostReachability.currentReachabilityStatus == NotReachable) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:@" Skipped for network not reachable"];
        [self changeConnStatus: SI_CONN_DISCONNECT];
        return;
    }
    
    DISPATCH_GLOBAL_ASYNC(^{
        //网络不可用，设置为 DISCONNECT 后返回
        if (self->_hostReachability.currentReachabilityStatus == NotReachable) {
            [self changeConnStatus: SI_CONN_DISCONNECT];
            return;
        }
        
        [SakuraLogHelper logFunc:__FUNCTION__ info:@" Start reconnect... "];
        [self doConnect];
    });
}

- (void)sendConnectReq {
    
    Protocol_Class *message = [[Protocol_Class alloc] init];
    message.protocolType = ProtocolType_ComConnectReq;
    message.connectReq.token = _token;
    message.connectReq.identify = _identify;
    message.connectReq.deviceType = SAKURA_DEVICE_IOS;
    
    [_io sendMessage:message];
    
}

- (void)sendHeartBeat {
    Protocol_Class *message = [[Protocol_Class alloc] init];
    message.protocolType = ProtocolType_ComHeartbeatReq;
    message.heartbeatReq.heartbeatId = [[[NSUUID UUID] UUIDString] lowercaseString];
    message.heartbeatReq.from = _identify;
    message.heartbeatReq.deviceType = SAKURA_DEVICE_IOS;
    
    [_io sendMessage:message];
    
}

- (void)initHeartBeatTimer {
    
    [self destroyHeartBeatTimer];
    
    DISPATCH_GLOBAL_ASYNC(^{
        
        self->_heartBeatTimer = [NSTimer timerWithTimeInterval:30
                                                  target:self
                                                selector:@selector(sendHeartBeat)
                                                userInfo:nil
                                                 repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self->_heartBeatTimer forMode:NSDefaultRunLoopMode];
    });
}

- (void)destroyHeartBeatTimer {
    if (_heartBeatTimer) {
        [_heartBeatTimer invalidate];
        _heartBeatTimer = nil;
    }
}

- (void)changeConnStatus:(SIConnStatus)status {
    [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"sakura connection status:%d", status]];
    if (_connStatus != status) {
        _connStatus = status;
        DISPATCH_MAIN_ASYNC(^{
            if (self.delegate && [self.delegate respondsToSelector: @selector(onConnStatusChange:)]) {
                [self.delegate onConnStatusChange:self->_connStatus];
            }
        });
    }
}

- (void)fetchOfflineMessage {
    DISPATCH_GLOBAL_ASYNC(^{
        [SakuraApi fetchOfflineMessage:self->_identify withAuthorization:self->_token forDevice:SAKURA_DEVICE_IOS completion:^(BOOL success, NSArray * _Nullable messageList, NSError * _Nullable error) {
            if (success) {
                [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"收到离线消息, count:%ld", messageList.count]];
                DISPATCH_MAIN_ASYNC(^{ [self->_delegate onSyncOfflineMessage:messageList]; });
                
                [SakuraApi updateSyncTime:self->_identify withAuthorization:self->_token forDevice:SAKURA_DEVICE_IOS completion:^(BOOL success, NSError * _Nullable error) {
                    if (!success) {
                        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"更新消息同步时间失败, %@", error.description]];
                    }
                }];
            } else {
                [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"同步离线消息失败, %@", error.description]];
            }
        }];
    });
}


- (void)getHistoryMessage:(void (^ _Nullable)(NSArray * _Nullable messageList, NSError * _Nullable error))completionHandler {
    [SakuraApi fetchHistoryMessage:_identify withAuthorization:_token forDevice:SAKURA_DEVICE_IOS completion:^(NSArray * _Nullable messageList, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, error);
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"拉取历史消息失败, %@", error.description]];
        } else {
            completionHandler(messageList, nil);
        }
    }];
}


- (void)getReceiptMessage:(NSArray * _Nonnull)messageIds completion:(void (^ _Nullable)(NSDictionary * _Nullable messageDictionary, NSError * _Nullable error))completionHandler {
    [SakuraApi fetchReceiptMessage:messageIds identify:_identify withAuthorization:_token completion:^(NSDictionary * _Nullable messageDictionary, NSError * _Nullable error) {
        completionHandler(messageDictionary, error);
    }];
}

- (void)initReachability {
    
    [self destroyReachability];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kSakuraNetworkChangedNotification
                                               object:nil];
    self->_hostReachability = [SakuraReachability reachabilityWithHostName:@"apple.com"];
    [self->_hostReachability startNotifier];
}

- (void)destroyReachability {
    if (_hostReachability) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kSakuraNetworkChangedNotification
                                                      object:nil];
        [self->_hostReachability stopNotifier];
        self->_hostReachability = nil;
    }
}
        
- (void)reachabilityChanged:(NSNotification *)note {
    SakuraReachability* curReach = [note object];
    if ([curReach currentReachabilityStatus] == ReachableViaWiFi) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:@"sakura network reachable via WiFi"];
        [self reconnect];
    } else if ([curReach currentReachabilityStatus ] == ReachableViaWWAN){
        [SakuraLogHelper logFunc:__FUNCTION__ info:@"sakura network reachable via WWAN"];
        [self reconnect];
    } else {
        [SakuraLogHelper logFunc:__FUNCTION__ info:@"sakura network not reachable"];
        [self changeConnStatus:SI_CONN_DISCONNECT];
        [self destroyHeartBeatTimer];
        if (_io) {
            [_io close];
        }
    }
}


- (void)sendMessage:(SIMessage * _Nonnull)message {
    Protocol_Class *packet = [[Protocol_Class alloc] init];
    NSString * msgId = message.messageId ? message.messageId : [[[NSUUID UUID] UUIDString] lowercaseString];
    switch (message.sessionType) {
        case SI_SESSION_CHAT: {
            packet.protocolType = ProtocolType_ComChatMessageReq;
            packet.chatMessageReq.messageId = msgId;
            packet.chatMessageReq.from = _identify;
            packet.chatMessageReq.to = message.sessionMain;
            packet.chatMessageReq.deviceType = SAKURA_DEVICE_IOS;
            packet.chatMessageReq.sourceLabel = _label;
            packet.chatMessageReq.targetLabel = message.sessionLabel;
            packet.chatMessageReq.body = message.toMessageBody;
            packet.chatMessageReq.domain = _appId;
            break;
        }
        case SI_SESSION_GROUP: {
            packet.protocolType = ProtocolType_ComGroupMessageReq;
            packet.groupMessageReq.messageId = msgId;
            packet.groupMessageReq.from = _identify;
            packet.groupMessageReq.groupId = message.sessionMain;
            packet.groupMessageReq.deviceType = SAKURA_DEVICE_IOS;
            packet.groupMessageReq.body = message.toMessageBody;
            packet.groupMessageReq.sourceLabel = _label;
            packet.groupMessageReq.targetLabel = message.sessionLabel;
            packet.groupMessageReq.domain = _appId;
            break;
        }
        case SI_SESSION_SYSTEM: {
            packet.protocolType = ProtocolType_ComCustomerMessageReq;
            packet.customerMessageReq.messageId = msgId;
            packet.customerMessageReq.sessionId = message.sessionMain;
            packet.customerMessageReq.sessionLabel = message.sessionLabel;
            //客服消息协议属于系统会话，其中的 sessionType 表示系统会话具体分类
            packet.customerMessageReq.sessionType = message.sessionCategory;
            packet.customerMessageReq.from = _identify;
            packet.customerMessageReq.fromLabel = _label;
            packet.customerMessageReq.deviceType = SAKURA_DEVICE_IOS;
            packet.customerMessageReq.body = message.toMessageBody;
            packet.customerMessageReq.domain = _appId;
            break;
        }
            
        default: {
            [SakuraLogHelper logFunc:__FUNCTION__ info:@"session type error"];
            return;
        }
    }
    @try {
        [_io sendMessage:packet];
    }
    @catch (NSException * e) {
        DISPATCH_MAIN_ASYNC(^{
            if (self.delegate && [self.delegate respondsToSelector: @selector(onSentMessage:result:)]) {
                [self.delegate onSentMessage:message result:false];
            }
        });
    }
}

- (void)sendMessageAck:(SIMessageRecvEvent * _Nonnull)messageRecvEvent {
    Protocol_Class *packet = [[Protocol_Class alloc] init];
    packet.protocolType = ProtocolType_ComReceiveStateMessageReq;
    packet.receiveStateMessageReq.messageId = [[[NSUUID UUID] UUIDString] lowercaseString];
    packet.receiveStateMessageReq.sessionId = messageRecvEvent.sessionId;
    if (SI_SESSION_CHAT == messageRecvEvent.sessionType) {
        packet.receiveStateMessageReq.sessionType = @"CHAT";
    } else if (SI_SESSION_GROUP == messageRecvEvent.sessionType) {
        packet.receiveStateMessageReq.sessionType = @"GROUP";
    } else if (SI_SESSION_SYSTEM == messageRecvEvent.sessionType) {
        packet.receiveStateMessageReq.sessionType = @"SYSTEM";
    }
    packet.receiveStateMessageReq.from = _identify;
    packet.receiveStateMessageReq.to = messageRecvEvent.receiverId;
    packet.receiveStateMessageReq.deviceType = SAKURA_DEVICE_IOS;
    packet.receiveStateMessageReq.eventType = messageRecvEvent.recvState;
    packet.receiveStateMessageReq.eventTargetId = messageRecvEvent.targetMessageId;
    packet.receiveStateMessageReq.domain = _appId;
    
    [_io sendMessage:packet];
}

- (void)sendSessionState:(SISessionStateEvent * _Nonnull)sessionStateEvent {
    Protocol_Class *packet = [[Protocol_Class alloc] init];
    packet.protocolType = ProtocolType_ComSessionStateMessageReq;
    packet.sessionStateMessageReq.messageId = [[[NSUUID UUID] UUIDString] lowercaseString];
    packet.sessionStateMessageReq.sessionId = sessionStateEvent.sessionId;
    if (SI_SESSION_CHAT == sessionStateEvent.sessionType) {
        packet.sessionStateMessageReq.sessionType = @"CHAT";
    } else if (SI_SESSION_GROUP == sessionStateEvent.sessionType) {
        packet.sessionStateMessageReq.sessionType = @"GROUP";
    } else if (SI_SESSION_SYSTEM == sessionStateEvent.sessionType) {
        packet.sessionStateMessageReq.sessionType = @"SYSTEM";
    }
    packet.sessionStateMessageReq.from = _identify;
    packet.sessionStateMessageReq.to = sessionStateEvent.sessionMain;
    packet.sessionStateMessageReq.deviceType = SAKURA_DEVICE_IOS;
    packet.sessionStateMessageReq.state = sessionStateEvent.state;
    packet.sessionStateMessageReq.extra = sessionStateEvent.extra;
    packet.sessionStateMessageReq.domain = _appId;
    
    [_io sendMessage:packet];
}


- (void)uploadImage:(UIImage *_Nullable)aImage
           progress:(void (^ _Nullable)(float progress))progressBlock
         completion:(void (^ _Nullable)(SIImageBody * _Nullable imageBody, NSError * _Nullable error))completionHandler {
    
    NSData * data = UIImageJPEGRepresentation(aImage, 1.0);
    
    [SakuraApi uploadImage:data withAuthorization:_token progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(BOOL success, SIImageBody * _Nullable body, NSError * _Nullable error) {
        if (error == nil && body != nil) {
            if (completionHandler) {
                completionHandler(body, nil);
            }
        } else {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"上传图片失败, @%@", error.description]];
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }];
    
}

- (void)uploadAudio:(NSData *_Nullable)audioData
           progress:(void (^ _Nullable)(float progress))progressBlock
         completion:(void (^ _Nullable)(SIVoiceBody * _Nullable voiceBody, NSError * _Nullable error))completionHandler {
    
    [SakuraApi uploadAudio:audioData withAuthorization:_token progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(BOOL success, SIVoiceBody * _Nullable body, NSError * _Nullable error) {
        if (error == nil && body != nil) {
            if (completionHandler) {
                completionHandler(body, nil);
            }
        } else {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"上传音频失败, @%@", error.description]];
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }];
}

- (void)uploadVideo:(NSData *_Nullable)videoData
           progress:(void (^ _Nullable)(float progress))progressBlock
         completion:(void (^ _Nullable)(SIShortvideoBody * _Nullable videoBody, NSError * _Nullable error))completionHandler {
    
    [SakuraApi uploadVideo:videoData withAuthorization:_token progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(BOOL success, SIShortvideoBody * _Nullable body, NSError * _Nullable error) {
        if (error == nil && body != nil) {
            if (completionHandler) {
                completionHandler(body, nil);
            }
        } else {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"上传视频失败, @%@", error.description]];
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }];
    
}

- (void)downloadAudio:(NSString * _Nonnull)mediaId
               toPath:(NSString *_Nullable)filePath
             progress:(void (^ _Nullable)(float progress))progressBlock
           completion:(void (^ _Nullable)(BOOL success, NSData * _Nullable data, NSError * _Nullable error))completionHandler {
    [[SakuraMessage sharedInstance] downloadFile:[NSString stringWithFormat:@"%@/%@", SakuraConfig.FileBase, mediaId] toPath:filePath progress:progressBlock completion:completionHandler];
}

- (void)downloadVideo:(NSString * _Nonnull)mediaId
               toPath:(NSString *_Nullable)filePath
             progress:(void (^ _Nullable)(float progress))progressBlock
           completion:(void (^ _Nullable)(BOOL success, NSData * _Nullable data, NSError * _Nullable error))completionHandler{
    [[SakuraMessage sharedInstance]downloadFile:[NSString stringWithFormat:@"%@/%@", SakuraConfig.FileBase, mediaId] toPath:filePath progress:progressBlock completion:completionHandler];
}

- (void)downloadFile:(NSString *_Nonnull)urlString
              toPath:(NSString *_Nullable)filePath
            progress:(void (^ _Nullable)(float progress))progressBlock
          completion:(void (^ _Nullable)(BOOL success, NSData * _Nullable data, NSError * _Nullable error))completionHandler {
    [SakuraApi downloadFile:urlString withAuthorization:_token toPath:filePath progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(BOOL success, NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            if (completionHandler) {
                completionHandler(true, data, nil);
            }
        } else {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"下载文件失败, @%@", error.description]];
            if (completionHandler) {
                completionHandler(false, nil, error);
            }
        }
    }];
}


#pragma mark -SakuraIODelegate
- (void)onRecv:(Protocol_Class *)message {
    [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"receive message : %@", message.debugDescription]];
    SIMessage *simsg = nil;
    switch (message.protocolType) {
        case ProtocolType_ComConnectReqAck: {
            if (message.connectReqAck.authorized) {
                [self changeConnStatus:SI_CONN_CONNECTED];
                [self initHeartBeatTimer];
                //timing to fetch offline message
                [self fetchOfflineMessage];
            } else {
                DISPATCH_MAIN_ASYNC(^{
                    if (self.delegate && [self.delegate respondsToSelector: @selector(onKickOff:)]) {
                        [self.delegate onKickOff:SI_KICKOFF_UNKNOWN];
                    }
                });
                [SakuraMessage disconnectSakura];
            }
            return;
        }
        case ProtocolType_ComHeartbeatReqAck: {
            //收到心跳回复，更新消息同步时间
            [SakuraApi updateSyncTime:_identify withAuthorization:_token forDevice:SAKURA_DEVICE_IOS completion:^(BOOL success, NSError * _Nullable error) {
                if (!success) {
                    [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"更新消息同步时间失败, %@", error.description]];
                }
            }];
            return;
        }
        case ProtocolType_ComChatMessageReq: {
            simsg = [SIMessage initWithChatMessageReq:message.chatMessageReq];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            return;
        }
        case ProtocolType_ComChatMessageNotify: {
            simsg = [SIMessage initWithChatMessageNotify:message.chatMessageNotify];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            return;
        }
        case ProtocolType_ComGroupMessageReq: {
            simsg = [SIMessage initWithGroupMessageReq:message.groupMessageReq];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            return;
        }
        case ProtocolType_ComGroupMessageNotify: {
            simsg = [SIMessage initWithGroupMessageNotify:message.groupMessageNotify];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            return;
        }
        case ProtocolType_ComCustomerMessageReq: {
            simsg = [SIMessage initWithCustomerMessageReq:message.customerMessageReq];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            break;
        }
        case ProtocolType_ComCustomerMessageReplyNotify: {
            simsg = [SIMessage initWithCustomerMessageReplyNotify:message.customerMessageReplyNotify];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            return;
        }
        case ProtocolType_ComSystemMessageNotify: {
            simsg = [SIMessage initWithSystemMessageNotify:message.systemMessageNotify];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessage:)]) {
                    [self.delegate onReceiveMessage:simsg];
                }
            });
            return;
        }
        case ProtocolType_ComReceiveStateMessageNotify: {
            SIMessageRecvEvent *sievt = [SIMessageRecvEvent initWithRecvStateNotify:message.receiveStateMessageNotify];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveMessageAck:)]) {
                    [self.delegate onReceiveMessageAck:sievt];
                }
            });
            return;
        }
        case ProtocolType_ComSessionStateMessageReq: {
            SISessionStateEvent *sievt = [SISessionStateEvent initWithSessionStateReq:message.sessionStateMessageReq];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveSessionState:)]) {
                    [self.delegate onReceiveSessionState:sievt];
                }
            });
            return;
        }
        case ProtocolType_ComSessionStateMessageNotify: {
            SISessionStateEvent *sievt = [SISessionStateEvent initWithSessionStateNotify:message.sessionStateMessageNotify];
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onReceiveSessionState:)]) {
                    [self.delegate onReceiveSessionState:sievt];
                }
            });
            return;
        }
        case ProtocolType_ComDisconnectNotify: {
            DISPATCH_MAIN_ASYNC(^{
                if (self.delegate && [self.delegate respondsToSelector: @selector(onKickOff:)]) {
                    [self.delegate onKickOff:message.disconnectNotify.reason];
                }
            });
            [SakuraMessage disconnectSakura];
            return;
        }
        default: {
            [SakuraLogHelper logFunc:__FUNCTION__ info:@"unsupported protocol"];
            return;
        }
    }
}

- (void)onSnd:(Protocol_Class *)message
        error:(NSError *)error {
    [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"send message : %@", message.debugDescription]];
    
    NSObject *simsg = nil;
    switch (message.protocolType) {
        case ProtocolType_ComChatMessageReq:
            simsg = [SIMessage initWithChatMessageReq:message.chatMessageReq];
            break;
        case ProtocolType_ComGroupMessageReq:
            simsg = [SIMessage initWithGroupMessageReq:message.groupMessageReq];
            break;
        case ProtocolType_ComCustomerMessageReq:
            simsg = [SIMessage initWithCustomerMessageReq:message.customerMessageReq];
            break;
        default:
            return;
    }
    
    if (error) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"sakura send message error, %@", error.description]];
        DISPATCH_MAIN_ASYNC(^{
            if (self.delegate && [self.delegate respondsToSelector: @selector(onSentMessage:result:)]) {
                [self.delegate onSentMessage:(SIMessage *)simsg result:false];
            }
        });
    } else {
        DISPATCH_MAIN_ASYNC(^{
            if (self.delegate && [self.delegate respondsToSelector: @selector(onSentMessage:result:)]) {
                [self.delegate onSentMessage:(SIMessage *)simsg result:true];
            }
        });
    }
}

- (void)onErr:(NSError *)error {
    [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"sakura connection error, %@", error.description]];
    DISPATCH_GLOBAL_ASYNC(^{[self reconnect];});
}

- (void)onClose {
    [SakuraLogHelper logFunc:__FUNCTION__ info:@"sakura connection closed"];
    DISPATCH_GLOBAL_ASYNC(^{[self reconnect];});
}

- (void)onAvailable {
    [self sendConnectReq];
}

@end
