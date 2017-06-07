//
//  CarOwnerTaskModel.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/22.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarOwnerTaskModel : NSObject

//订单Id
@property (nonatomic,strong) NSString *subOrderId;
//订单价格
@property (nonatomic,assign) float price;
//订单状态
@property (nonatomic,assign) int orderState;
//订单开始时间
@property (nonatomic,strong) NSString *startTime;
//订单结束时间
@property (nonatomic,strong) NSString *endTime;
//出发地
@property (nonatomic,strong) NSString *startName;
//目的地
@property (nonatomic,strong) NSString *destinationName;
//订单里程
@property (nonatomic,assign) float mileage;
//车辆等级名称
@property (nonatomic,strong) NSString *vehicleLevelName;
//车辆类型名称
@property (nonatomic,strong) NSString *vehicleTypeName;
//座位数
@property (nonatomic,assign) int seats;
//车辆牌照
@property (nonatomic,strong) NSString *licensePlate;
//司机名称
@property (nonatomic,strong) NSString *driverName;
//司机电话
@property (nonatomic,strong) NSString *driverPhone;
//抢单等待开始时间
@property (nonatomic,strong) NSString *waitStartTime;

//联系人姓名
@property (nonatomic,strong) NSString *contacterName;
//联系人电话
@property (nonatomic,strong) NSString *contacterPhone;

//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
