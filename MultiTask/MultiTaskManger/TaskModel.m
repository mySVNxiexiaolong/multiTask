//
//  TaskModel.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/20.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "TaskModel.h"

#define DocumentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject

@interface TaskModel ()<NSURLSessionDelegate>{
    int64_t totalSize;//字节
    int64_t speedSizeEveSec;
    
    NSTimer *timer;
    
    NSDictionary *urlAndFilePath;
    
    TaskFinishCallBack finishBlockCallBack;
}

@property (nonatomic, strong) NSURLSession *downloadSession;

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, assign) int64_t location;

@property (nonatomic, strong) NSString * _Nullable filePath;

@end

@implementation TaskModel

- (NSURLSession *)downloadSession{
    
    if (!_downloadSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _downloadSession;
}

- (instancetype)initWithDownloadURL:(NSString *)url localPath:(NSString *)fileDirectory fileName:(NSString * _Nullable)fileName finishCallBack:(TaskFinishCallBack _Nonnull)callBack{
    self = [super init];
    if (self) {
        totalSize = 0;
        speedSizeEveSec = 0;
        _filePath = fileDirectory;
        _downloadURL = url;
        _fileName = fileName;
        
        if (!_fileName) {
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
            NSString *dateStr = [formatter stringFromDate:date];
            dateStr = [NSString stringWithFormat:@"%@.mp4",dateStr];
            
            _fileName = dateStr;
        }
        
        _filePath = [_filePath stringByAppendingPathComponent:_fileName];
        
        urlAndFilePath = @{url:self.filePath};
        
        finishBlockCallBack = callBack;
        
    }
    return self;
}

- (instancetype)initWithRebuildTaskURL:(NSString *)fileUrl fileName:(NSString *)fileName finishCallBack:(TaskFinishCallBack _Nonnull)callBack{
    self = [super init];
    if (self) {
        totalSize = 0;
        speedSizeEveSec = 0;
        _fileName = fileName;
        _filePath = [DocumentPath stringByAppendingPathComponent:fileName];
        _downloadURL = fileUrl;
        
        NSData *data = [NSData dataWithContentsOfFile:_filePath];
        _location = data.length;
        
        finishBlockCallBack = callBack;
        
    }
    return self;
}

#pragma mark - 操作任务
- (void)startTask{
    
    if (!self.downloadURL) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[self.downloadURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //设置请求头，用于获取文件信息
    NSMutableURLRequest *headRequest = [NSMutableURLRequest requestWithURL:url];
    headRequest.HTTPMethod = @"HEAD";
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:headRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        
        totalSize = response.expectedContentLength;
        
        [self initTaskWith:response.URL];
        
        
    }];
    [self startTimer];
    [task resume];
    
}

- (void)pasueTask{
    
    [self.task suspend];
    self.taskState = DownloadTaskStatePasue;
    [timer invalidate];
    [self.outputStream close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskModelDidPause:)]) {
        [self.delegate onTaskModelDidPause:self];
    }
    NSLog(@"pasueTask");
    
}

- (void)restartTask{
   
//    [self initTaskWith:[NSURL URLWithString:self.downloadURL]];
//    [self startTimer];
    [self startTask];
    NSLog(@"restartTask");
    
}

- (void)deleteTask{
    
    [self.task suspend];
    [self.outputStream close];
    [timer invalidate];
    BOOL isDelete = [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    NSLog(@"deleteTask:%d",isDelete);
    
}

- (void)initTaskWith:(NSURL *)url{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSData *data = nil;
    BOOL b = [manager fileExistsAtPath:self.filePath];
    if (b) {
        data = [NSData dataWithContentsOfFile:self.filePath];
    }else{
        [manager createFileAtPath:self.filePath contents:nil attributes:nil];
        data = [NSData dataWithContentsOfFile:self.filePath];
    }
    
    self.location = data.length;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *head = [NSString stringWithFormat:@"bytes=%zd-",self.location];
    [request setValue:head forHTTPHeaderField:@"Range"];
    
    self.task = [self.downloadSession dataTaskWithRequest:request];
    
    //创建并打开写入流
    self.outputStream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.outputStream open];
    
    [self.task resume];
    
    self.taskState = DownloadTaskStateRunning;
    
}

- (void)startTimer{
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setupDownloadSpeed) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

- (void)setupDownloadSpeed{
    
    self.speed = speedSizeEveSec/1000.0;
//    NSLog(@"网速:%f/s",self.speed);
    speedSizeEveSec = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGetDownloadSpeed:)]) {
        [self.delegate onGetDownloadSpeed:self.speed];
    }
    
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (!error) {
        self.taskState = DownloadTaskStateDone;
        finishBlockCallBack(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskModelDidFinished:)]) {
            [self.delegate onTaskModelDidFinished:self];
        }
        NSLog(@"视频下载完成");
    }else{
        self.taskState = DownloadTaskStateFaild;
    }
    
    [self.outputStream close];
    [timer invalidate];
    
    [session finishTasksAndInvalidate];//完成任务一定要调用，否则会内存泄露
//    [session invalidateAndCancel];
    
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.outputStream write:data.bytes maxLength:data.length];
    self.location += data.length;
    speedSizeEveSec += data.length;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGetDownloadReceivedData:totalData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onGetDownloadReceivedData:self.location totalData:totalSize];
        });
    }
    
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
