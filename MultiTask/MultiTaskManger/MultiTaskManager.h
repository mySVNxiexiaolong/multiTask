//
//  MultiTaskManager.h
//  多任务下载
//
//  Created by 谢小龙 on 16/5/20.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TaskModel;

@interface MultiTaskManager : NSObject

@property (nonatomic, strong) NSMutableArray *tasksArray;

+ (instancetype)sharedInstance;

- (void)addDownloadMaskWithURL:(NSString *)urlString filePath:(NSString *)fileDirectory fileName:(NSString *)fileName;

//删除任务 一个或多个
- (void)deleteTasks:(NSArray *)tasks;

//app被杀掉时存储当前下载信息
- (void)saveTasksData;
//启动时加载上次未完成的下载任务
- (void)initTasksData;

@end
