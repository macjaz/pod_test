//
//  SakuraReconnect.m
//  SakuraKit
//
//  Created by keilon on 2019/6/4.
//  Copyright © 2019 keilon. All rights reserved.
//

#import "SakuraReconnect.h"
#import "SakuraIO.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define IMPOSSIBLE_REACHABILITY_FLAGS 0xFFFFFFFF

enum ReconnectFlags {
    kShouldReconnect        = 1 << 0,
    kShouldRestartReconnect = 1 << 1,
};

@interface SakuraReconnect() {
    Byte _flags;
    SakuraIO * _io;
    SCNetworkReachabilityRef _reachability;
    SCNetworkReachabilityFlags _previousReachabilityFlags;
}
@end

/// PrivateAPI
@interface SakuraReconnect()

- (void)setupReconnectTimer;
- (void)teardownReconnectTimer;

- (void)setupNetworkMonitoring;
- (void)teardownNetworkMonitoring;

@end


@implementation SakuraReconnect

@synthesize reconnectDelay;
@synthesize reconnectTimerInterval;

- (id)initWithIO:(SakuraIO *)io {
    self = [super init];
    
    _io = io;
    _previousReachabilityFlags = IMPOSSIBLE_REACHABILITY_FLAGS;
    self.reconnectDelay = DEFAULT_SAKURA_RECONNECT_DELAY;
    self.reconnectTimerInterval = DEFAULT_SAKURA_RECONNECT_TIMER_INTERVAL;
    
    return self;
}

- (void)dealloc {
    [self teardownReconnectTimer];
    [self teardownNetworkMonitoring];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Reachability
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static void SakuraReconnectReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    @autoreleasepool {
        SakuraReconnect *that = (__bridge SakuraReconnect*)info;
        if (that->_previousReachabilityFlags != flags) {
            
        }
    }
}

- (void)setupReconnectTimer {
    
}

- (void)teardownReconnectTimer {
    
}

- (void)setupNetworkMonitoring {
    if (_reachability == NULL) {
        NSString *domain = @"apple.com";
        _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
        if (_reachability) {
            SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
            SCNetworkReachabilitySetCallback(_reachability, SakuraReconnectReachabilityCallback, &context);
            
            //TODO setup DispatchQueue
            SCNetworkReachabilitySetDispatchQueue(_reachability, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        }
    }
}

- (void)teardownNetworkMonitoring {
    
    if (_reachability) {
        SCNetworkReachabilitySetDispatchQueue(_reachability, NULL);
        SCNetworkReachabilitySetCallback(_reachability, NULL, NULL);
        CFRelease(_reachability);
        _reachability = NULL;
    }
}

- (void)start {
    
    dispatch_block_t block = ^{ @autoreleasepool {
        [self setupReconnectTimer];
        [self setupNetworkMonitoring];
    }};
    
    //TODO setup DispatchQueue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)stop {
    
    dispatch_block_t block = ^{ @autoreleasepool {
        [self teardownReconnectTimer];
        [self teardownNetworkMonitoring];
        
    }};

    //TODO setup DispatchQueue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
