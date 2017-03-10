//
//  ZYVideoRecord.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYVideoRecord.h"
#import <AVFoundation/AVFoundation.h>

static NSUInteger AudioAlertTag = 10;
static NSUInteger VideoAlertTag = 11;

@interface ZYVideoRecord ()<UIAlertViewDelegate>

/// 捕捉会话
@property (nonatomic, strong) AVCaptureSession *session;

/// 视频输入
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

/// 音频输入
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;

@end

@implementation ZYVideoRecord

+ (instancetype)videoRecordWithPreview:(UIView *)preview
{
    ZYVideoRecord *record = [[self alloc] init];
    AVCaptureVideoPreviewLayer *videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:record.session];
    videoLayer.frame = preview.bounds;
    [preview.layer insertSublayer:videoLayer atIndex:0];
    [record setUp];
    return record;
}

#pragma mark - public method

#pragma mark - private method
- (void)setUp
{
    /// 重新检测摄像头和麦克风权限
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetInput) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self addVideoInput];
    
    [self addAudioInput];
    
    [self.session startRunning];
}

- (void)resetInput
{
    if (self.audioInput == nil) {
        [self addAudioInput];
    }
    
    if (self.videoInput == nil) {
        [self addVideoInput];
    }
}

/// 添加视频输入
- (void)addVideoInput
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device;
    for (AVCaptureDevice *d in devices) {
        if (d.position == AVCaptureDevicePositionBack) {
            device = d;
            break;
        }
    }
    
    if (!device) {
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input && !error) {
        if ([self.session canAddInput:input]) {
            [self.session addInput:input];
            self.videoInput = input;
        }
    }
}

/// 添加音频输入
- (void)addAudioInput
{
    AVCaptureDevice *device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    if (!device) {
        return;
    }

    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input && !error) {
        if ([self.session canAddInput:input]) {
            [self.session addInput:input];
            self.audioInput = input;
        }
    }
}

- (void)addOutPut
{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AudioAlertTag) {
        
    }
    else if (alertView.tag == VideoAlertTag){
        
    }

}

#pragma mark - laze method
- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

@end
