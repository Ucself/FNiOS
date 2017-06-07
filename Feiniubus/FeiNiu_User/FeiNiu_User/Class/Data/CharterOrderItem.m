//
//  CharterOrderHistoryItem.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/2.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterOrderItem.h"
#import <objc/runtime.h>

@implementation CharterOrderItem
- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.orderId = dictionary[@"id"];
        self.creator = dictionary[@"creator"];
        self.createTime = [NSDate dateFromString:dictionary[@"createTime"]];
        self.orderAmount = [dictionary[@"orderAmount"] integerValue];
        self.startTime = [NSDate dateFromString:dictionary[@"startTime"]];
        self.returnTime = [NSDate dateFromString:dictionary[@"returnTime"]];
        self.kilometers = [dictionary[@"kilometers"] floatValue];
        self.type = [dictionary[@"type"] integerValue];
        self.status = [dictionary[@"status"] integerValue];
        self.startingName = dictionary[@"startingName"];
        self.destinationName = dictionary[@"destinationName"];
        self.grabAmount = [dictionary[@"grabAmount"] integerValue];
        
        NSMutableArray<CharterSuborderItem *> *temp = [NSMutableArray array];
        NSArray *suborders = dictionary[@"subOrder"];
        if (suborders && [suborders isKindOfClass:[NSArray class]]) {
            [suborders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CharterSuborderItem *suborderItem = [[CharterSuborderItem alloc]initWithDictionary:obj];
                [temp addObject:suborderItem];
            }];
            self.subOrder = [NSArray arrayWithArray:temp];
        }
        
    }
    return self;
}

//将对象属性封装到字典，并返回字典
-(NSDictionary *)propertyDictionary
{
    //创建字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for(int i=0;i<outCount;i++){
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc]initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        NSString *tempKey = propName;
        if ([propName isEqualToString:@"orderId"]) {
            tempKey = @"id";
        }
        id propValue = [self valueForKey:propName];
        if(propValue){
            [dict setObject:propValue forKey:tempKey];
        }
    }
    
    free(props);
    return dict;
}
@end

@implementation CharterSuborderItem

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.subOrderId = dictionary[@"subOrderId"];
        self.mainOrderId = dictionary[@"mainOrderId"];
        
        [self updateOrderInfo:dictionary];
    }
    return self;
}

- (void)updateOrderInfo:(NSDictionary *)dictionary{
    if (![self.subOrderId isEqualToString:dictionary[@"subOrderId"]] ||
        ![self.mainOrderId isEqualToString:dictionary[@"mainOrderId"]]) {
        return;
    }
    CharterBus *bus = [CharterBus new];
    bus.seat = [dictionary[@"seat"] integerValue];
    bus.vehicleLevel = [dictionary[@"vehicleLevelId"] integerValue];
    bus.vehicleType = [dictionary[@"vehicleTypeId"] integerValue];
    bus.typeName = dictionary[@"typeName"];
    bus.levelName = dictionary[@"levelName"];
    bus.licensePlate = dictionary[@"licensePlate"];
    self.bus = bus;
    
    self.quotation = [dictionary[@"quotation"] integerValue];
    self.realPay = [dictionary[@"realPay"] integerValue];
    self.grapTime = [NSDate dateFromString:dictionary[@"grabTime"]];
    self.payTime = [NSDate dateFromString:dictionary[@"payTime"]];
    self.orderState = [dictionary[@"orderState"] integerValue];
    self.payState = [dictionary[@"payState"] integerValue];
    self.creatorId = dictionary[@"creatorId"];
    self.createTime = [NSDate dateFromString:dictionary[@"createTime"]];
    self.startingTime = [NSDate dateFromString:dictionary[@"startingTime"]];
    self.returnTime = [NSDate dateFromString:dictionary[@"returnTime"]];
    self.kilometers = [dictionary[@"kilometers"] floatValue];
    self.toll = [dictionary[@"toll"] integerValue];
    
    CharterDriver *driver = [CharterDriver new];
    driver.driverId = dictionary[@"driverId"];
    driver.driverName = dictionary[@"driverName"];
    driver.driverPhone = dictionary[@"driverPhone"];
    driver.driverAvtar = [KServerAddr stringByAppendingFormat:@"Resources?url=%@", dictionary[@"driverAvatar"]];
    driver.driverScore = [dictionary[@"driverScore"] integerValue];
    self.driver = driver;
    
    self.starting = [[CharterPlace alloc] initWithDictionary:dictionary[@"starting"]];
    self.destination = [[CharterPlace alloc]initWithDictionary:dictionary[@"destination"]];
    self.grabAmount = [dictionary[@"grabAmount"] integerValue];
    self.price = [dictionary[@"price"] integerValue];
    
    NSMutableArray<CharterPlace *> *temp = [NSMutableArray array];
    NSArray *route = dictionary[@"route"];
    if (route && [route isKindOfClass:[NSArray class]]) {
        [route enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CharterPlace *place = [[CharterPlace alloc]initWithDictionary:obj];
            [temp addObject:place];
        }];
        self.route = [NSArray arrayWithArray:temp];
    }
    
    NSDictionary *photoDic = [JsonUtils jsonToDcit:dictionary[@"vehiclePhotos"]];
    if (photoDic) {
        photoDic = photoDic[@"vehiclePhoto"];
        NSMutableArray<NSString *> *photoTemp = [NSMutableArray array];
        if (photoDic[@"sideUrl"]) {
            [photoTemp addObject:[KServerAddr stringByAppendingFormat:@"Resources?url=%@", photoDic[@"sideUrl"]]];
        }
        if (photoDic[@"backUrl"]) {
            [photoTemp addObject:[KServerAddr stringByAppendingFormat:@"Resources?url=%@", photoDic[@"backUrl"]]];
        }
        if (photoDic[@"frontUrl"]) {
            [photoTemp addObject:[KServerAddr stringByAppendingFormat:@"Resources?url=%@", photoDic[@"frontUrl"]]];
        }
        self.photos = [NSArray arrayWithArray:photoTemp];
    }
    self.waitStartTime = [NSDate dateFromString:dictionary[@"waiteStartTime"]];
    
    self.refundCategory = [dictionary[@"refundCategory"] integerValue];
    self.refundTotal = [dictionary[@"refundTotal"] integerValue];
    self.refundTime = [NSDate dateFromString:dictionary[@"refundTime"]];
    self.refundDesc = dictionary[@"refundDescription"];
}

- (void)setRefundDesc:(NSString *)refundDesc{
    if (!refundDesc || ![refundDesc isKindOfClass:[NSString class]] ) {
        refundDesc = @"无";
    }
    _refundDesc = refundDesc;
}
@end

@implementation CharterBus

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@%@ 准坐%@人", self.typeName, self.levelName, @(self.seat)];
}
- (NSString *)typeName{
    if (!_typeName || [_typeName isKindOfClass:[NSNull class]]) {
        return @"不限";
    }
    return _typeName;

}

- (NSString *)levelName{
    if (!_levelName || [_levelName isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return _levelName;
}
@end

@implementation CharterPlace

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.name = dictionary[@"detailAddress"];
        self.coordinate = dictionary[@"detailLocation"];
        self.sequence = [dictionary[@"pathSequence"] integerValue];
    }
    return self;
}

@end

@implementation CharterDriver



@end
