//
//  ZYVideoRecord.h
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2017/2/27.
//  Copyright © 2017年 ZYSu. All rights reserved.
//  自定义的录像类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ZYVideoRecorder : NSObject

/// 当前的录制时长
@property (nonatomic, assign, readonly) NSTimeInterval currentDuration;

/// 是否正在录制
@property (nonatomic, assign, readonly) NSTimeInterval isRecording;

/// 摄像头位置
@property (nonatomic, assign, readonly) AVCaptureDevicePosition scenePosition;

/// 闪光灯状态
@property (nonatomic, assign, readonly) AVCaptureFlashMode flashMode;

@end

/// 方法
@interface ZYVideoRecorder ()

/// 初始化录像类
+ (instancetype)videoRecordWithPreview:(UIView *)preview;

/// 开始录制
/// BOOL : 是否成功
- (BOOL)startRecord;

/**
 停止录像
 
 @param completion 完成的回调
 @videoURL 录制的文件的FileURL
 */
- (void)stopRecordWithCompletion:(void (^)(NSURL *videoURL))completion;

/// 切换摄像头
/// BOOL : 是否成功
- (BOOL)switchScene;

/// 切换闪光灯
/// BOOL : 是否成功
- (BOOL)switchFlashWithMode:(AVCaptureFlashMode)mode;

@end
