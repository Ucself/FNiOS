//
//  CallCarStateViewController.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "ShuttleModel.h"

@interface CallCarStateViewController : UserBaseUIViewController
/**
 * @breif  接送机状态
 */
@property(nonatomic,assign) EmShuttleStatus controllerType;
/**
 * @breif 订单ID
 */
@property(nonatomic,copy) NSString *orderID;

//@property(nonatomic,copy) void (^callCarStateChange)();

@end
