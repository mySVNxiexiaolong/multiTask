//
//  TaskModel.h
//  多任务下载
//
//  Created by 谢小龙 on 16/5/20.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskModel;

typedef void(^TaskFinishCallBack)(TaskModel * _Nonnull taskModel);

typedef NS_ENUM(NSInteger, DownloadTaskState){
    
    DownloadTaskStateNotRunning = 0,
    DownloadTaskStateRunning,
    DownloadTaskStatePasue,
    DownloadTaskStateDone,
    DownloadTaskStateFaild
    
};

@protocol TaskModelDelegate <NSObject>
  @optional
    - (void)onTaskModelDidFinished:(nonnull TaskModel *)taskModel;
    - (void)onTaskModelDidPause:(nonnull TaskModel *)taskModel;
    - (void)onTaskModelDidRestart:(nonnull TaskModel *)taskModel;
    - (void)onGetDownloadSpeed:(float)speed;
    - (void)onGetDownloadReceivedData:(int64_t)recrived totalData:(int64_t)total;

@end

@interface TaskModel : NSObject

@property (nonatomic, assign) int64_t totalSize_Bit;//总字节
@property (nonatomic, strong) NSString * _Nullable fileName;

@property (nonatomic, assign) float speed;//speed/s
@property (nonatomic, assign) float percentage;

@property (nonatomic, assign) DownloadTaskState taskState;

@property (nonatomic, strong)  NSString * _Nonnull downloadURL;

@property (nonatomic, strong) NSURLSessionDataTask * _Nonnull task;
@property (nonatomic, strong) id<TaskModelDelegate> _Nullable delegate;

- (void)startTask;
- (void)pasueTask;
- (void)restartTask;
- (void)deleteTask;

- (instancetype _Nonnull)initWithDownloadURL:(NSString * _Nonnull)url localPath:(NSString * _Nullable)fileDirectory fileName:(NSString * _Nullable)fileName finishCallBack:(TaskFinishCallBack _Nonnull)callBack;

- (instancetype _Nonnull)initWithRebuildTaskURL:(NSString * _Nonnull)fileUrl fileName:(NSString * _Nonnull)fileName finishCallBack:(TaskFinishCallBack _Nonnull)callBack;

@end
