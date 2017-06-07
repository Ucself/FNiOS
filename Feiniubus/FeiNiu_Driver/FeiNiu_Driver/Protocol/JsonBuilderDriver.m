//
//  JsonBuilderDriver.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "JsonBuilderDriver.h"

@implementation JsonBuilderDriver
/**
 *  单例
 *
 *  @return 单例对象
 */
+(JsonBuilderDriver*)sharedInstance
{
    static JsonBuilderDriver *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
