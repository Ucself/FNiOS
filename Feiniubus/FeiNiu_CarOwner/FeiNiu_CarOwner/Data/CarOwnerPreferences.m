//
//  CarOwnerPreferences.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerPreferences.h"

@implementation CarOwnerPreferences


+(CarOwnerPreferences*)sharedInstance
{
    static CarOwnerPreferences *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

//设置订单数据
-(void)setOrderIdInfo:(NSMutableArray*)orderArray{
    [self.preDict  setValue:orderArray forKey:@"orderIdInfo"];
    [self save];
}
//获得订单集合数据
-(NSMutableArray*)getOrderIdInfo{
    return [self.preDict objectForKey:@"orderIdInfo"];
}

@end
