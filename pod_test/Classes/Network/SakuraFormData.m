//
//  SakuraFormNSData.m
//  SakuraKit
//
//  Created by 123 on 2018/5/10.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraFormData.h"

@implementation SakuraFormData

+ (NSData *)voiceData:(NSData *)data withRequest:(NSMutableURLRequest *)request {
    NSString *filename  = [NSString stringWithFormat:@"audio%.0f.amr", [[NSDate date] timeIntervalSince1970]];
    NSString *field = @"file";
    NSString *mimetype = @"audio/amr";
    
    return [self formData:data fileName:filename field:field mimeType:mimetype request:request];
    
}

+ (NSData *)imageData:(NSData *)data withRequest:(NSMutableURLRequest *)request {
    NSString *filename  = [NSString stringWithFormat:@"img%.0f.jpg", [[NSDate date] timeIntervalSince1970]];
    NSString *field = @"file";
    NSString *mimetype = @"image/jpeg";
    
    return [self formData:data fileName:filename field:field mimeType:mimetype request:request];
}


+ (NSData *)videoData:(NSData *)data withRequest:(NSMutableURLRequest *)request {
    NSString *filename  = [NSString stringWithFormat:@"video%.0f.mp4", [[NSDate date] timeIntervalSince1970]];
    NSString *field = @"file";
    NSString *mimetype = @"video/quicktime";
    
    return [self formData:data fileName:filename field:field mimeType:mimetype request:request];
}



+ (NSData *)formData:(NSData *)data fileName:(NSString *)fileName field:(NSString *)field mimeType:(NSString *)mimeType request:(NSMutableURLRequest *)request {
    
    NSMutableData *formData = [NSMutableData data];
    NSString *boundary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    
    //for request's boundary consistent with body's boundary
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    // add data
    [formData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", field, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:data];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [formData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return formData;
}

@end
