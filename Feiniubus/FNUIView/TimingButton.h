//
//  TimingButton.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/9/4.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimingButtonDelegate <NSObject>

-(void)timingButtonClick:(id)sender;

@end

@interface TimingButton : UIButton

@property (nonatomic,assign) id<TimingButtonDelegate>delegate;
@property (nonatomic, assign) int timeInterval;
@property (nonatomic, assign) BOOL isTiming;

//按钮设置
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIColor *currentTextColor;
@property (nonatomic, strong) UIColor *timingColor;

@end
