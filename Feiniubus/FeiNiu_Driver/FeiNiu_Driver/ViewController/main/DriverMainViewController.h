//
//  DriverMainViewController.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/12.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverBaseViewController.h"

@protocol DriverMainViewControllerDelegate <NSObject>

//个人中心点击
-(void)PersonalCenterClick;

@end

@interface DriverMainViewController : DriverBaseViewController

@property(nonatomic,assign) id<DriverMainViewControllerDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UILabel *leftTime;
@property (weak, nonatomic) IBOutlet UILabel *rightTime;


@end
