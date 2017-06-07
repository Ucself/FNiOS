//
//  CarOwnerTaskModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/22.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "DriverCarpoolingTaskModel.h"

@implementation DriverCarpoolingTaskModel

//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass:[NSNull class]] || !dictionary) {
            return self;
        }
        //班次Id
        self.scheduleId = [dictionary objectForKey:@"scheduleId"] ? [dictionary objectForKey:@"scheduleId"] : @"";
        //出发时间
        self.startingDate = [dictionary objectForKey:@"startingDate"] ? [dictionary objectForKey:@"startingDate"] : @"";
        //出发具体时间
        self.startingTime = [dictionary objectForKey:@"startingTime"] ? [dictionary objectForKey:@"startingTime"] : @"";
        //出发地点
        self.startingName = [dictionary objectForKey:@"startingName"] ? [dictionary objectForKey:@"startingName"] : @"";
        //目的地点
        self.destinationName = [dictionary objectForKey:@"destinationName"] ? [dictionary objectForKey:@"destinationName"] : @"";
        //车牌号
        self.vehicleLicensePlate = [dictionary objectForKey:@"vehicleLicensePlate"] && ![[dictionary objectForKey:@"vehicleLicensePlate"] isKindOfClass:[NSNull class]]? [dictionary objectForKey:@"vehicleLicensePlate"] : @"";
        //车辆类型名称
        self.vehicleTypeName = [dictionary objectForKey:@"vehicleType"] && ![[dictionary objectForKey:@"vehicleType"] isKindOfClass:[NSNull class]] ? [dictionary objectForKey:@"vehicleType"] : @"";
        //车辆等级名称
        self.vehicleLevelName = [dictionary objectForKey:@"vehicleLevel"] && ![[dictionary objectForKey:@"vehicleLevel"] isKindOfClass:[NSNull class]]? [dictionary objectForKey:@"vehicleLevel"] : @"";
        //车辆座位数
        self.vehicleSteats = [dictionary objectForKey:@"vehicleSteats"] ? [[dictionary objectForKey:@"vehicleSteats"] intValue] : 0;
        //乘坐人数
        self.peopleAmount = [dictionary objectForKey:@"peopleAmount"] ? [[dictionary objectForKey:@"peopleAmount"] intValue] : 0;
        //任务状态
        self.orderStatus = [dictionary objectForKey:@"orderStatus"] ? [[dictionary objectForKey:@"orderStatus"] intValue] : 0;
    }
    
    return self;
}

@end
