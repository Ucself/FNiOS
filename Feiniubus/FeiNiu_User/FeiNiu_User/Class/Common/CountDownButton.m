//
//  CountDownButton.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CountDownButton.h"

@interface CountDownButton (){
    NSTimer     *_timer;
    NSInteger   _startIndex;
    NSDate      *_startDate;
    NSInteger   _initialIndex;
}

@end
@implementation CountDownButton

#pragma mark - Public Methods
- (void)startAutoCountDownByInitialCount:(NSInteger)index{
    _startIndex = index;
    _initialIndex = index;
    _startDate = [NSDate date];
    [self setTitle:[NSString stringWithFormat:@"%@s",@(_startIndex)] forState:UIControlStateNormal];
    [self startTimer];
}

- (void)stopAutoCount{
    [self setTitle:@"重新获取验证码" forState:UIControlStateNormal];
    [self stopTimer];
}

#pragma mark - Private Methods
#pragma mark - Timer
- (void)startTimer{
    if (_timer) {
        [self stopTimer];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    self.enabled = NO;
}

- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
    self.enabled = YES;
}

- (void)handleTimer:(NSTimer *)timer{
    NSInteger delta = [[NSDate date]timeIntervalSinceDate:_startDate];
    NSInteger current = _initialIndex - delta;
    if (current >= 0) {
        [UIView performWithoutAnimation:^{
            [self setTitle:[NSString stringWithFormat:@"%@s",@(current)] forState:UIControlStateNormal];
            [self layoutIfNeeded];
        }];
    }else{
        [self stopAutoCount];
    }
//    _startIndex --;
//    if (_startIndex >= 0) {
//        [UIView performWithoutAnimation:^{
//            [self setTitle:[NSString stringWithFormat:@"%@s",@(_startIndex)] forState:UIControlStateNormal];
//            [self layoutIfNeeded];
//        }];
//    }else{
//        [self stopAutoCount];
//    }
}
@end
