//
//  CarOwnerTaskModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/22.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerTaskModel.h"

@implementation CarOwnerTaskModel

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
        if ([dictionary objectForKey:@"starting"])
        {
            NSDictionary *startingDic = [dictionary objectForKey:@"starting"];
            self.startName = [startingDic objectForKey:@"detailAddress"] ? [startingDic objectForKey:@"detailAddress"] :@"";
        }
        else{
            self.startName = @"";
        }
        //目的地
        if ([dictionary objectForKey:@"destination"])
        {
            NSDictionary *startingDic = [dictionary objectForKey:@"destination"];
            self.destinationName = [startingDic objectForKey:@"detailAddress"] ? [startingDic objectForKey:@"detailAddress"] :@"";
        }
        else{
            self.destinationName = @"";
        }
        //订单价格
        self.price = [dictionary objectForKey:@"quotation"] ? [[dictionary objectForKey:@"quotation"] floatValue] : 0.0;
        //订单里程
        self.mileage = [dictionary objectForKey:@"kilometers"] ? [[dictionary objectForKey:@"kilometers"] floatValue] : 0.0;
        //车辆等级名称
        self.vehicleLevelName = [dictionary objectForKey:@"levelName"] && ![[dictionary objectForKey:@"levelName"] isKindOfClass:[NSNull class]] ? [dictionary objectForKey:@"levelName"] : @"";
        //车辆类型名称
        self.vehicleTypeName = [dictionary objectForKey:@"typeName"]  && ![[dictionary objectForKey:@"typeName"] isKindOfClass:[NSNull class]] ? [dictionary objectForKey:@"typeName"] : @"";
        //座位数
        self.seats = [dictionary objectForKey:@"seat"] ? [[dictionary objectForKey:@"seat"] intValue] : 0;
        //车辆牌照
        self.licensePlate = [dictionary objectForKey:@"licensePlate"] ? [dictionary objectForKey:@"licensePlate"] : @"";
        //司机名称
        self.driverName = [dictionary objectForKey:@"driverName"] ? [dictionary objectForKey:@"driverName"] : @"";
        //司机名称
        self.driverPhone = [dictionary objectForKey:@"driverPhone"] ? [dictionary objectForKey:@"driverPhone"] : @"";
        //抢单开始时间
        self.waitStartTime = [dictionary objectForKey:@"waiteStartTime"] ? [dictionary objectForKey:@"waiteStartTime"] : @"";
        //联系人姓名
        self.contacterName = [dictionary objectForKey:@"memberName"] ? [dictionary objectForKey:@"memberName"] : @"";
        //联系人电话
        self.contacterPhone = [dictionary objectForKey:@"memberPhone"] ? [dictionary objectForKey:@"memberPhone"] : @"";
    }
    
    return self;
}

@end
