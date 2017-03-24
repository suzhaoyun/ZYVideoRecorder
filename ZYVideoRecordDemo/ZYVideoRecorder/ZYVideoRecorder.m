//
//  ZYVideoRecord.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYVideoRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "ZYVideoWriter.h"

@interface ZYVideoRecorder ()<UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

/// 捕捉会话
@property (nonatomic, strong) AVCaptureSession *session;

/// 视频输入
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

/// 音频输入
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;

/// 视频写入
@property (nonatomic, strong) ZYVideoWriter *videoWriter;

@end

@interface ZYVideoRecorder ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ZYVideoRecorder

+ (instancetype)videoRecordWithPreview:(UIView *)preview
{
    ZYVideoRecorder *recorder = [[self alloc] init];
    recorder->_scenePosition = AVCaptureDevicePositionBack;
    AVCaptureVideoPreviewLayer *videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:recorder.session];
    videoLayer.frame = preview.bounds;
    [preview.layer insertSublayer:videoLayer atIndex:0];
    [recorder setUp];
    return recorder;
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

- (BOOL)switchScene
{
    // 确定要转换的摄像头
    AVCaptureDevicePosition position = _scenePosition==AVCaptureDevicePositionBack?AVCaptureDevicePositionFront:AVCaptureDevicePositionBack;
    
    AVCaptureDevice *device = [self deviceWithPosition:position];
    
    if (!device) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        return NO;
    }
    
    // 定制session
    [self.session stopRunning];
    
    // 移除原有的输入源
    [self.session removeInput:self.videoInput];
    
    if ([self.session canAddInput:input]) {
        // 切换新的输入源
        [self.session addInput:input];
        self.videoInput = input;
        _scenePosition = position;
        [self.session startRunning];
        return YES;
    }else{
        [self.session addInput:self.videoInput];
        [self.session startRunning];
        return NO;
    }
}

- (void)switchFlashWithMode:(AVCaptureFlashMode)mode
{
    AVCaptureDevice *device = [self deviceWithPosition:AVCaptureDevicePositionBack];
    if (device.flashMode != mode) {
        [device lockForConfiguration:NULL];
        device.torchMode = (int)mode;
        device.flashMode = mode;
        [device unlockForConfiguration];
        _flashMode = mode;
    }
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

/**
 添加视频输入
 */
- (void)addVideoInput
{
    AVCaptureDevice *device = [self deviceWithPosition:_scenePosition];
    
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

/**
 添加音频输入
 */
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

/**
 添加音视频输出
 */
- (void)addOutPut
{
    dispatch_queue_t global_q = dispatch_queue_create("ZYVideoRecorderQueue", DISPATCH_QUEUE_SERIAL);
    
    // 添加视频输出
    AVCaptureVideoDataOutput *videoDataOutPut = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutPut.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    [videoDataOutPut setSampleBufferDelegate:self queue:global_q];
    [self.session addOutput:videoDataOutPut];
    [videoDataOutPut connectionWithMediaType:AVMediaTypeVideo].videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 添加音频输出
    AVCaptureAudioDataOutput *audioDataOutPut = [[AVCaptureAudioDataOutput alloc] init];
    [audioDataOutPut setSampleBufferDelegate:self queue:global_q];
    [audioDataOutPut connectionWithMediaType:AVMediaTypeAudio];
    [self.session addOutput:audioDataOutPut];
}


/**
 收到音频视频数据输出的回调
 */
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


/**
 根据位置获取对应的摄像头

 @param position 位置
 @return 获得的设备
 */
- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

/**
 累加录像时间
 */
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
