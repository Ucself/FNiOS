//
//  OrderReview.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "OrderReview.h"

@implementation OrderReview

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.orderId = dictionary[@"orderId"];
        self.isAppraiseDriver = [dictionary[@"isAppraiseDriver"] boolValue];
        self.isAppraiseVehicle = [dictionary[@"isAppraiseVehicle"] boolValue];
        self.driverScores = [dictionary[@"driverScores"] floatValue];
        self.vehicleScores = [dictionary[@"vehicleScores"] floatValue];

        NSArray<NSDictionary *> *appraises = dictionary[@"vehicleAppraises"];
        NSMutableArray<ReviewItem *> *temp = [NSMutableArray array];
        
        [appraises enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ReviewItem *item = [[ReviewItem alloc]initWithDictionary:obj];
            if (item) {
                [temp addObject:item];
            }
        }];
        self.vehicleAppraises = [NSArray arrayWithArray:temp];
        
        appraises = dictionary[@"driverAppraises"];
        temp = [NSMutableArray array];
        [appraises enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ReviewItem *item = [[ReviewItem alloc]initWithDictionary:obj];
            if (item) {
                [temp addObject:item];
            }
        }];
        self.driverAppraises = [NSArray arrayWithArray:temp];
        
        NSDictionary *photos  = dictionary[@"vehiclePhotos"];
        if (photos && photos[@"vehiclePhoto"]) {
            NSDictionary *tempDic = photos[@"vehiclePhoto"];
            NSMutableArray *vechiclePhotos = [NSMutableArray array];
            if (tempDic[@"frontUrl"]) {
                NSString *url = [KServerAddr stringByAppendingFormat:@"Resources?url=%@", tempDic[@"frontUrl"]];
                [vechiclePhotos addObject:url];
            }
            if (tempDic[@"sideUrl"]) {
                NSString *url = [KServerAddr stringByAppendingFormat:@"Resources?url=%@", tempDic[@"sideUrl"]];
                [vechiclePhotos addObject:url];
            }
            if (tempDic[@"backUrl"]) {
                NSString *url = [KServerAddr stringByAppendingFormat:@"Resources?url=%@", tempDic[@"backUrl"]];
                [vechiclePhotos addObject:url];
            }
            self.vehiclePhotos = [NSArray arrayWithArray:vechiclePhotos];
        }
        
    }
    return self;
}
@end


@implementation ReviewItem

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.appraiseTime = [NSDate dateFromString:dictionary[@"appraiseTime"]];
        self.appraiseLevel = [dictionary[@"appraiseLevel"] integerValue];
        self.content = dictionary[@"content"];
        self.reviewId = dictionary[@"id"];
    }
    return self;
}

@end