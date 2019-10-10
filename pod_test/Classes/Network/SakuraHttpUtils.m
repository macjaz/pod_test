//
//  SakuraHttpUtils.m
//  SakuraKit
//
//  Created by keilon on 2018/1/11.
//  Copyright © 2018年 keilon. All rights reserved.
//

#import "SakuraHttpUtils.h"

//stolen from AFNetworking, see: https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFURLSessionManager.m
@interface SakuraHttpClient ()  <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSLock *lock;
@property (readwrite, nonatomic, strong) NSMutableDictionary *tasksIdentifier;

@end

@implementation SakuraHttpClient

static id _sharedInstance;

+ (instancetype)sharedInstance {
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    NSAssert(_sharedInstance == nil, @"Only one instance of SakuraMessage should be created. Use +[SakuraHttpClient sharedInstance] instead.");
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.sessionConfiguration = config;
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
    
    self.lock = [[NSLock alloc] init];
    self.tasksIdentifier = [[NSMutableDictionary alloc]init];
    
    
    return self;
}


- (SakuraTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    
    SakuraTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.tasksIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return delegate;
}

- (void)setDelegate:(SakuraTaskDelegate *)delegate
            forTask:(NSURLSessionTask *)task
{
    
    [self.lock lock];
    self.tasksIdentifier[@(task.taskIdentifier)] = delegate;
    [self.lock unlock];
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    [self.lock lock];
    self.tasksIdentifier[@(task.taskIdentifier)] = nil;
    [self.tasksIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}


+ (void)post:(NSURLRequest *_Nonnull)request
  completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler {
    
    //1.get session
    SakuraHttpClient *this = [SakuraHttpClient sharedInstance];
    NSURLSession *session = this.session;
    

    //2.build task
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    
    //3.set taskDelegate
    SakuraTaskDelegate *delegate = [[SakuraTaskDelegate alloc] initWithTask:dataTask];
    delegate.completionHandler = completionHandler;
    [this setDelegate:delegate forTask:dataTask];
    
    //4.execute task
    [dataTask resume];
}


+ (void)put:(NSURLRequest *_Nonnull)request
 completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler{
    //1.get session
    SakuraHttpClient *this = [SakuraHttpClient sharedInstance];
    NSURLSession *session = this.session;
    
    
    //2.build task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    
    //3.set taskDelegate
    SakuraTaskDelegate *delegate = [[SakuraTaskDelegate alloc] initWithTask:dataTask];
    delegate.completionHandler = completionHandler;
    [this setDelegate:delegate forTask:dataTask];
    
    //4.execute task
    [dataTask resume];
}


+ (void)get:(NSURLRequest *_Nonnull)request
 completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler {
    
    //1.get session
    SakuraHttpClient *this = [SakuraHttpClient sharedInstance];
    NSURLSession *session = this.session;
    
    //2.build task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    
    //3.set taskDelegate
    SakuraTaskDelegate *delegate = [[SakuraTaskDelegate alloc] initWithTask:dataTask];
    delegate.completionHandler = completionHandler;
    [this setDelegate:delegate forTask:dataTask];
    
    //4.execute task
    [dataTask resume];
    
    
}

+ (void)upload:(NSURLRequest *_Nonnull)urlRequest
      withForm:(NSData *_Nonnull)formData
      progress:(SakuraHttpClientProgressBlock _Nullable)taskProgress
    completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler {
    
    //1.get session
    SakuraHttpClient *this = [SakuraHttpClient sharedInstance];
    NSURLSession *session = this.session;
    
    //2.build task
    NSURLSessionUploadTask *dataTask = [session uploadTaskWithRequest:urlRequest fromData:formData];
    
    //3.set taskDelegate to give progress
    SakuraTaskDelegate *delegate = [[SakuraTaskDelegate alloc] initWithTask:dataTask];
    delegate.completionHandler = completionHandler;
    delegate.uploadProgressBlock = taskProgress;
    
    [this setDelegate:delegate forTask:dataTask];
    
    
    //4.execute task
    [dataTask resume];
}


+ (void)download:(NSURLRequest *_Nonnull)urlRequest
          toPath:(NSString *_Nullable)filePath
        progress:(SakuraHttpClientProgressBlock _Nullable)taskProgress
      completion:(SakuraHttpClientCompleteBlock _Nullable)completionHandler {
    
    SakuraHttpClient *this = [SakuraHttpClient sharedInstance];
    NSURLSession *session = this.session;
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:urlRequest];
    
    SakuraTaskDelegate *delegate = [[SakuraTaskDelegate alloc] initWithTask:dataTask];
    delegate.completionHandler = completionHandler;
    delegate.downloadProgressBlock = taskProgress;
    delegate.filePath = filePath;

    [this setDelegate:delegate forTask:dataTask];
    
    [dataTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    SakuraTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    SakuraTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}



#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    SakuraTaskDelegate *delegate = [self delegateForTask:task];
    if (delegate) {
        [delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    SakuraTaskDelegate *delegate = [self delegateForTask:task];
    // delegate may be nil when completing a task in the background
    if (delegate) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        [self removeDelegateForTask:task];
    }
}



#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    
    SakuraTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [delegate URLSession:session dataTask:dataTask didReceiveData:data];
    }
    
    
}
@end
