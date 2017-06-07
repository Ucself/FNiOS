//
//  CarOwnerDriverModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/7.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverModel.h"

@implementation DriverModel

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSDictionary class]] || !dictionary) {
            return self;
        }
        self.driverId = [dictionary objectForKey:@"id"] ? [dictionary objectForKey:@"id"] : @"";
        self.driverHead = [dictionary objectForKey:@"avatar"] ? [dictionary objectForKey:@"avatar"] : @"";
        self.driverName = [dictionary objectForKey:@"name"] ? [dictionary objectForKey:@"name"] : @"";
        self.driverPhone = [dictionary objectForKey:@"phone"] ? [dictionary objectForKey:@"phone"] : @"";
        self.driverRating = [dictionary objectForKey:@"rating"] ? [[dictionary objectForKey:@"rating"] floatValue] :0.0f;
        self.driverMileage = [dictionary objectForKey:@"mileage"] ? [[dictionary objectForKey:@"mileage"] floatValue] : 0.0f;
        self.driverAudit = [dictionary objectForKey:@"audit"] ? [[dictionary objectForKey:@"audit"] intValue] : 0;
        self.birthday = [dictionary objectForKey:@"birthday"] ? [dictionary objectForKey:@"birthday"] : @"";
        self.createTime = [dictionary objectForKey:@"createTime"] ? [dictionary objectForKey:@"createTime"] : @"";
    }
    
    return self;
    
}

@end
