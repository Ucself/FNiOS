//
//  FNLocation.m
//  FNMap
//
//  Created by 易达飞牛 on 15/8/14.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "FNLocation.h"

@implementation FNLocation

- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@, cityCode:%@, adCode:%@, address:%@, coordinate:%f, %f", self.name, self.cityCode, self.adCode, self.address, self.coordinate.latitude, self.coordinate.longitude];
}

@end
