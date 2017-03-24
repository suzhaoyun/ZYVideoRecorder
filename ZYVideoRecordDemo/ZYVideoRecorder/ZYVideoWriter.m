//
//  ZYVideoWriter.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/3/13.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYVideoWriter.h"
#import <AVFoundation/AVFoundation.h>

@interface ZYVideoWriter ()

/// 缓存文件的完整路径
@property (nonatomic, copy) NSString *cachePath;

/// 文件写入者
@property (nonatomic, strong) AVAssetWriter *writer;

/// 视频输入
@property (nonatomic, strong) AVAssetWriterInput *videoInput;

/// 音频输入
@property (nonatomic, strong) AVAssetWriterInput *audioInput;

/// 视频文件URL fileURL
@property (nonatomic, copy) NSURL *videoURL;

@end

/// 缓存文件夹
static NSString *VideoCacheDirectory = @"ZYVideoRecordCache";

@implementation ZYVideoWriter

+ (instancetype)videoWriterWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    ZYVideoWriter *videoWriter = [[self alloc] init];
    
    [videoWriter checkCachePath];
    
    [videoWriter initPropertiesWithSampleBuffer:sampleBuffer];
    
    return videoWriter;
}

/**
 检测缓存目录
 */
- (void)checkCachePath
{
    // 检测缓存文件夹是否存在
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:VideoCacheDirectory];
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (!isDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    _cachePath = path;
}

- (void)initPropertiesWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 1. 初始化文件写入者
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd_HH:mm:ss_video";
    NSString *filename = [NSString stringWithFormat:@"%@.mp4", [fmt stringFromDate:[NSDate date]]];
    _videoURL = [NSURL fileURLWithPath:[self.cachePath stringByAppendingPathComponent:filename]];
    _writer = [AVAssetWriter assetWriterWithURL:_videoURL fileType:AVFileTypeMPEG4 error:NULL];
    // 网络播放
    _writer.shouldOptimizeForNetworkUse = YES;
    
    // 2. 初始化视频输入源
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey:AVVideoCodecH264, AVVideoWidthKey : @720, AVVideoHeightKey : @1280}];
    
    //表明输入是否应该调整其处理为实时数据源的数据
    _videoInput.expectsMediaDataInRealTime = YES;
    //将视频输入源加入
    [_writer addInput:_videoInput];
    
    
    // 3. 初始化音频输入源
    //音频的一些配置包括音频各种这里为AAC,音频通道、采样率和音频的比特率
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(CMSampleBufferGetFormatDescription(sampleBuffer));
    _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:@{AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVNumberOfChannelsKey : @(asbd->mChannelsPerFrame), AVSampleRateKey : @(asbd->mSampleRate), AVEncoderBitRateKey : @128000}];
    //表明输入是否应该调整其处理为实时数据源的数据
    _audioInput.expectsMediaDataInRealTime = YES;
    //将音频输入源加入
    [_writer addInput:_audioInput];
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo
{
    //数据是否准备写入
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        //写入状态为未知,保证视频先写入
        if (_writer.status == AVAssetWriterStatusUnknown && isVideo) {
            //获取开始写入的CMTime
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            //开始写入
            [_writer startWriting];
            [_writer startSessionAtSourceTime:startTime];
        }
        //写入失败
        if (_writer.status == AVAssetWriterStatusFailed) {
            NSLog(@"写入失败%@", _writer.error.localizedDescription);
        }
        //判断是否是视频
        if (isVideo) {
            //视频输入是否准备接受更多的媒体数据
            if (_videoInput.readyForMoreMediaData == YES) {
                //拼接数据
                [_videoInput appendSampleBuffer:sampleBuffer];
            }
        }else {
            //音频输入是否准备接受更多的媒体数据
            if (_audioInput.readyForMoreMediaData) {
                //拼接数据
                [_audioInput appendSampleBuffer:sampleBuffer];
            }
        }
    }
}

- (void)stopRecordWithCompletion:(void (^)(NSURL *))completion
{
    [self.writer finishWritingWithCompletionHandler:^{
        if (completion) {
            completion(self.videoURL);
        }
    }];
}

@end
