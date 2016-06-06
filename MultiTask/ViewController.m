//
//  ViewController.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/20.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "ViewController.h"
#import "MultiTaskManager.h"
#import "TaskModel.h"

#import "MultiTaskDownloadController.h"

@interface ViewController ()<TaskModelDelegate,NSURLSessionDelegate>

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) TaskModel *task;

@property (nonatomic, assign) NSInteger location;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urls = @[@"http://112.33.2.60:8082/mediamp4/6dbb3632-de68-4ba5-9775-0a3a60ba36ee=/480x240_1000k.mp4",
                  @"http://112.33.2.60:8082/mediamp4/852e6a97-733b-4bab-8f99-fd27ffba68fb=/1280x720_3000k.mp4"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 60, 30);
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"push" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(100, 150, 60, 30);
    addBtn.backgroundColor = [UIColor lightGrayColor];
    [addBtn setTitle:@"add" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(downLoadFiles:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}

- (void)downLoadFiles:(UIButton *)sender{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    [[MultiTaskManager sharedInstance] addDownloadMaskWithURL:self.urls.firstObject filePath:path fileName:nil];
}

- (void)pushVC:(id)sender{
    
    MultiTaskDownloadController *vc = [[MultiTaskDownloadController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)onTaskModelDidFinished:(TaskModel *)taskModel{
    
    self.task = nil;
    
}

@end
























