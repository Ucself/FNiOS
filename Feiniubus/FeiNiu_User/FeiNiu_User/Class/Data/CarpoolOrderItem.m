//
//  CarpoolOrderItem.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolOrderItem.h"
#import "BusTicket.h"
@interface CarpoolOrderItem()
@property (nonatomic, assign) NSInteger             peopleTicketsNumber;
@property (nonatomic, assign) NSInteger             childrenTicketsNumber;
@end

@implementation CarpoolOrderItem
- (id)initWithDictionary:(NSDictionary *)dictionary{
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        self.orderId = dictionary[@"orderId"];
        self.orderStatus = [dictionary[@"orderStatus"] integerValue];
        self.payStatus = [dictionary[@"payState"] integerValue];
        self.price = [dictionary[@"price"] integerValue];
        
        if ([dictionary[@"startTime"] isKindOfClass:[NSString class]]) {
            
            self.startTime = dictionary[@"startTime"];
        }else{
            
            self.startTime = @"";
        }
        
        if ([dictionary[@"endTime"] isKindOfClass:[NSString class]]) {
            self.endTime = dictionary[@"endTime"];
        }else{
            self.endTime = @"";
        }
        
//        self.endTime = dictionary[@"endTime"];
        self.departure = [NSDate dateFromString:dictionary[@"departure"]];
        self.departureTime = dictionary[@"departureTime"];
        self.createTime = [NSDate dateFromString:dictionary[@"createTime"]];
        self.type = [dictionary[@"type"] integerValue];
        self.startName = dictionary[@"startingName"];
        self.destinationName = dictionary[@"destinationName"];
        self.station = dictionary[@"station"];
        self.peopleTicketsNumber = [dictionary[@"peopleTicketsNumber"] integerValue];
        self.childrenTicketsNumber = [dictionary[@"childrenTicketsNumber"] integerValue];
        self.comment = dictionary[@"comment"];
        
        self.refundTime = dictionary[@"refundTime"];
        self.refundPrice = [dictionary[@"refundPrice"] integerValue];
        self.cancelReason = dictionary[@"cancelReason"];
        self.telephone = dictionary[@"telephone"];
        
        NSArray *tickets = dictionary[@"tickets"];
        NSMutableArray  *temp = [NSMutableArray array];
        
        if ([dictionary[@"ferryOrder"] isKindOfClass:[NSDictionary class]]) {
            self.ferryOrder  = dictionary[@"ferryOrder"];
        }else{
            self.ferryOrder = @{};
        }
        
        
        
        
        for (NSDictionary *dic in tickets) {
            BusTicket *ticket = [[BusTicket alloc] initWithDictionary:dic];
            [temp addObject:ticket];
        }
        if (temp.count > 0) {
            self.tickets = [NSArray arrayWithArray:temp];
        }
    }
    return self;
}

- (NSInteger)adultsTicketsNumber{
    if (self.tickets) {
        NSInteger result = 0;
        for (BusTicket *ticket in self.tickets) {
            if (ticket.type == TicketTypeAdult) {
                result ++;
            }
        }
        return result;
    }
    return _peopleTicketsNumber;
}

- (NSInteger)childTicketsNumber{
    if (self.tickets) {
        NSInteger result = 0;
        for (BusTicket *tiket in self.tickets) {
            if (tiket.type == TicketTypeChild) {
                result ++;
            }
        }
        return result;
    }
    return _childrenTicketsNumber;
}

- (NSString *)startTime{
    if (!_startTime || ![_startTime isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *result = [self removeSecondPart:_startTime];
    if (result) {
        return result;
    }
    return _startTime;
}

- (NSString *)endTime{
    
    if (!_endTime || ![_endTime isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *result = [self removeSecondPart:_endTime];
    if (result) {
        return result;
    }
    return _endTime;
}
- (NSString *)departureTime{
    if (!_departureTime || ![_departureTime isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *result = [self removeSecondPart:_departureTime];
    if (result) {
        return result;
    }
    return _departureTime;
}
- (NSString *)removeSecondPart:(NSString *)str{
    NSDate *tempDate = [NSDate dateFromString:str format:@"HH:mm:ss"];
    return [tempDate timeStringByFormat:@"HH:mm"];
}
- (NSString *)startName{
    if (!_startName || ![_startName isKindOfClass:[NSString class]]) {
        return @"";
    }
    return _startName;
}
- (NSString *)destinationName{
    if (!_destinationName || ![_destinationName isKindOfClass:[NSString class]]) {
        return @"";
    }
    return _destinationName;
}
- (NSString *)refundTime{
    if (!_refundTime || ![_refundTime isKindOfClass:[NSString class]]) {
        return @"";
    }
    return _refundTime;
}
@end
