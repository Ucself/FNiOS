//
//  CarOwnerVehicleInforViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"
#import "CarOwnerVehicleModel.h"

@protocol CarOwnerVehicleInforViewControllerDelegate <NSObject>

-(void)controllerReturnBack;

@end

@interface CarOwnerVehicleInforViewController : CarOwnerBaseViewController

//传入的数据对象
@property (nonatomic, strong) CarOwnerVehicleModel *vehicleModel;
@property (nonatomic, assign) id<CarOwnerVehicleInforViewControllerDelegate> delegate;

@end
