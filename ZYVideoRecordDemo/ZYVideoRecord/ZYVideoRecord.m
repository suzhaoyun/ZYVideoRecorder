//
//  ZYVideoRecord.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYVideoRecord.h"
#import <AVFoundation/AVFoundation.h>
#import "ZYVideoWriter.h"

@interface ZYVideoRecord ()<UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

/// 捕捉会话
@property (nonatomic, strong) AVCaptureSession *session;

/// 视频输入
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

/// 音频输入
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;

/// 视频写入
@property (nonatomic, strong) ZYVideoWriter *videoWriter;

@end

@interface ZYVideoRecord ()

@property (nonatomic, strong) NSTimer *timer;

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
- (BOOL)startRecord
{
    if (self.audioInput == nil || self.videoInput == nil) {
        return NO;
    }

    _isRecording = YES;
    _currentDuration = 0.0;
    
    // 开始计时
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    [self.timer fire];
    
    return YES;
}

- (void)stopRecordWithCompletion:(void (^)(NSURL *))completion
{
    _isRecording = NO;
    [self.videoWriter stopRecordWithCompletion:^(NSURL *videoURL) {
        if (completion) {
            completion(videoURL);
            _videoWriter = nil;
        }
    }];
}

#pragma mark - private method
- (void)setUp
{
    /// 重新检测摄像头和麦克风权限
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetInput) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self addVideoInput];
    
    [self addAudioInput];
    
    [self addOutPut];
    
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

/// 添加音视频输出
- (void)addOutPut
{
    dispatch_queue_t global_q = dispatch_get_global_queue(0, 0);
    AVCaptureVideoDataOutput *videoDataOutPut = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutPut.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    [videoDataOutPut setSampleBufferDelegate:self queue:global_q];
    [self.session addOutput:videoDataOutPut];
    [videoDataOutPut connectionWithMediaType:AVMediaTypeVideo].videoOrientation = AVCaptureVideoOrientationPortrait;
    
    AVCaptureAudioDataOutput *audioDataOutPut = [[AVCaptureAudioDataOutput alloc] init];
    [audioDataOutPut setSampleBufferDelegate:self queue:global_q];
    [audioDataOutPut connectionWithMediaType:AVMediaTypeAudio];
    [self.session addOutput:audioDataOutPut];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    /// 初始化视频写入者
    if (_videoWriter == nil && [captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]]) {
        _videoWriter = [ZYVideoWriter videoWriterWithSampleBuffer:sampleBuffer];
    }
    
    if (!self.isRecording) {
        return;
    }
    
    if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        [self.videoWriter appendSampleBuffer:sampleBuffer isVideo:YES];
        NSLog(@"-------视频.....");
    }
    else if ([captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]]){
        [self.videoWriter appendSampleBuffer:sampleBuffer isVideo:NO];
        NSLog(@"-------音频.....");
    }
}

- (void)timeUpdate
{
    _currentDuration+=0.1;
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
