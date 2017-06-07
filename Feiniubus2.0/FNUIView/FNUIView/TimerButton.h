//
//  TimingButton.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/9/4.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimerButtonDelegate <NSObject>

-(void)timerButtonClick:(id)sender;

@end

@interface TimerButton : UIButton

- (void)startTimerWithInitialCount:(NSInteger)index;
- (void)stopTimer;


@property (nonatomic, assign) BOOL isTiming;
@end
