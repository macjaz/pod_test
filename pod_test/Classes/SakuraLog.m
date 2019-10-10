//
//  SakuraLog.m
//  SakuraKit
//
//  Created by 123 on 2018/11/28.
//  Copyright © 2018 keilon. All rights reserved.
//

#import "SakuraLog.h"


// 日志保留最大天数
static const int LogMaxSaveDay = 7;

@interface SakuraLog()

@property (nonatomic, retain) NSDateFormatter *dateFormatter; //日期化格式
@property (nonatomic, retain) NSDateFormatter *timeFormatter; //时间化格式
@property (nonatomic, copy) NSString *basePath; //日志的目录路径

@end


@implementation SakuraLog

+ (instancetype) sharedInstance {
    static SakuraLog *log = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!log) {
            log = [[SakuraLog alloc]init];
        }
    });
    
    return log;
}


//获取当前时间
+ (NSDate *)getCurrentDate {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    
    return localeDate;
}


#pragma mark ------- init ----------
- (instancetype)init {
    self = [super init];
    
    if (self) {
        // 创建日期格式化
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        // 设置时区，解决8小时
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        self.dateFormatter = dateFormatter;
        
        // 创建时间格式化
        NSDateFormatter* timeFormatter = [[NSDateFormatter alloc]init];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        [timeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        self.timeFormatter = timeFormatter;
        
        // 日志的目录路径
        self.basePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(), @"/Documents/SakuraLog/"];
    }
    
    return self;
}


#pragma mark -------- 进行写日志 -------------


//写入日志
- (void)logFunc:(NSString *)module logInfo:(NSString *)logInfo {
    
    // 异步执行
    dispatch_async(dispatch_queue_create("writeLog", nil), ^{
        
        // 获取当前日期做为文件名
        NSString* fileName = [self.dateFormatter stringFromDate:[NSDate date]];
        NSString* filePath = [NSString stringWithFormat:@"%@%@",self.basePath,fileName];
        
        // [时间]-[模块]-日志内容
        NSString* timeStr = [self.timeFormatter stringFromDate:[SakuraLog getCurrentDate]];
        NSString* writeStr = [NSString stringWithFormat:@"[%@]-[%@]-%@\n",timeStr,module,logInfo];
        
        // 写入数据
        [self writeFile:filePath stringData:writeStr];
    });
}


- (void)writeFile:(NSString*)filePath stringData:(NSString*)stringData{
    
    // 待写入的数据
    NSData* writeData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    // NSFileManager 用于处理文件
    BOOL createPathOk = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByDeletingLastPathComponent] isDirectory:&createPathOk]) {
        // 目录不存先创建
        [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        // 文件不存在，直接创建文件并写入
        [writeData writeToFile:filePath atomically:NO];
    }else{
        // NSFileHandle 用于处理文件内容
        // 读取文件到上下文，并且是更新模式
        NSFileHandle* fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        
        // 跳到文件末尾
        [fileHandler seekToEndOfFile];
        
        // 追加数据
        [fileHandler writeData:writeData];
        
        // 关闭文件
        [fileHandler closeFile];
    }
}



#pragma mark ----------- 删除日志 --------------
// 删除过期日志,超过七天
- (void)clearExpiredLog {
    // 获取日志目录下的所有文件
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.basePath error:nil];
    for (NSString* file in files) {
        
        NSDate* date = [self.dateFormatter dateFromString:file];
        if (date) {
            NSTimeInterval oldTime = [date timeIntervalSince1970];
            NSTimeInterval currTime = [[SakuraLog getCurrentDate] timeIntervalSince1970];
            
            NSTimeInterval second = currTime - oldTime;
            int day = (int)second / (24 * 3600);
            if (day >= LogMaxSaveDay) {
                // 删除该文件
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",self.basePath,file] error:nil];
            }
        }
    }
}

@end
