//
//  TaskFilterView.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//时间类型
typedef NS_ENUM(int, FilterTimeType)
{
    FilterTimeTypeDay = 1,
    FilterTimeTypeWeek,
    FilterTimeTypeMonth,
};

//任务类型
typedef NS_ENUM(int, FilterTaskType)
{
    FilterTaskTypeCurrent = 1,
    FilterTaskTypeComplete,
};

@protocol TaskFilterViewDelegate <NSObject>

- (void)taskFilterViewViewReset;
- (void)taskFilterViewOK:(float)selectStartPrice selectEndPrice:(float)selectEndPrice selectFilterTimeType:(FilterTimeType)selectFilterTimeType selectFilterTaskType:(FilterTaskType)selectFilterTaskType;

@end


@interface TaskFilterView : UIView


@property(nonatomic,assign) float startPrice;
@property(nonatomic,assign) float endPrice;
@property(nonatomic,assign) FilterTimeType dateType;
@property(nonatomic,assign) FilterTaskType taskType;

@property(nonatomic,assign) id<TaskFilterViewDelegate> delegate;

//设置传入的值
-(void)setViewValue;

- (void)showInView:(UIView *) view;
- (void)cancelSelect:(UIView *) view;

@end
