//
//  SakuraIO.m
//  SakuraKit
//
//  Created by keilon on 2018/1/3.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraIO.h"
#import "SakuraLogHelper.h"

@interface SakuraIO ()

@property(atomic) BOOL isConnected;
@property(nonatomic, strong) NSString *host;
@property(nonatomic) unsigned int port;
@property(nonatomic, strong) NSInputStream *inStream;
@property(nonatomic, strong) NSOutputStream *outStream;
@property(nonatomic, strong) NSLock *lock;

@end

@implementation SakuraIO

+ (instancetype _Nullable )ioWithHost:(NSString * _Nonnull)host on:(unsigned int)port {
    return [[self alloc] initWithHost:host on:port];
}

- (instancetype _Nullable )initWithHost:(NSString * _Nonnull)host on:(unsigned int)port {
    self = [super init];
    
    if (self) {
        _isConnected = NO;
        
        _host        = [host copy];
        _port        = port;
        _inStream    = nil;
        _outStream   = nil;
        _lock = [[NSLock alloc]init];
    }
    
    return self;
}

- (void)connect {
    if (_isConnected) {
        return;
    }
    
    CFReadStreamRef   read_s;
    CFWriteStreamRef  write_s;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)_host, _port, &read_s, &write_s);
    
    // Enable SSL/TLS on the streams
    CFReadStreamSetProperty(read_s, (__bridge CFStreamPropertyKey)NSStreamSocketSecurityLevelKey, NSStreamSocketSecurityLevelNegotiatedSSL);
    CFWriteStreamSetProperty(write_s, (__bridge CFStreamPropertyKey)NSStreamSocketSecurityLevelKey, NSStreamSocketSecurityLevelNegotiatedSSL);

    // Define SSL/TLS settings
    NSDictionary *sslSettingsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (id)kCFBooleanFalse, (id)kCFStreamSSLValidatesCertificateChain, nil];
    
    // Config SSL/TLS settings
    CFReadStreamSetProperty(read_s, kCFStreamPropertySSLSettings, (__bridge CFTypeRef _Null_unspecified)sslSettingsDict);
    CFWriteStreamSetProperty(write_s, kCFStreamPropertySSLSettings, (__bridge CFTypeRef _Null_unspecified)sslSettingsDict);
        
    _inStream = (__bridge NSInputStream *)read_s;
    _outStream = (__bridge NSOutputStream *)write_s;
    _inStream.delegate = self;
    _outStream.delegate = self;
    
    [_inStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_outStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [_inStream open];
    [_outStream open];
    
}

- (BOOL)close {
    
    [_lock lock];
    
    if (_inStream && _outStream) {
        
        [_inStream close];
        [_outStream close];
        
        [_inStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_outStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        _inStream = nil;
        _outStream = nil;
    }
    
    _isConnected = NO;
    [SakuraLogHelper logFunc:__FUNCTION__ info:@"Sakura IO closed"];
    
    [_lock unlock];
    return YES;
}

- (void)sendMessage:(Protocol_Class *)message {
    if (!(_outStream.hasSpaceAvailable)) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"sendMessage error，probably space not available ", @"desc", nil];
        [_delegate onSnd:message error:[NSError errorWithDomain:@"SakuraIO" code:-1  userInfo:userInfo]];
        [_delegate onErr:[NSError errorWithDomain:@"SakuraIO" code:-1  userInfo:userInfo]];
        return;
    }
    NSData *data = [message data];
    UInt16 length = CFSwapInt16HostToBig(data.length);
    NSMutableData *packet =[NSMutableData dataWithBytes:&length length:sizeof(UInt16)];
    [packet appendData:data];
    if ([_outStream write:packet.bytes maxLength:packet.length] == packet.length) {
        [_delegate onSnd:message error:nil];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"write error，probably connection has closed", @"desc", nil];
        [_delegate onSnd:message error:[NSError errorWithDomain:@"SakuraIO" code:-1  userInfo:userInfo]];
        [_delegate onErr:[NSError errorWithDomain:@"SakuraIO" code:-1  userInfo:userInfo]];
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventNone: {
            //none
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"[%@ event]none", aStream.class]];
            break;
        }
        case NSStreamEventOpenCompleted: {
            //connection open
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"[%@ event]connection open", aStream.class]];
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            //bytes available (inputStream)
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"[%@ event]bytes available", aStream.class]];
            [self readBytes];
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            //space available (outputStream)
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"[%@ event]space available", aStream.class]];
            if (_isConnected) {
                return;
            }
            _isConnected = YES;
            [_delegate onAvailable];
            break;
        }
        case NSStreamEventErrorOccurred: {
            //connection error
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"[%@ event]connection error", aStream.class]];
            NSError * thisErr = [aStream streamError];
            [_delegate onErr:thisErr];
            break;
        }
        case NSStreamEventEndEncountered: {
            //connection close
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"[%@ event]connection close", aStream.class]];
            [_delegate onClose];
            break;
        }
    }
}

- (void)readBytes {
    while ([_inStream hasBytesAvailable]) {
        uint8_t lenBuf[2];
        NSInteger headLen1 = [_inStream read:lenBuf maxLength:1];
        NSInteger headLen2 = [_inStream read:(lenBuf + 1) maxLength:1];
        if (headLen1 != 1 || headLen2 != 1) {
            // read length failed, probably stream unavalible
            return ;
        }
        UInt16 length = CFSwapInt16BigToHost(*(uint16_t *)lenBuf);
        uint8_t dataBuf[length];
        NSInteger leftSize = length;
        while (leftSize > 0) {
            NSInteger offSet = length - leftSize;
            NSInteger readLength = [_inStream read:(dataBuf + offSet) maxLength:leftSize];
            if (readLength <= 0) {
                // read data failed, probably stream unavalible
                return ;
            }
            leftSize -= readLength;
        }
        
        NSData *data = [NSData dataWithBytes:dataBuf length:length];
        NSError *error = nil;
        Protocol_Class *message = [Protocol_Class parseFromData:data error:&error];
        if (error) {
            [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"parse protocol error, %@",error]];
            break;
        }
        [_delegate onRecv: message];
    }
}

@end
