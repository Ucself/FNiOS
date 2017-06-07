//
//  CarOwnerOrderModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerOrderModel.h"

@implementation CarOwnerOrderModel


//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSDictionary class]] || !dictionary) {
            return self;
        }
        //订单Id
        self.subOrderId = [dictionary objectForKey:@"subOrderId"] ? [dictionary objectForKey:@"subOrderId"] : @"";
        //订单状态
        self.orderState = [dictionary objectForKey:@"orderState"] ? [[dictionary objectForKey:@"orderState"] intValue] : 0;
        //订单开始时间
        self.startTime = [dictionary objectForKey:@"startingTime"] ? [dictionary objectForKey:@"startingTime"] : @"";
        //订单结束时间
        self.endTime = [dictionary objectForKey:@"returnTime"] ? [dictionary objectForKey:@"returnTime"] : @"";
        //出发地
//        if ([dictionary objectForKey:@"starting"])
//        {
//            NSDictionary *startingDic = [dictionary objectForKey:@"starting"];
//            self.startName = [startingDic objectForKey:@"detailAddress"] ? [startingDic objectForKey:@"detailAddress"] :@"";
//        }
//        else{
//            self.startName = @"";
//        }
        //出发地
        self.startName = [dictionary objectForKey:@"startingName"] ? [dictionary objectForKey:@"startingName"] :@"";
        //目的地
//        if ([dictionary objectForKey:@"destination"])
//        {
//            NSDictionary *startingDic = [dictionary objectForKey:@"destination"];
//            self.destinationName = [startingDic objectForKey:@"detailAddress"] ? [startingDic objectForKey:@"detailAddress"] :@"";
//        }
//        else{
//            self.destinationName = @"";
//        }
        //目的地
        self.destinationName = [dictionary objectForKey:@"destinationName"] ? [dictionary objectForKey:@"destinationName"] :@"";
        //订单价格
        self.price = [dictionary objectForKey:@"price"] ? [[dictionary objectForKey:@"price"] floatValue] : 0.0;
        //订单里程
        self.mileage = [dictionary objectForKey:@"mileage"] ? [[dictionary objectForKey:@"mileage"] floatValue] : 0.0;
        //车辆等级名称
        self.vehicleLevelName = [dictionary objectForKey:@"vehicleLevelName"] ? [dictionary objectForKey:@"vehicleLevelName"] : @"";
        //车辆类型名称
        self.vehicleTypeName = [dictionary objectForKey:@"typeName"] ? [dictionary objectForKey:@"typeName"] : @"";
        //座位数
        self.seats = [dictionary objectForKey:@"seats"] ? [[dictionary objectForKey:@"seats"] intValue] : 0;
        //车辆牌照
        self.licensePlate = [dictionary objectForKey:@"licensePlate"] ? [dictionary objectForKey:@"licensePlate"] : @"";
        //司机名称
        self.driverName = [dictionary objectForKey:@"driverName"] ? [dictionary objectForKey:@"driverName"] : @"";
        //司机名称
        self.driverPhone = [dictionary objectForKey:@"driverPhone"] ? [dictionary objectForKey:@"driverPhone"] : @"";
        //抢单开始时间
        self.waitStartTime = [dictionary objectForKey:@"waiteStartTime"] ? [dictionary objectForKey:@"waiteStartTime"] : @"";
    }
    
    return self;
}

@end
