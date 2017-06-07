//
//  Coupon.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "Coupon.h"

@implementation Coupon

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.couponId = dictionary[@"id"];
        self.passengerId = dictionary[@"passengerId"];
        self.total = [dictionary[@"total"] integerValue];
        self.orderId = dictionary[@"orderId"];
        self.name = dictionary[@"name"];
        self.state = [dictionary[@"state"] integerValue];
        self.expiry = [NSDate dateFromString:dictionary[@"expiry"]];
        self.limit = [dictionary[@"limit"] integerValue];
        self.orderType = [dictionary[@"orderType"] integerValue];
        self.deleted = [dictionary[@"deleted"] boolValue];
    }
    return self;
}
@end
