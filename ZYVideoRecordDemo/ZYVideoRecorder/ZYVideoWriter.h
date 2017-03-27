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

/**
 根据输入数据 初始化writer
 */
+ (instancetype)videoWriterWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 添加音视频数据
 */
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;

/**
 停止录像

 @param completion 完成的回调
 @videoURL 录制的文件的FileURL
 */
- (void)stopRecordWithCompletion:(void (^)(NSURL *videoURL))completion;

@end
