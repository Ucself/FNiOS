//
//  BaiDuCarWaitOrder.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/23.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@interface BaiDuCarWaitOrder : UserBaseUIViewController

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, assign) CGFloat userLatitude;
@property (nonatomic, assign) CGFloat userLongitude;
//@property (nonatomic, strong) NSString *userAddress;
@property (nonatomic, assign) int typeId;
@property (nonatomic, strong) NSString* carpoolOrderId;


//@property (nonatomic, strong) NSDictionary *orderOtherDic;

@end
