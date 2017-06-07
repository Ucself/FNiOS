//
//  CarpoolOrderItem.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

@class BusTicket;

typedef NS_ENUM(NSInteger, CarpoolOrderStatus) {
    CarpoolOrderStatusPrepare = 1,  // 待处理
    CarpoolOrderStatusWaitingForBus,// 等待派车
    CarpoolOrderStatusReserveSuccess,   // 预约成功
    CarpoolOrderStatusTravelling,   // 行程中
    CarpoolOrderStatusTravelEnd,    // 行程已完成
    CarpoolOrderStatusReserveFail,  // 预约失败
    CarpoolOrderStatusCancel,       // 已取消
};

typedef NS_ENUM(NSInteger, CarpoolOrderPayStatus) {
    CarpoolOrderPayStatusNON = 1,       // 未开发支付
    CarpoolOrderPayStatusPrepareForPay, // 待支付
    CarpoolOrderPayStatusPaid,          // 已支付
    CarpoolOrderPayStatusApplyForRefund,// 退款申请
    CarpoolOrderPayStatusRefunding,     // 退款中
    CarpoolOrderPayStatusRefundReject,  // 退款申请驳回
    CarpoolOrderPayStatusRefundDone,    // 退款完成
    CarpoolOrderPayStatusRefundFail,    // 退款失败
    CarpoolOrderPayStatusPaidFail,      // 支付失败

};

typedef NS_ENUM(NSInteger, CarpoolBusType) {
    CarpoolBusTypeGundong = 1,
    CarpoolBusTypeDingdian,
    CarpoolBusTypeGundong2,
};

@interface CarpoolOrderItem : BaseModel
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, assign) CarpoolOrderStatus    orderStatus;
@property (nonatomic, assign) CarpoolOrderPayStatus payStatus;
@property (nonatomic, assign) NSInteger             price;
@property (nonatomic, strong) NSString              *startTime;
@property (nonatomic, strong) NSString              *endTime;
@property (nonatomic, strong) NSDate                *departure;
@property (nonatomic, strong) NSString              *departureTime;
@property (nonatomic, strong) NSDate                *createTime;
@property (nonatomic, assign) CarpoolBusType        type;
@property (nonatomic, strong) NSString              *startName;
@property (nonatomic, strong) NSString              *destinationName;
@property (nonatomic, strong) NSString              *station;
@property (nonatomic, strong) NSString              *telephone;

//
@property (nonatomic, strong) NSString              *refundTime;
@property (nonatomic, assign) NSInteger             refundPrice; // 分
@property (nonatomic, strong) NSString              *cancelReason;

//
@property (nonatomic, assign, readonly) NSInteger   adultsTicketsNumber;
@property (nonatomic, assign, readonly) NSInteger   childTicketsNumber;
//@property (nonatomic, assign, readonly) NSInteger   freeTicketsNumber;
//
@property (nonatomic, strong) NSString              *comment;
@property (nonatomic, strong) NSArray<BusTicket *>  *tickets;
@property (nonatomic, strong) NSDictionary          *ferryOrder;

@end
