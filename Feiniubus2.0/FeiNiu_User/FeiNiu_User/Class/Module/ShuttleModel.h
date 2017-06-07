//
//  ShuttleModel.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/21.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DriverObj.h"

//订单状态
typedef NS_ENUM(int, EmShuttleStatus)
{
    EmShuttleStatus_WaitAssgin     = 2,//正在派车
    EmShuttleStatus_ReserveSuccess = 4,//预约成功
    EmShuttleStatus_Processing     = 5,//进行中
    EmShuttleStatus_Finished1      = 7,//已完成(未评价)
    EmShuttleStatus_Finished2      = 8,//已完成(已评价)
    EmShuttleStatus_WaitGetOn      = 9,//等待上车
    EmShuttleStatus_Cancelled      = 99,//已取消
};


//订单类型
typedef NS_ENUM(int, EmShuttleOrderType)
{
    EmShuttleOrderType_GotoAirport          = 1,//送机
    EmShuttleOrderType_FrombackAirport      = 2,//接机
    EmShuttleOrderType_GotoBusStation       = 4,//送汽车
    EmShuttleOrderType_FrombackBusStation   = 5,//接汽车
    EmShuttleOrderType_GotoTrainStation     = 6,//送火车
    EmShuttleOrderType_FrombackTrainStation = 7,//接火车
};


//支付状态
typedef NS_ENUM(int, EmShuttlePayStatus)
{
    EmShuttlePayStatus_Unallowed      = 1,//不允许支付
    EmShuttlePayStatus_WaitPay        = 2,//等待支付
    EmShuttlePayStatus_HasPay         = 3,//已付款
    EmShuttlePayStatus_Refunding      = 4,//退款中
    EmShuttlePayStatus_RefundFinished = 5,//已退款
};



//退款状态
typedef NS_ENUM(int, EmShuttleRefundStatus)
{
    EmShuttleRefundStatus_NoRefund      = 0,//无退款
    EmShuttleRefundStatus_ApplySuccess  = 1,//申请成功
    EmShuttleRefundStatus_FeiniuSuccess = 2,//飞牛处理成功
    EmShuttleRefundStatus_RefunSuccess  = 3,//退款成功
};

@interface ShuttleModel : NSObject

// Cell use
@property(nonatomic,copy)NSString *titleString;
@property(nonatomic,copy)NSString *endString;
@property(nonatomic,copy)NSString *titleImgString;

/**
 * @breif 起点地址名
 */
@property(nonatomic,retain)NSString *starAddressName;
/**
 * @breif 终点地址名
 */
@property(nonatomic,retain)NSString *endAddressName;
/**
 * @breif 电话
 */
@property(nonatomic,retain)NSString *phoneNumber;
/**
 * @breif 时间
 */
@property(nonatomic,retain)NSString *date;
/**
 * @breif 起点经纬度
 */
@property(nonatomic,assign)CLLocationCoordinate2D starAddress;
/**
 * @breif 终点经纬度
 */
@property(nonatomic,assign)CLLocationCoordinate2D endAddress;
/**
 * @breif 人数
 */
@property(nonatomic,retain)NSNumber *peopleNumber;
/**
 * @breif 距离(单位米)
 */
@property(nonatomic,retain)NSNumber *mileage;
/**
 * @breif 总价
 */
@property(nonatomic,retain)NSNumber *totalPrice;
/**
 * @breif 优惠卷ID
 */
@property(nonatomic,retain)NSString *couponID;
/**
 * @breif 优惠价格
 */
@property(nonatomic,assign)int coupon;
/**
 * @breif 是否立即预约--接送机
 */
@property(nonatomic,assign)int realTime;


//____________________________________HHTP-___________
/**
 * @breif HTTP订单ID
 */
@property(nonatomic,retain)NSNumber *orderId;
/**
 * @breif 订单状态 --等待派车2 预约排队3 预约成功4 接送中5 等待结算6 已完成7 预约失败98  已取消 99
 */
@property(nonatomic,retain)NSNumber *orderState;
/**
 * @breif 单个人价格
 */
@property(nonatomic,retain)NSNumber *unitPrice;

/**
 * @breif 起点坐标
 */
@property(nonatomic,assign)double sLatitude;
/**
 * @breif 起点坐标
 */
@property(nonatomic,assign)double sLongitude;
/**
 * @breif 终点坐标
 */
@property(nonatomic,assign)double dLatitude;
/**
 * @breif 终点坐标
 */
@property(nonatomic,assign)double dLongitude;

/**
 * @breif 订单状态
 */
@property(nonatomic,retain)NSNumber *paymentState;
/**
 * @breif 订单总价
 */
@property(nonatomic,retain)NSNumber *amount;
/**
 * @breif 订单创建时间
 */
@property(nonatomic,retain)NSString *createTime;
/**
 * @breif 是否提交取消原因
 */
@property(nonatomic,retain)NSNumber *isSubmitCancelReason;
/**
 * @breif 是否是及时呼车---callCar class使用
 */
@property(nonatomic,retain)NSNumber *isReal;
/**
 * @breif 司机数据
 */
@property(nonatomic,retain)DriverObj *driver;
/**
 * @breif 支付金额----  只有已支付订单才有
 */
@property(nonatomic,assign)int paymentAmount;
/**
 * @breif 优惠金额----已支付订单且使用了优惠券金额 否则0
 */
@property(nonatomic,assign)int couponsAmount;
/**
 * @breif 退款金额--
 */
@property(nonatomic,assign)int refundAmount;
/*
 *  可以退款金额
 */
@property(nonatomic, assign) int canRefundAmount;



//订单列表数据
@property (nonnull, strong) NSString *useDate;
@property (nonnull, strong) NSString *starting;
@property (nonnull, strong) NSString *destination;
@end
