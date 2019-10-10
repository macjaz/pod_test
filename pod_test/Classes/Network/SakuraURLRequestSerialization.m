//
//  SakuraURLRequestSerialization.m
//  SakuraKit
//
//  Created by 123 on 2018/5/10.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraURLRequestSerialization.h"

@interface SakuraURLRequestSerialization ()

@end

@implementation SakuraURLRequestSerialization

- (instancetype)init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}


- (NSMutableURLRequest *_Nonnull)downloadURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    [request addValue:@"audio/amr" forHTTPHeaderField:@"Content-Type"];
    return request;
    
}

- (NSMutableURLRequest *_Nonnull)shortvideoURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token {
    return [self UploadURLRequestSerialization:[NSString stringWithFormat:@"%@/shortvideo",urlString] withAuthorization:token];
}

- (NSMutableURLRequest *_Nonnull)audioURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token{
    return [self UploadURLRequestSerialization:[NSString stringWithFormat:@"%@/normal",urlString] withAuthorization:token];
}



- (NSMutableURLRequest *_Nonnull)imageURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token{
    return [self UploadURLRequestSerialization:[NSString stringWithFormat:@"%@/image",urlString] withAuthorization:token];
}



- (NSMutableURLRequest *_Nonnull)GetURLRequestSerialization:(NSString *_Nonnull)urlString
                                                          withAuthorization:(NSString *_Nonnull)token {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    [request addValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    return request;
}



- (NSMutableURLRequest *_Nonnull)UploadURLRequestSerialization:(NSString *_Nonnull)urlString
                                            withAuthorization:(NSString *_Nonnull)token{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    return request;
}


- (NSMutableURLRequest *_Nonnull)PutURLRequestSerialization:(NSString *_Nonnull)urlString
                                          withAuthorization:(NSString *_Nonnull)token
                                                   withBody:(NSDictionary *_Nullable)requestBody
                                                  withError:(NSError *_Nullable)error{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    [request addValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    
    if(requestBody){
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestBody options:kNilOptions error:&error];
    }
    return request;
}


- (NSMutableURLRequest *_Nonnull)UpdateTokenRequestSerialization:(NSString *_Nonnull)urlString
                                               withAuthorization:(NSString *_Nonnull)token
                                                        withBody:(NSObject *_Nullable)requestBody
                                                       withError:(NSError *_Nullable)error{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request addValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    
    if(requestBody){
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestBody options:kNilOptions error:&error];
    }
    return request;
}

@end
