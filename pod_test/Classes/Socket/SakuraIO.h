//
//  SakuraIO.h
//  SakuraKit
//
//  Created by keilon on 2018/1/3.
//  Copyright © 2018年 keilon. All rights reserved.
//

#ifndef SakuraIO_h
#define SakuraIO_h

#import "Protocol.pbobjc.h"

@protocol SakuraIODelegate <NSObject>

@optional
- (void)onRecv:(Protocol_Class *_Nonnull)message;
@optional
- (void)onSnd:(Protocol_Class *_Nonnull)message error:(NSError * _Nullable)error;
@optional
- (void)onErr:(NSError *_Nonnull)error;
@optional
- (void)onClose;
@optional
- (void)onAvailable;

@end


@interface SakuraIO : NSObject <NSStreamDelegate>

@property(nullable, assign) id<SakuraIODelegate> delegate;

+ (instancetype _Nullable )ioWithHost:(NSString * _Nonnull)host on:(unsigned int)port;
- (instancetype _Nullable )initWithHost:(NSString * _Nonnull)host on:(unsigned int)port;
- (void)sendMessage:(Protocol_Class * _Nonnull)message;
- (void)connect;
- (BOOL)close;

@end

#endif /* SakuraIO_h */


