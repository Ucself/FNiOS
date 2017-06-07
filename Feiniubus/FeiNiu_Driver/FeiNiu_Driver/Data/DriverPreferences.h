//
//  CarOwnerPreferences.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>
#import "DriverLocationUploadModel.h"

@interface DriverPreferences : EnvPreferences

+(DriverPreferences*)sharedInstance;

//文件存储车辆地理位置信息
-(void)setDriverLocationUploadModel:(DriverLocationUploadModel*)data;
-(DriverLocationUploadModel*)getDriverLocationUploadModel;

@end
