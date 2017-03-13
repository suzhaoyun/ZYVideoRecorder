//
//  ZYVideoWriter.h
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/3/13.
//  Copyright © 2017年 ZYSu. All rights reserved.
//  写入视频文件到沙盒

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface ZYVideoWriter : NSObject

/// 根据输入数据 初始化writer
+ (instancetype)videoWriterWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// 开始录像
- (void)startToRecord;

/// 添加音频数据
- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// 添加视频数据
- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// 停止录像
/// return : URL
- (void)stopRecord;

/// 视频文件URL fileURL
@property (nonatomic, copy, readonly) NSString *videoURL;

@end
