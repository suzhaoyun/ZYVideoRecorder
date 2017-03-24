//
//  ViewController.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYVideoRecord.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (nonatomic, strong) ZYVideoRecord *videoRecord;

@property (nonatomic, strong) NSURL *videoURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self videoRecord];
}
- (IBAction)start:(id)sender {
    [self.videoRecord startRecord];
}
- (IBAction)stop:(id)sender {
    if (self.videoRecord.isRecording) {
        [self.videoRecord stopRecordWithCompletion:^(NSURL *videoURL) {
            NSLog(@"%@", [NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoURL = videoURL;
            });
        }];
    }
}
- (IBAction)play:(id)sender {
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoURL];
    [self presentViewController:vc animated:YES completion:nil];
}


- (ZYVideoRecord *)videoRecord
{
    if (_videoRecord == nil) {
        _videoRecord = [ZYVideoRecord videoRecordWithPreview:self.view];
    }
    return _videoRecord;
}

@end
