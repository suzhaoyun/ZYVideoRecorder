//
//  ZYRecordFocusView.m
//  ZYVideoRecordDemo
//
//  Created by ZYSu on 2016/12/27.
//  Copyright © 2016年 ZYSu. All rights reserved.
//

#import "ZYRecordFocusView.h"

@implementation ZYRecordFocusView
{
    UIImageView *_focusView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

/**
 *  进行初始化设置
 */
- (void)setUp
{
    _focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ZYVideoRecorder.bundle/icon-focus"]];
    _focusView.hidden = YES;
    [self addSubview:_focusView];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _focusView.bounds.size.width, _focusView.bounds.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _focusView.frame = CGRectMake(0, 0, _focusView.bounds.size.width, _focusView.bounds.size.height);
}

- (void)startFocusAnimation
{
    _focusView.hidden = NO;
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"transform.scale";
    animation.fromValue = @1.0;
    animation.toValue = @0.6;
    animation.duration = 0.5;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    [_focusView.layer addAnimation:animation forKey:@"foucs"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_focusView.layer removeAnimationForKey:@"foucs"];
        _focusView.hidden = YES;
    });
}

@end
