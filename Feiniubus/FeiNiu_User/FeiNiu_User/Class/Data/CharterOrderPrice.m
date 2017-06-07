//
//  CharterOrderPrice.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterOrderPrice.h"
#import <FNCommon/JsonUtils.h>

@implementation CharterOrderPrice

- (NSString *)virtualIdDescription{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.virtualId) {
        [dic setObject:self.virtualId forKey:@"virtualId"];
    }
    return [JsonUtils dictToJson:dic];
}

- (NSString *)description{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.paths) {
        [dic setObject:self.paths forKey:@"paths"];
    }
    if (self.virtualId) {
        [dic setObject:self.virtualId forKey:@"virtualId"];
    }
    [dic setObject:@(self.type) forKey:@"type"];
    if (self.startTime) {
        [dic setObject:self.startTime forKey:@"startTime"];
    }
    if (self.endTime) {
        [dic setObject:self.endTime forKey:@"endTime"];
    }
    [dic setObject:@(self.mapSourceType) forKey:@"mapSourceType"];
    [dic setObject:@(self.miles) forKey:@"miles"];
    [dic setObject:@(self.passageFares) forKey:@"passageFares"];
    if (self.vehicleConfigs) {
        [dic setObject:self.vehicleConfigs forKey:@"vehicleConfigs"];
    }
    [dic setObject:@(self.isDriverFree) forKey:@"isDriverFree"];
    
    return [JsonUtils dictToJson:dic];
}
@end
