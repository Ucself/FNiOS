//
//  DriverLocationUploadModel.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/10/13.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverLocationUploadModel : NSObject

//上传状态 0 表示未执行上传任务 1 表示正在执行位置上传任务
@property(nonatomic,assign) int uploadState;

//任务类型，包车，拼车
@property(nonatomic,strong) NSString *taskType;

//订单id
@property(nonatomic,strong) NSString *orderId;

//执行任务的车牌号
@property(nonatomic,strong) NSString *licensePlate;

//任务的坐标位置
@property(nonatomic,strong) NSMutableArray *locationsArray;

@end

@interface locationArrayModel : NSObject

//坐标位置
@property(nonatomic,strong) NSString *location;

//获取坐标的时间
@property(nonatomic,strong) NSString *time;

//当前车速
@property(nonatomic,assign) int speed;

@end