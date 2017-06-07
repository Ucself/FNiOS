//
//  TFCarOrderDetailModel.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TFCarOrderDetailModel.h"

@implementation TFCarOrderDetailModel

+ (instancetype)sharedInstance{
    
    static TFCarOrderDetailModel *model = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        model = [[TFCarOrderDetailModel alloc] init];
    });
    
    return model;
}


- (id)initWithDictionary:(NSDictionary*)_dic{
    if (self = [super init]) {
        if (_dic[@"carpoolOrderId"]) {
            self.carpoolOrderId = [_dic[@"carpoolOrderId"] integerValue];
        }
        self.boardingLatitude = [_dic[@"boardingLatitude"] doubleValue];
        self.boardingLongitude = [_dic[@"boardingLongitude"] doubleValue];
        self.destinationLatitude = [_dic[@"destinationLatitude"] doubleValue];
        self.destinationLongitude = [_dic[@"destinationLongitude"] doubleValue];
        self.taskId = [_dic[@"taskId"] integerValue];
        self.driverAvatar = _dic[@"driverAvatar"];
        self.driverName = _dic[@"driverName"];
        self.driverPhone = _dic[@"driverPhone"];
        self.license = _dic[@"license"];
        self.busId = [_dic[@"busId"] integerValue];
        self.orderId = _dic[@"orderId"];
        self.creator = _dic[@"creator"];
        self.createTime = _dic[@"createTime"];
        self.number = [_dic[@"number"] intValue];
        self.type = [_dic[@"type"] intValue];
        self.boardAddress = _dic[@"boardAddress"];
        self.state = [_dic[@"state"] intValue];
        self.payState = [_dic[@"payState"] intValue];
        self.price = _dic[@"price"];
        self.driverScore = [_dic[@"driverScore"] floatValue];
        self.driverOrderNum = [_dic[@"driverOrderNum"] intValue];

    }
    return self;
}


@end
