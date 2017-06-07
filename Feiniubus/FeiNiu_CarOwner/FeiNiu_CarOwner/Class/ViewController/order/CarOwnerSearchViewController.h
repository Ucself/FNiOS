//
//  CarOwnerCompanySearchViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"
//时间类型
typedef NS_ENUM(int, RequestDataType)
{
    RequestDataTypeVehicle = 0,
    RequestDataTypeDriver,
};


@protocol CarOwnerSearchViewControllerDelegate <NSObject>

-(void)seachSelected:(NSObject*)seachInfor requestType:(RequestDataType)requestType;

@end

@interface CarOwnerSearchViewController: CarOwnerBaseViewController

@property(nonatomic, assign) id<CarOwnerSearchViewControllerDelegate> delegate;
//配置车辆还是配置驾驶员
@property(nonatomic,assign) RequestDataType requestType;
//搜索开始时间
@property(nonatomic,strong) NSString *startTime;
//搜索结束时间
@property(nonatomic,strong) NSString *endTime;

@end
