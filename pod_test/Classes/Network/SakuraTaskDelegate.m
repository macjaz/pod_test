//
//  SakuraTaskDelegate.m
//  SakuraKit
//
//  Created by 123 on 2018/5/7.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraTaskDelegate.h"
#import "SakuraLogHelper.h"

@interface SakuraTaskDelegate() 

@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, copy) NSURL *downloadFileURL;

@end

@implementation SakuraTaskDelegate

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _mutableData = [[NSMutableData alloc] init];
    
    return self;
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (self.uploadProgressBlock) {
        self.uploadProgressBlock((float)totalBytesSent/totalBytesExpectedToSend);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (error) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"%@", error.description]];
        if (self.completionHandler) {
            self.completionHandler(false, nil, error);
            return ;
        }
        
    }
    
    // check for http status
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
    if (res.statusCode < 200 || res.statusCode > 299) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"请求出错, code:@%ld", (long)res.statusCode]];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: res.description, @"desc", nil];
        self.completionHandler(false, nil, [NSError errorWithDomain:@"SakuraHttpClient" code:res.statusCode userInfo:userInfo]);
        return ;
    }
    
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        self.mutableData = nil;
    }
    
    // 返回空数据 (httpStatusCode = 204)
    if (data == nil || 0 == data.length) {
        self.completionHandler(true, nil, nil);
        return;
    }
    
    // 返回下载文件数据
    if (self.downloadFileURL) {
        self.completionHandler(true, data, nil);
        return;
    }
    
    // 解析并返回 json 数据
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (jsonError) {
        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"%@", jsonError.description]];
        self.completionHandler(false, nil, jsonError);
        return;
    }
    
    self.completionHandler(true, jsonObject, nil);
    
}


#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    self.downloadFileURL = location;
    
    NSError *fileManagerError = nil;
    
    //如果存在指定文件路径则移到指定的文件路径
    if (self.filePath) {
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL URLWithString:self.filePath] error:&fileManagerError];
        [SakuraLogHelper logFunc:__FUNCTION__ info:[NSString stringWithFormat:@"---------filePath:%@",self.filePath]];
    }
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.filePath]];
    [self.mutableData appendData:data];
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock((float)totalBytesWritten/totalBytesWritten);
    }
}
@end
