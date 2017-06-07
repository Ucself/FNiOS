//
//  CountDownButton.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TimerButton.h"

@interface TimerButton (){
    NSTimer     *_timer;
    NSInteger   _startIndex;
    NSDate      *_startDate;
    NSInteger   _initialIndex;
}

@end
@implementation TimerButton

#pragma mark - Public Methods
- (void)startTimerWithInitialCount:(NSInteger)index{
    _startIndex = index;
    _initialIndex = index;
    _startDate = [NSDate date];
    [self setTitle:[NSString stringWithFormat:@"%@s",@(_startIndex)] forState:UIControlStateNormal];
    [self startTimer];
}


#pragma mark - Private Methods
#pragma mark - Timer
- (void)startTimer{
    if (_timer) {
        [self stopTimer];
    }
    
    [self setTitleColor:UITextColor_LightGray forState:UIControlStateNormal];
    _isTiming = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    self.enabled = NO;
}

- (void)stopTimer{
    [self setBackgroundColor:UIColor.whiteColor];
    [self setTitleColor:UIColorFromRGB(0xFE6E35) forState:UIControlStateNormal];
    [self setTitle:@"重新发送" forState:UIControlStateNormal];
    [_timer invalidate];
    _timer = nil;
    _isTiming = NO;
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
        [self stopTimer];
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
