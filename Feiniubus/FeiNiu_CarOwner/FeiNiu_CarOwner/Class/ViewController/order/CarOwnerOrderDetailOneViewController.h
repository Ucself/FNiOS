//
//  CarOwnerOrderDetailOneViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"
#import "CarOwnerOrderModel.h"

@interface CarOwnerOrderDetailOneViewController : CarOwnerBaseViewController

@property(nonatomic,strong) CarOwnerOrderModel *orderModel;

//空置车辆信息   包含id 和 name
@property(nonatomic,strong) NSMutableArray *vehicleArray;
//空闲驾驶员
@property(nonatomic,strong) NSMutableArray *driverArray;

//选中的车辆信息
@property(nonatomic,strong) NSDictionary *vehicleSelectDic;
//选中的驾驶员信息
@property(nonatomic,strong) NSDictionary *driverSelectDic;

@end
