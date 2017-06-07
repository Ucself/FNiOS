//
//  PushConfiguration.h
//  FNNetInterface
//
//  Created by 易达飞牛 on 15/9/16.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//别名后缀
#define PassengerAlias       @"1"                 //旅客会员 Passenger
#define DriverAlias          @"2"                 //司机 Driver
#define BossAlias            @"3"                 //车主老板 Boss
#define ManagerAlias         @"Manager"           //管理员
#define AdministratorAlias   @"Administrator"     //超级管理员


//分组名称
#define feiniuBusPassengerTag          @"feiniuBusPassenger"           //旅客
#define feiniuBusOwenersTag            @"feiniuBusOweners"             //车主
#define feiniuBusDrvierTag             @"feiniuBusDrvier"              //司机
#define feiniuBusCarferryTag           @"feiniuBusCarferry"           //摆渡车


@interface PushConfiguration : NSObject
//实例化
+ (PushConfiguration*)sharedInstance;
/**
 *  设置标签
 *
 *  @param tag
 */
-(void)setTag:(NSString*)tag;
/**
 *  设置别名
 *
 *  @param alias
 *  @param userId
 */
-(void)setAlias:(NSString*)alias userId:(NSString*)userId;
-(void)setAlias:(NSString*)alias userAlias:(NSString*)userAlias;
/**
 *  设置标签和别名 此方法正常
 *
 *  @param tag
 *  @param alias
 *  @param userId
 */
-(void)setTagAndAlias:(NSString*)tag alias:(NSString*)alias userId:(NSString*)userId;
/**
 *  清除标签
 */
-(void)resetTag;
/**
 *  清除别名
 */
-(void)resetAlias;
/**
 *  清除标签和别名
 */
-(void)resetTagAndAlias;
/**
 *  获取激光注册的设备注册id
 */
-(NSString*)getRegistrationID;

//设置
- (BOOL)setBadge:(NSInteger)value;

@end
