//
//  TimerButton.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TimerButton.h"

@interface TimerButton (){
    NSTimer *_timer;
    NSInteger   _maxSeconds;
    NSInteger   _seconds;
}

@end
@implementation TimerButton
- (NSString *)timeoutTitle{
    return [self titleForState:UIControlStateSelected];
}
#pragma mark - 
- (void)startTimerAtTime:(NSTimeInterval)seconds{
    if (seconds <= 0) {
        seconds = 0;
    }
    _seconds = seconds;
    [self startTimer];
}
- (void)startTimer{
    if (_timer) {
        [self stopTimer];
    }
    _maxSeconds = 35 * 60 + self.startTime;
    if (_seconds >= _maxSeconds) {
        [self setTitle:[self timeoutTitle] forState:UIControlStateNormal];
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [self displaySeconds:_seconds];
//    [self setTitle:[NSString stringWithFormat:@"%02d:%02d", (int)(_seconds / 60), (int)(_seconds % 60)] forState:UIControlStateNormal];
    self.enabled = NO;
}
- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
    self.enabled = YES;
}
- (void)handleTimer:(NSTimer *)timer{
    if (_seconds >= _maxSeconds) {
        [self setTitle:[self timeoutTitle] forState:UIControlStateNormal];
        [self stopTimer];
    }else{
        _seconds ++;
        [self displaySeconds:_seconds];
    }
}

- (void)displaySeconds:(NSInteger)seconds{
    [self setTitle:[NSString stringWithFormat:@"%02d:%02d", (int)(seconds / 60), (int)(seconds % 60)] forState:UIControlStateNormal];
}
#pragma mark - Override Methods
- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    [UIView performWithoutAnimation:^{
        [super setTitle:title forState:state];
        [self layoutIfNeeded];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
