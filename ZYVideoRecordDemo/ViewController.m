//
//  ViewController.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYVideoRecord.h"

@interface ViewController ()

@property (nonatomic, strong) ZYVideoRecord *videoRecord;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self videoRecord];
}

- (ZYVideoRecord *)videoRecord
{
    if (_videoRecord == nil) {
        _videoRecord = [ZYVideoRecord videoRecordWithPreview:self.view];
    }
    return _videoRecord;
}

@end
