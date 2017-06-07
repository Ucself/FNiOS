//
//  JsonBuilderDriver.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <FNNetInterface/FNNetInterface.h>

@interface JsonBuilderDriver : JsonBaseBuilder

/**
 *  单例
 *
 *  @return 单例对象
 */
+(JsonBuilderDriver*)sharedInstance;
#pragma mark ---

@end
