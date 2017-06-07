//
//  CarpoolOrderPrice.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolOrderPrice.h"

@implementation CarpoolOrderPrice

- (NSString *)virtualIdDescription{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.virtualId) {
        [dic setObject:self.virtualId forKey:@"virtualId"];
    }
    return [JsonUtils dictToJson:dic];
}

- (NSString *)description{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.virtualId) {
        [dic setObject:self.virtualId forKey:@"virtualId"];
    }
    if (self.peopleNumber) {
        [dic setObject:self.peopleNumber forKey:@"peopleNumber"];
    }
    
    if (self.childrenNumber) {
        [dic setObject:self.childrenNumber forKey:@"childrenNumber"];
    }

    if (self.bookingStartTime) {
        [dic setObject:self.bookingStartTime forKey:@"bookingStartTime"];
    }
    if (self.bookingEndTime) {
        [dic setObject:self.bookingEndTime forKey:@"bookingEndTime"];
    }

    if (self.type) {
        [dic setObject:self.type forKey:@"type"];
    }
    
    if (self.pathId) {
        [dic setObject:self.pathId forKey:@"pathId"];
    }
    if (self.trainId) {
        [dic setObject:self.trainId forKey:@"trainId"];
    }
    return [JsonUtils dictToJson:dic];
}

@end
