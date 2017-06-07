//
//  CharterOrderHistoryItem.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/2.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

@class CharterBus;
@class CharterPlace;
@class CharterDriver;
@class CharterSuborderItem;

typedef NS_ENUM(NSInteger, CharterOrderStatus) {
    CharterOrderStatusPrepare = 1,      // 待抢单
    CharterOrderStatusDriverGot,        // 已抢单
    CharterOrderStatusWaiting,          // 等待开始
    CharterOrderStatusTravelling,       // 行程中
    CharterOrderStatusTravelEnd,        // 行程完成
    CharterOrderStatusSuspend,          // 中止, 继续等待
    CharterOrderStatusCancel,           // 已取消
};

typedef NS_ENUM(NSInteger, CharterOrderPayStatus) {
    CharterOrderPayStatusNON = 1,       // 未开发支付
    CharterOrderPayStatusPrepareForPay, // 待支付
    CharterOrderPayStatusEarnestPay,    // 定金支付
    CharterOrderPayStatusPaidInFull,    // 全款支付
    CharterOrderPayStatusPaying,        // 支付中（对公转账）
    CharterOrderPayStatusApplyForRefund,// 退款申请
    CharterOrderPayStatusRefunding,     // 退款中
    CharterOrderPayStatusRefundReject,  // 退款申请驳回
    CharterOrderPayStatusRefundDone,    // 退款完成
    CharterOrderPayStatusRefundFail,    // 退款失败
    CharterOrderPayStatusEarnestPayFail,// 定金支付失败
    CharterOrderPayStatusPaidInFullFail,// 全款支付失败
};
@interface CharterOrderItem : BaseModel
@property (nonatomic, strong) NSString  *orderId;           // 订单号
@property (nonatomic, strong) NSString  *creator;           // 创建者userId
@property (nonatomic, assign) NSInteger  orderAmount;       // 金额
@property (nonatomic, strong) NSDate    *createTime;        // 创建时间
@property (nonatomic, strong) NSDate    *startTime;         // 开始时间
@property (nonatomic, strong) NSDate    *returnTime;        // 返回时间
@property (nonatomic, assign) CGFloat   kilometers;         // 总里程
@property (nonatomic, assign) NSInteger type;               // 类型
@property (nonatomic, assign) NSInteger status;             // 订单状态
@property (nonatomic, strong) NSString  *startingName;      // 起始地名称
@property (nonatomic, strong) NSString  *destinationName;   // 目的地名称
@property (nonatomic, assign) NSInteger grabAmount;         // 优惠金额
@property (nonatomic, strong) NSArray<CharterSuborderItem *>   *subOrder;          // 子订单
@end


// 子订单
@interface CharterSuborderItem : BaseModel
@property (nonatomic, strong) NSString  *subOrderId;        // 订单号
@property (nonatomic, strong) NSString  *mainOrderId;       // 主订单号
@property (nonatomic, strong) CharterBus *bus;
@property (nonatomic, assign) NSInteger quotation;          // 报价
@property (nonatomic, assign) NSInteger realPay;
@property (nonatomic, strong) NSDate    *grapTime;
@property (nonatomic, strong) NSDate    *payTime;
@property (nonatomic, assign) CharterOrderStatus    orderState; // 订单状态
@property (nonatomic, assign) CharterOrderPayStatus payState;   // 订单支付状态
@property (nonatomic, strong) NSString  *creatorId;         // 创建者id
@property (nonatomic, strong) NSDate    *createTime;
@property (nonatomic, strong) NSDate    *startingTime;
@property (nonatomic, strong) NSDate    *returnTime;
@property (nonatomic, assign) CGFloat   kilometers;
@property (nonatomic, assign) NSInteger toll;
@property (nonatomic, strong) CharterDriver *driver;
@property (nonatomic, strong) CharterPlace *starting;
@property (nonatomic, strong) CharterPlace *destination;
@property (nonatomic, strong) NSArray<CharterPlace *> *route;
@property (nonatomic, assign) NSInteger grabAmount;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, strong) NSDate    *waitStartTime;
@property (nonatomic, strong) NSArray<NSString *> *photos;

@property (nonatomic, assign) NSInteger refundCategory;
@property (nonatomic, assign) NSInteger refundTotal;
@property (nonatomic, strong) NSDate    *refundTime;
@property (nonatomic, strong) NSString *refundDesc;
- (void)updateOrderInfo:(NSDictionary *)info;
@end

@interface CharterBus : BaseModel
@property (nonatomic, assign) NSInteger seat;           // 座位数量
@property (nonatomic, assign) NSInteger vehicleLevel;   // 车辆等级
@property (nonatomic, assign) NSInteger vehicleType;    // 车辆类型
@property (nonatomic, assign) NSInteger amount;         // 所需数量
@property (nonatomic, strong) NSArray<NSString *> *photos;  // 图片
@property (nonatomic, assign) NSInteger score;          // 评分
@property (nonatomic, strong) NSString  *typeName;
@property (nonatomic, strong) NSString  *levelName;
@property (nonatomic, strong) NSString  *licensePlate;  // 车牌号

@end

@interface CharterPlace : BaseModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *coordinate;
@property (nonatomic, assign) NSInteger sequence;
@end

@interface CharterDriver : BaseModel
@property (nonatomic, strong) NSString *driverId;
@property (nonatomic, strong) NSString *driverName;
@property (nonatomic, strong) NSString *driverAvtar;
@property (nonatomic, strong) NSString *driverPhone;
@property (nonatomic, assign) NSInteger driverScore;
@end
