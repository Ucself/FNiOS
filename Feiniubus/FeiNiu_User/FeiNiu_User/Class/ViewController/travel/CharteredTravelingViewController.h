//
//  CharteredTravelingViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/31.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "CharterOrderPrice.h"
#import "CharterOrderItem.h"

@interface CharterOrderPrice (Date)
- (NSDate *)startDate;
- (NSDate *)endDate;
@end

@interface CharteredTravelingViewController : UserBaseUIViewController

@property (nonatomic, strong) CharterOrderPrice *order;     // monitor
@property (nonatomic, strong) NSString  *orderId;

@end
