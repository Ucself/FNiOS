//
//  CarOwnerTaskDetailViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"
#import "CarOwnerTaskModel.h"
#import <MAMapKit/MAMapKit.h>

@interface CarOwnerTaskDetailViewController : CarOwnerBaseViewController

@property (nonatomic,strong) CarOwnerTaskModel *taskModel;
//全局只用一个地图对象
@property (nonatomic,strong) MAMapView *mapView;

@end
