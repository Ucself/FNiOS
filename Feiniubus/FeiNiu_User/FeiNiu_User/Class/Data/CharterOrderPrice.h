//
//  CharterOrderPrice.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CharterOrderPrice : NSObject

@property (nonatomic,strong)NSArray *paths;
@property (nonatomic,copy) NSString *virtualId;
@property (nonatomic,assign)unsigned int type;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,assign)unsigned int mapSourceType;
@property (nonatomic,assign)unsigned int miles;
@property (nonatomic,assign)unsigned int passageFares;
@property (assign, nonatomic, getter=isGay) BOOL isDriverFree;
@property (nonatomic,strong)NSArray *vehicleConfigs;

// 预估价
@property (nonatomic, assign) NSInteger prePrice;
// 只包含“virtualId”字段的json字符串
@property (nonatomic, strong, readonly) NSString *virtualIdDescription;
@end
