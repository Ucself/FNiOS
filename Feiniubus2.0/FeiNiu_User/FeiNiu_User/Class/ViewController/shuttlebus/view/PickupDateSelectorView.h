//
//  DateSelectorVV.h
//  FeiNiu_User
//
//  Created by CYJ on 16/4/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickupDateSelectorView : UIView

@property (nonatomic,assign) NSInteger minuteInterval;      //时间间隔秒
@property (nonatomic,copy) NSDate *starTime;                //开始时间
@property (nonatomic,copy) NSDate *endTime;                 //结束时间

@property (nonatomic, copy) NSDate *specTime;        //指定显示的时间

@property (nonatomic,copy) void(^clickCompleteBlock)(NSString *dateString,NSDate *useDate,BOOL isReal);   //回调

- (instancetype)initWithFrame:(CGRect)frame starTime:(NSDate*)starTime endTime:(NSDate*)endTime minuteInterval:(NSInteger) minuteInterval;
- (void)showInView:(UIView *) view;
- (void)resetDateSource:(NSDate*)starTime endTime:(NSDate*)endTime minuteInterval:(NSInteger) minuteInterval;

@end
