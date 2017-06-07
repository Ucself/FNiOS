//
//  CarOwnerInforModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerInforModel.h"

@implementation CarOwnerInforModel


//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSDictionary class]] || !dictionary) {
            //直接返回空
            return self;
        }
        self.totalAmount = [dictionary objectForKey:@"income"] ? [[dictionary objectForKey:@"income"] floatValue] : 0.f;
        self.vehicleAmount = [dictionary objectForKey:@"vehicleAmount"] ? [dictionary objectForKey:@"vehicleAmount"] : @"0";
        self.driverAmount = [dictionary objectForKey:@"driverAmount"] ? [dictionary objectForKey:@"driverAmount"] : @"0";
        self.orderAmount = [dictionary objectForKey:@"orderAmount"] ? [dictionary objectForKey:@"orderAmount"] : @"0";
        self.mileage = [dictionary objectForKey:@"mileage"] ? [dictionary objectForKey:@"mileage"] : @"0";
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
