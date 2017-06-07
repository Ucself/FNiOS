//
//  VehicleConfig.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleConfig : NSObject
@property (nonatomic,strong)NSNumber *vehicleLevelId;
@property (nonatomic,strong)NSNumber *vehicleTypeId;
@property (nonatomic,assign)unsigned int seat;
@property (nonatomic,assign)unsigned int amount;
@property (nonatomic, strong) NSString *vehileTypeLevel;
@end
