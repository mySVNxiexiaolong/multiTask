//
//  MultiTaskDownloadController.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/31.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "MultiTaskDownloadController.h"
#import "MultiTaskManager.h"
#import "MultiTaskDownloadCell.h"

@interface MultiTaskDownloadController ()<MultiTaskDownloadCellDelegate>

@end

@implementation MultiTaskDownloadController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger number = [MultiTaskManager sharedInstance].tasksArray.count;
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cell";
//    MultiTaskDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    MultiTaskDownloadCell *cell = nil;
    
//    if (!cell) {
        cell = [[MultiTaskDownloadCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
//    }
    
    cell.downloadTask = [MultiTaskManager sharedInstance].tasksArray[indexPath.row];
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100.0;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaskModel *task = [MultiTaskManager sharedInstance].tasksArray[indexPath.row];
    
    [[MultiTaskManager sharedInstance] deleteTasks:@[task]];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)onTaskFinished:(NSInteger)tag{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    });
    
}

@end
