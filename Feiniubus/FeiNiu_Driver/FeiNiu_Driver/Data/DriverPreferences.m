//
//  CarOwnerPreferences.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverPreferences.h"

@implementation DriverPreferences


+(DriverPreferences*)sharedInstance
{
    static DriverPreferences *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

//文件存储车辆地理位置信息
-(void)setDriverLocationUploadModel:(DriverLocationUploadModel*)data
{
    [self.preDict setValue:data forKey:@"DriverLocationUploadModel"];
    [self save];
}

-(DriverLocationUploadModel*)getDriverLocationUploadModel
{
    return [self.preDict objectForKey:@"DriverLocationUploadModel"];
}

@end
