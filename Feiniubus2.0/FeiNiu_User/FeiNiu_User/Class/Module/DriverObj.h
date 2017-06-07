//
//  DriverObj.h
//  FeiNiu_User
//
//  Created by CYJ on 16/4/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverObj : NSObject

/**
 * @breif 车牌
 */
@property(nonatomic,retain)NSString *licence;
/**
 * @breif 头像
 */
@property(nonatomic,retain)NSString *avatar;
/**
 * @breif 名字
 */
@property(nonatomic,retain)NSString *name;
/**
 * @breif 电话
 */
@property(nonatomic,retain)NSString *phone;
/**
 * @breif 司机评分
 */
@property(nonatomic,assign)int score;
/**
 * @breif 车ID
 */
@property(nonatomic,retain)NSString *bus_id;

//司机id
@property(nonatomic,retain)NSString *driver_id;
//车辆归属类型（1-自有车辆，2-合作公司）
@property(nonatomic,retain)NSString *bus_type;
//车辆座位数
@property(nonatomic,assign)int *seats;

@end
