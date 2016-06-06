//
//  MultiTaskDownloadCell.m
//  多任务下载
//
//  Created by 谢小龙 on 16/5/31.
//  Copyright © 2016年 xintong. All rights reserved.
//

#import "MultiTaskDownloadCell.h"

@interface MultiTaskDownloadCell ()<TaskModelDelegate>{
    
    UIProgressView *progressView;
    UIButton *controlBtn;
    
    UILabel *speedLabel;
    UILabel *contentLabel;
    
}

@end

@implementation MultiTaskDownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"pasue.jpg"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"play.jpg"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickControlBtn:) forControlEvents:UIControlEventTouchUpInside];
        controlBtn = btn;
        [self.contentView addSubview:btn];
        
        UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView = progress;
        [self.contentView addSubview:progress];
        
        UILabel *speed = [[UILabel alloc] init];
        speed.backgroundColor = [UIColor colorWithRed:0.746 green:0.941 blue:0.933 alpha:1.000];
        speed.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:speed];
        speedLabel = speed;
        
        UILabel *content = [[UILabel alloc] init];
        content.backgroundColor = [UIColor colorWithRed:0.736 green:0.761 blue:0.937 alpha:1.000];
        content.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:content];
        contentLabel = content;
        
    }
    return self;
}

- (void)setDownloadTask:(TaskModel *)downloadTask{
    _downloadTask = downloadTask;
    downloadTask.delegate = self;
    [self setTaskInfo];
}

- (void)setTaskInfo{
    
    if (self.downloadTask.taskState == DownloadTaskStatePasue) {
        controlBtn.selected = NO;
    }
    
    if (self.downloadTask.taskState == DownloadTaskStateRunning) {
        controlBtn.selected = YES;
    }
    
    contentLabel.text = [NSString stringWithFormat:@"%.2fm",self.downloadTask.totalSize_Bit/1000000.0];
    
}

- (void)clickControlBtn:(UIButton *)sender{
    
    if (sender.selected) {
        [self.downloadTask pasueTask];
    }else{
        [self.downloadTask restartTask];
    }
    
    sender.selected = !sender.selected;
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    controlBtn.frame = CGRectMake(5, 5, height - 10, height - 10);
    controlBtn.layer.cornerRadius = controlBtn.bounds.size.width/2;
    controlBtn.layer.masksToBounds = YES;
    
    progressView.frame = CGRectMake(CGRectGetMaxX(controlBtn.frame) + 8, CGRectGetMaxY(controlBtn.frame) - 20, width - CGRectGetMaxX(controlBtn.frame) - 8 - 8, 10);
    
    contentLabel.frame = CGRectMake(CGRectGetMinX(progressView.frame), CGRectGetMinY(progressView.frame) - 8 - 40, CGRectGetWidth(progressView.frame)/2, 40);
    
    speedLabel.frame = CGRectMake(CGRectGetMaxX(contentLabel.frame), CGRectGetMinY(contentLabel.frame), CGRectGetWidth(contentLabel.frame), 40);
}


#pragma mark - TaskModelDelegate

- (void)onGetDownloadSpeed:(float)speed{
    
    speedLabel.text = [NSString stringWithFormat:@"%.2fKB/S",speed];
    
}

- (void)onGetDownloadReceivedData:(int64_t)recrived totalData:(int64_t)total{
    
    progressView.progress = (float)recrived/total;
    contentLabel.text = [NSString stringWithFormat:@"%.2fm/%.2fm",(float)recrived/1000000,(float)total/1000000];
    
}

- (void)onTaskModelDidFinished:(TaskModel *)taskModel{
    NSLog(@"onTaskModelDidFinished");
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskFinished:)]) {
        [self.delegate onTaskFinished:self.tag];
    }
    self.downloadTask = nil;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
