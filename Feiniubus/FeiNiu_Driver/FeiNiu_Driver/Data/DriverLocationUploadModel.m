//
//  DriverLocationUploadModel.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/10/13.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "DriverLocationUploadModel.h"

@interface DriverLocationUploadModel ()<NSCopying>

@end

@implementation DriverLocationUploadModel

- (id)copyWithZone:(NSZone *)zone
{
    DriverLocationUploadModel *result = [[[self class] allocWithZone:zone] init];
    
    result->_uploadState = self->_uploadState;
    result->_taskType = [self->_taskType copy];
    result->_orderId = [self->_orderId copy];
    result->_licensePlate = [self->_licensePlate copy];
    result->_locationsArray = [self->_locationsArray copy];
    
    return result;
}

//对象序列化方法
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[[NSNumber alloc] initWithInt:self.uploadState] forKey:@"uploadState"];
    [aCoder encodeObject:self.taskType forKey:@"taskType"];
    [aCoder encodeObject:self.orderId forKey:@"orderId"];
    [aCoder encodeObject:self.licensePlate forKey:@"licensePlate"];
    [aCoder encodeObject:self.locationsArray forKey:@"locationsArray"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.uploadState = [[aDecoder decodeObjectForKey:@"uploadState"] intValue];
        self.taskType = [aDecoder decodeObjectForKey:@"taskType"];
        self.orderId = [aDecoder decodeObjectForKey:@"orderId"];
        self.licensePlate = [aDecoder decodeObjectForKey:@"licensePlate"];
        self.locationsArray = [aDecoder decodeObjectForKey:@"locationsArray"];
    }
    return  self;
}

@end


@implementation locationArrayModel

//对象序列化方法
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[[NSNumber alloc] initWithInt:self.speed] forKey:@"speed"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.time forKey:@"time"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.speed = [[aDecoder decodeObjectForKey:@"speed"] intValue];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
    }
    return  self;
}

@end