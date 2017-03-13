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

@interface ZYVideoRecord : NSObject

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
@interface ZYVideoRecord ()

/// 初始化录像类
+ (instancetype)videoRecordWithPreview:(UIView *)preview;

/// 开始录制
/// BOOL : 是否成功
- (BOOL)startRecord;

/// 停止录制
/// return : fileURL
- (NSString *)stopRecord;

/// 切换摄像头
/// BOOL : 是否成功
- (BOOL)switchScene;

/// 切换闪光灯
/// BOOL : 是否成功
- (BOOL)switchFlashWithMode:(AVCaptureFlashMode)mode;

@end
