//
//  DriverTaskDetailViewController.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/9/15.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverBaseViewController.h"
#import "DriverTaskModel.h"
#import <MAMapKit/MAMapKit.h>

@interface DriverPackTaskDetailViewController : DriverBaseViewController

@property (nonatomic,strong) DriverTaskModel *taskModel;
//全局只用一个地图对象
@property (nonatomic,strong) MAMapView *mapView;

@end
