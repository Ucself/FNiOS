//
//  FNLocation.m
//  FNMap
//
//  Created by 易达飞牛 on 15/8/14.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "FNLocation.h"
#import <objc/runtime.h>

@implementation FNLocation

- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@, cityCode:%@, adCode:%@, address:%@, coordinate:%f, %f", self.name, self.cityCode, self.adCode, self.address, self.coordinate.latitude, self.coordinate.longitude];
}


-(instancetype) initWithName:(NSString*)name longitude:(double)longitude latitude:(double)latitude
{
    self = [super init];
    if (self) {
        self.name = name;
        self.longitude = longitude;
        self.latitude = latitude;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.cityCode = [aDecoder decodeObjectForKey:@"cityCode"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.adCode = [aDecoder decodeObjectForKey:@"adCode"];
        self.latitude = [[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
        self.longitude = [[aDecoder decodeObjectForKey:@"longitude"] doubleValue];
        
        self.coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.cityCode forKey:@"cityCode"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.adCode forKey:@"adCode"];
    [coder encodeObject:@(self.coordinate.latitude) forKey:@"latitude"];
    [coder encodeObject:@(self.coordinate.longitude) forKey:@"longitude"];
}


- (id)copyWithZone:(NSZone *)zone
{
    id copyInstance = [[[self class] allocWithZone:zone] init];
    size_t instanceSize = class_getInstanceSize([self class]);
    memcpy((__bridge void *)(copyInstance), (__bridge const void *)(self), instanceSize);
    return copyInstance;
}

@end
