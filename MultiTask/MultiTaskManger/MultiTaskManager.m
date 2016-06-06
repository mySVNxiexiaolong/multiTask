//
//  MultiTaskManager.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/20.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "MultiTaskManager.h"
#import "TaskModel.h"

#define PLIST_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"MultiTaskManager.plist"]

@interface MultiTaskManager ()<TaskModelDelegate>{
    NSMutableArray *taskArray;
    UIWindow *infoWindow;
}

@end

@implementation MultiTaskManager

+ (instancetype)sharedInstance{
    
    static MultiTaskManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[MultiTaskManager alloc] init];
    });
    return singleton;
}

- (NSMutableArray *)tasksArray{
    if (!_tasksArray) {
        _tasksArray = [NSMutableArray array];
    }
    return _tasksArray;
}

- (void)addDownloadMaskWithURL:(NSString *)urlString filePath:(NSString *)filePath fileName:(NSString *)fileName{
    
    //检查urlString中是否已有任务
    BOOL isExist = [self isTaskExist:urlString];
    
    if (isExist) {
        [self indicatorInfo:@"任务已存在"];
        return;
    }
    
    TaskModel *taskM = [[TaskModel alloc] initWithDownloadURL:urlString localPath:filePath fileName:fileName finishCallBack:^(TaskModel * _Nonnull taskModel) {
        if ([self.tasksArray containsObject:taskModel]) {
            [self.tasksArray removeObject:taskModel];
        }
    }];
    [taskM startTask];
    [self.tasksArray addObject:taskM];
    [self indicatorInfo:@"已添加到任务管理器"];
}

- (void)deleteTasks:(NSArray *)tasks{
    
    if (!tasks || tasks.count == 0) {
        return;
    }
    for (TaskModel *task in tasks) {
        
        if ([self.tasksArray containsObject:task]) {
            [task deleteTask];
            [self.tasksArray removeObject:task];
        }
        
    }
    
}

#pragma mark - check task exist or not 
- (BOOL)isTaskExist:(NSString *)urlString{
    
    for (TaskModel *task in self.tasksArray) {
        if ([task.downloadURL isEqualToString:urlString]) {
            return YES;
        }
    }
    return NO;
}

- (void)indicatorInfo:(NSString *)message{
    
    if (infoWindow) {
        return;
    }
    
    CGRect oldFrame = CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 20);
    CGRect newFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
    
    UIWindow *indicatorWin = [[UIWindow alloc] initWithFrame:newFrame];
    indicatorWin.windowLevel = UIWindowLevelAlert;
    [indicatorWin makeKeyAndVisible];
    
    infoWindow = indicatorWin;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = oldFrame;
    label.backgroundColor = [UIColor colorWithRed:0.124 green:0.783 blue:0.325 alpha:1.000];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.text = message;
    [indicatorWin addSubview:label];
    
    CGFloat duration = 0.25;
    
    NSArray *winds = [UIApplication sharedApplication].windows;
    
    for (UIWindow *w in winds) {
        NSLog(@"%f",w.windowLevel);
    }
    
    [UIView animateWithDuration:duration animations:^{
        label.frame = newFrame;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:duration animations:^{
                    label.frame = oldFrame;
                } completion:^(BOOL finished) {
                    [label removeFromSuperview];
                    [infoWindow resignKeyWindow];
                    infoWindow = nil;
                }];
            });
        });
        
    }];
    
}

#pragma mark - save task data
- (void)saveTasksData{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (!self.tasksArray || self.tasksArray.count == 0) {
        [manager removeItemAtPath:PLIST_PATH error:nil];
        return;
    }
    
    NSString *plistPath = PLIST_PATH;
    
    if (![manager fileExistsAtPath:plistPath isDirectory:NULL]) {
        [manager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (TaskModel *task in self.tasksArray) {
        
        [task pasueTask];
        NSDictionary *dic = @{@"fileUrl":task.downloadURL,@"fileName":task.fileName,@"fileSize":@(task.totalSize_Bit)};
        
        [array addObject:dic];
        
    }
    
    [array writeToFile:PLIST_PATH atomically:YES];
    
}

#pragma mark - initail task data
- (void)initTasksData{
    
    NSArray *tasks = [NSArray arrayWithContentsOfFile:PLIST_PATH];
    
    if (!tasks) {
        return;
    }
    
    for (NSDictionary *taskDict in tasks) {
        
        TaskModel *task = [[TaskModel alloc] initWithRebuildTaskURL:taskDict[@"fileUrl"] fileName:taskDict[@"fileName"]finishCallBack:^(TaskModel * _Nonnull taskModel) {
            if ([self.tasksArray containsObject:taskModel]) {
                [self.tasksArray removeObject:taskModel];
            }
        }];
        task.totalSize_Bit = [taskDict[@"fileSize"] longLongValue];
        [self.tasksArray addObject:task];
        
    }
    
}


@end
