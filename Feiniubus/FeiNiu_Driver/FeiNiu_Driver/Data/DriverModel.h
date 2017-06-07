//
//  CarOwnerDriverModel.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/7.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverModel : NSObject

//驾驶员id
@property (nonatomic,strong) NSString* driverId;
//驾驶员头像
@property (nonatomic,strong) NSString* driverHead;
//驾驶员名称
@property (nonatomic,strong) NSString* driverName;
//驾驶员电话号码
@property (nonatomic,strong) NSString* driverPhone;
//驾驶员得分
@property (nonatomic,assign) float driverRating;
//驾驶员里程
@property (nonatomic,assign) float driverMileage;
//驾驶员状态
@property (nonatomic,assign) int driverAudit;
//驾驶员出生日期
@property (nonatomic,strong) NSString* birthday;
//该司机的创建时间
@property (nonatomic,strong) NSString* createTime;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
