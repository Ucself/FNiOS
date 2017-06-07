//
//  LeftDrawerViewController.h
//  CourseDemoSummary
//
//  Created by DreamHack on 15-7-10.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverBaseViewController.h"

@interface LeftDrawerViewController : DriverBaseViewController

//历程
@property(nonatomic,assign) float mileage;
//订单总数
@property(nonatomic,assign) int orderAmount;

//里程
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;
//单数
@property (weak, nonatomic) IBOutlet UILabel *orderAmountLabel;

//姓名
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
