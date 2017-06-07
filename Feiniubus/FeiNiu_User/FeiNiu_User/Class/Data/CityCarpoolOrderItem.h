//
//  CityCarpoolOrderItem.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/29.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

//订单状态
typedef NS_ENUM(NSInteger, CityCarpoolOrderStatus) {
    CityCarpoolOrderStatusPrepare = 1,  // 待确认
    CityCarpoolOrderStatusWaiting = 2,      // 等待司机接送
    CityCarpoolOrderStatusStart,    // 行程开始
    CityCarpoolOrderStatusEnd,      // 行程完成
    CityCarpoolOrderStatusCancel = 5,       // 已取消
    CityCarpoolOrderStatusFailure,       // 下单失败
};


//支付状态
typedef NS_ENUM(NSInteger, CityCarpoolOrderPayStatus) {
    CityCarpoolOrderPayStatusNON = 1,       // 未开放支付
    CityCarpoolOrderPayStatusPrepareForPay, // 待支付
    CCityCarpoolOrderPayStatusPaid,          // 已支付
    CityCarpoolOrderPayStatusFreeCharge,    // 免单
    
};

typedef NS_ENUM(NSInteger, CityCarpoolType) {
    CityCarpoolTypeGundong = 1,
    CityCarpoolTypeDingdian,
};


@interface CityCarpoolOrderItem : BaseModel


@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, assign) CityCarpoolOrderStatus    orderStatus;
@property (nonatomic, assign) CityCarpoolOrderPayStatus payStatus;
@property (nonatomic, strong) NSString              *creator;
@property (nonatomic, assign) NSInteger             number;
@property (nonatomic, strong) NSDate                *createTime;
@property (nonatomic, assign) CityCarpoolType       type;
@property (nonatomic, strong) NSString              *destinationName;
@property (nonatomic, strong) NSString              *destinationAddress;
@property (nonatomic, strong) NSString              *boardAddress;
@property (nonatomic, assign) NSInteger             price;


@end
