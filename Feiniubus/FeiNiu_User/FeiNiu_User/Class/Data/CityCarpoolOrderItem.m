//
//  CityCarpoolOrderItem.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/29.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CityCarpoolOrderItem.h"

@implementation CityCarpoolOrderItem

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.orderId = dictionary[@"orderId"];
        self.orderStatus = [dictionary[@"state"] integerValue];
        self.payStatus = [dictionary[@"payState"] integerValue];
        self.price = [dictionary[@"price"] integerValue];
        self.createTime = [NSDate dateFromString:dictionary[@"createTime"]];
        self.type = [dictionary[@"type"] integerValue];
        self.destinationName = dictionary[@"destinationName"];
        self.boardAddress = dictionary[@"boardAddress"];
        self.number = [dictionary[@"number"] integerValue];
        self.destinationAddress = dictionary[@"destinationAddress"];
    }
    return self;
}



@end
