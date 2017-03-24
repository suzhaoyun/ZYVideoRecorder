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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self videoRecorder];
}
- (IBAction)start:(id)sender {
    [self.videoRecorder startRecord];
}
- (IBAction)stop:(id)sender {
    if (self.videoRecorder.isRecording) {
        [self.videoRecorder stopRecordWithCompletion:^(NSURL *videoURL) {
            NSLog(@"%@", [NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoURL = videoURL;
            });
        }];
    }
}
- (IBAction)play:(id)sender {
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoURL];
    vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)switch:(id)sender {
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
