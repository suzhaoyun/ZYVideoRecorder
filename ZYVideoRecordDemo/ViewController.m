//
//  ViewController.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYVideoRecorder.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (nonatomic, strong) ZYVideoRecorder *videoRecorder;

@property (nonatomic, strong) NSURL *videoURL;

@property (weak, nonatomic) IBOutlet UILabel *timeL;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self videoRecorder];
}
- (IBAction)start:(id)sender {
    BOOL res = [self.videoRecorder startRecord];
    if (res == NO) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请确保相机和麦克风权限已打开" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
        return;
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)update{
    self.timeL.text = [NSString stringWithFormat:@"%.1f", self.videoRecorder.currentDuration];
}

- (IBAction)stop:(id)sender {
    [self.timer invalidate];
    [self.videoRecorder stopRecordWithCompletion:^(NSURL *videoURL) {
        NSLog(@"%@", [NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoURL = videoURL;
        });
    }];
}

- (IBAction)play:(id)sender {
    
    UIViewController *vc = [UIStoryboard storyboardWithName:@"VideoListViewController" bundle:nil].instantiateInitialViewController;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)switchScene:(id)sender {
    [self.videoRecorder switchScene];
}

- (IBAction)flash:(id)sender {
    
    [self.videoRecorder switchFlashWithMode:self.videoRecorder.flashMode?0:1];
}

- (ZYVideoRecorder *)videoRecorder
{
    if (_videoRecorder == nil) {
        _videoRecorder = [ZYVideoRecorder videoRecordWithPreview:self.view];
    }
    return _videoRecorder;
}

@end
