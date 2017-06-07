//
//  DriverCarpoolOrdeMember.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/10/8.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "DriverCarpoolOrdeMember.h"

@implementation DriverCarpoolOrdeMember

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSDictionary class]] || !dictionary) {
            return self;
        }
        self.memberId = [dictionary objectForKey:@"memberId"] ? [dictionary objectForKey:@"memberId"] : @"";
        self.memberName = [dictionary objectForKey:@"memberName"] ? [dictionary objectForKey:@"memberName"] : @"";
        self.memberPhone = [dictionary objectForKey:@"memberPhone"] ? [dictionary objectForKey:@"memberPhone"] : @"";
        self.orderId = [dictionary objectForKey:@"orderId"] ? [dictionary objectForKey:@"orderId"] : @"";
        self.ticketsAmount = [dictionary objectForKey:@"ticketsAmount"] ? [[dictionary objectForKey:@"ticketsAmount"] intValue] : 0;
        self.checkedicketsAmount = [dictionary objectForKey:@"checkedTicketsAmount"] ? [[dictionary objectForKey:@"checkedTicketsAmount"] intValue] : 0;
        self.ticketsStatus = [dictionary objectForKey:@"ticketsStatus"] ? [[dictionary objectForKey:@"ticketsStatus"] intValue] : 1;
        self.memberAvatar = [dictionary objectForKey:@"memberAvatar"] ? [dictionary objectForKey:@"memberAvatar"] : @"";
    }
    
    return self;
    
}


@end
