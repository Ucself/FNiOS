//
//  CarOwnerNotThroughVehicleViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"

@interface CarOwnerNotThroughVehicleViewController : CarOwnerBaseViewController

/**
 *  数据源属性
 */
//经营范围
@property (nonatomic, strong) NSMutableArray *businessScopeArray;
//座位数
@property (nonatomic, strong) NSMutableArray *seatNumberArray;
//车型等级
@property (nonatomic, strong) NSMutableArray *vehicleLevelArray;
//燃油类别
@property (nonatomic, strong) NSMutableArray *fuelTypeArray;
//错误提示信息
@property (nonatomic, strong) NSMutableArray *errorInfo;
/**
 *  当前展示的数据数据源
 */
//公司名称
@property (nonatomic, strong) NSObject *companyName;
//经营范围
@property (nonatomic, strong) NSObject *businessScope;
//车辆牌照
@property (nonatomic, strong) NSObject *vehicleLicense;
//座位数
@property (nonatomic, strong) NSObject *seatNumber;
//车辆等级
@property (nonatomic, strong) NSObject *vehicleLevel;
//燃油类别
@property (nonatomic, strong) NSObject *fuelType;
//上户时间
@property (nonatomic, strong) NSObject *registTime;
//运营证  state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
@property (nonatomic, strong) NSMutableArray *operateCertificate;
//车的照片 state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
@property (nonatomic, strong) NSMutableArray *carPhotos;

@end
