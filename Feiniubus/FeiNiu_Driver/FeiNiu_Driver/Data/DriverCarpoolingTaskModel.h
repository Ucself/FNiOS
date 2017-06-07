//
//  CarOwnerTaskModel.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/22.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverCarpoolingTaskModel : NSObject

//班次Id
@property (nonatomic,strong) NSString *scheduleId;
//出发时间
@property (nonatomic,strong) NSString *startingDate;
//出发具体时间
@property (nonatomic,strong) NSString *startingTime;
//出发地点
@property (nonatomic,strong) NSString *startingName;
//目的地点
@property (nonatomic,strong) NSString *destinationName;
//车牌号
@property (nonatomic,strong) NSString *vehicleLicensePlate;
//车辆类型名称
@property (nonatomic,strong) NSString *vehicleTypeName;
//车辆等级名称
@property (nonatomic,strong) NSString *vehicleLevelName;
//车辆座位数
@property (nonatomic,assign) int vehicleSteats;
//乘坐人数
@property (nonatomic,assign) int peopleAmount;
//任务状态
@property (nonatomic,assign) int orderStatus;


//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
