//
//  DriverInfo.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/26.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "DriverInfo.h"

@implementation DriverInfo

+ (instancetype)sharedInstance{
    
    static DriverInfo *driverInfo;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        driverInfo = [[DriverInfo alloc] init];
    });
    
    return driverInfo;
}

@end
