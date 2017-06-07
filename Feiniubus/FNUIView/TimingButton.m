//
//  TimingButton.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/9/4.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "TimingButton.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TimingButton ()
{
    //秒数
    double seconds;
}
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation TimingButton

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    //初始化属性
    _timeInterval = 60;
    _buttonTitle = @"获取验证码";
    _isTiming = NO;
    _currentTextColor = UIColorFromRGB(0xFF5A37);
    _timingColor = [UIColor grayColor];
}

-(void)setCurrentTextColor:(UIColor *)currentTextColor
{
    [self setTitleColor:currentTextColor forState:UIControlStateNormal];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self beginTimer:nil];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark ----
- (void)beginTimer:(NSString *)buttonCode
{
    if (_isTiming) {
        return;
    }
    [_timer invalidate];
    seconds = _timeInterval;
    _isTiming = YES;
    
    __block TimingButton *blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        blockSelf->_timer=[NSTimer timerWithTimeInterval:1
                                                  target:blockSelf
                                                selector:@selector(timerPro)
                                                userInfo:nil
                                                 repeats:YES] ;
        
        
        [[NSRunLoop currentRunLoop] addTimer:blockSelf->_timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        
    });
    _timer=[NSTimer timerWithTimeInterval:0.1
                                   target:blockSelf
                                 selector:@selector(timerPro)
                                 userInfo:nil
                                  repeats:YES] ;
    //    按钮点击
    if ([self.delegate respondsToSelector:@selector(timingButtonClick:)]) {
        [self.delegate timingButtonClick:self];
    }
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    //还原数据
    [self setTitleColor:_currentTextColor forState:UIControlStateNormal];
    [self setTitle:_buttonTitle forState:UIControlStateNormal];
    _isTiming = NO;
}

-(void)timerPro
{
    //设置字体颜色
    if (seconds == _timeInterval) {
        [self setTitleColor:_timingColor forState:UIControlStateNormal];
    }
    //设置读秒
    if (_isTiming && seconds > 0) {
        seconds --;
        [self setTitle:[[NSString alloc] initWithFormat:@"%ds",(int)seconds] forState:UIControlStateNormal];
    }
    else
    {
        [self stopTimer];
    }
}
@end








