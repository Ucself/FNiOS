//
//  CarOwnerPreferences.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>

#define subOrderId      @"subOrderId"    //订单id  key 字符串
#define pushTime        @"pushTime"      //推送时间 字符串
#define isCheck         @"isCheck"       //是否查看 0 未查看 1已查看


@interface CarOwnerPreferences : EnvPreferences

+(CarOwnerPreferences*)sharedInstance;

//设置订单数据
-(void)setOrderIdInfo:(NSMutableArray*)orderArray;
//获得订单集合数据
-(NSMutableArray*)getOrderIdInfo;

@end
