//
//  SakuraReconnect.h
//  SakuraKit
//
//  Created by keilon on 2019/6/4.
//  Copyright © 2019 keilon. All rights reserved.
//

#ifndef SakuraReconnect_h
#define SakuraReconnect_h

#import <Foundation/Foundation.h>

#define DEFAULT_SAKURA_RECONNECT_DELAY 2.0
#define DEFAULT_SAKURA_RECONNECT_TIMER_INTERVAL 10.0

@interface SakuraReconnect : NSObject

/**
 * 是否开启重连，默认开启
 **/
@property (nonatomic, assign) BOOL autoReconnect;

/**
 * 重连延迟时间，当连接意外断开时，短暂时间之后再进行重连
 *
 * 默认值为 DEFAULT_SAKURA_RECONNECT_DELAY
 *
 * 指定值为 0 时，不启用延迟重连（立刻进行重连）
 *
 * Note: NSTimeInterval 为 double 类型，单位为秒
 **/
@property (nonatomic, assign) NSTimeInterval reconnectDelay;

/**
 * 重连间隔时间，首次重连后计时开始
 *
 * 默认值为 DEFAULT_SAKURA_RECONNECT_TIMER_INTERVAL
 *
 * Note: NSTimeInterval 为 double 类型，单位为秒
 **/
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval;

/**
 * 开始重连
 **/
- (void)start;

/**
 * 中断当前重连
 **/
- (void)stop;

@end
#endif /* SakuraReconnect_h */
