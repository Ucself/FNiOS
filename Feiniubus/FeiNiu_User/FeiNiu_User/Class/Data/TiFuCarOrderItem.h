//
//  TiFuCarOrderItem.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/1.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TiFuCarOrderItem : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) int action;
@property (nonatomic, strong) NSString *boarding;
@property (nonatomic, assign) float boardingLatitude;
@property (nonatomic, assign) float boardingLongitude;
@property (nonatomic, strong) NSString *destination;
@property (nonatomic, assign) float destinationLatitude;
@property (nonatomic, assign) float destinationLongitude;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) NSString *carpoolOrderId;
@property (nonatomic, assign) float mileage;
@property (nonatomic, strong) NSArray *route;
@property (nonatomic, strong) NSString *virtualId;
@property (nonatomic, assign) NSInteger amount;


@end
