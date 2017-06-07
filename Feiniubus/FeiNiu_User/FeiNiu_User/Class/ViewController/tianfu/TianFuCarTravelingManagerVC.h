//
//  TianFuCarTravelingManagerVC.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/9.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

//订单状态
typedef NS_ENUM(NSInteger, TianFuCarOrderStatus) {
    TianFuCarOrderStatusPrepare = 1,  // 待确认
    TianFuCarOrderStatusWaiting,      // 等待司机接送
    TianFuCarOrderStatusStart,    // 行程开始
    TianFuCarOrderStatusEnd,      // 行程完成
    TianFuCarOrderStatusCancel,       // 已取消
    TianFuCarOrderStatusFailure,       // 下单失败
};

#import "UserBaseUIViewController.h"

@interface TianFuCarTravelingManagerVC : UserBaseUIViewController

@property (nonatomic) TianFuCarOrderStatus status;

@end
