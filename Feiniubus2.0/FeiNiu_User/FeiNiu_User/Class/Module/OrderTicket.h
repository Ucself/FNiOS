//
//  OrderTicket.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/23.
//  Copyright © 2016年 tianbo. All rights reserved.
//
// 车票订单详情

#import <FNDataModule/FNDataModule.h>

typedef NS_ENUM(int, OrderTicketType)
{
    EmOrderTicketType_FixTime = 2,    //定时班车
    EmOrderTicketType_Rolling = 3,    //滚动班车
};

typedef NS_ENUM(int, OrderTicketStatus)
{
    EmOrderTicketStatus_WaitPay        = 3,
    EmOrderTicketStatus_Finished       = 5,
    EmOrderTicketStatus_Cancelled      = 7,
    EmOrderTicketStatus_Refunding      = 8,
    EmOrderTicketStatus_RefundFinished = 9,
};

@interface OrderTicket : BaseModel

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *date;              //车票日期
@property (nonatomic, strong) NSString *endCity;
@property (nonatomic, strong) NSString *endSite;
@property (nonatomic, assign) int       orderState;        //3:等待付款   5:完成   7:取消
@property (nonatomic, assign) int       peopleNumber;      //人数
@property (nonatomic, strong) NSString *startCity;
@property (nonatomic, strong) NSString *startSite;
@property (nonatomic, strong) NSString *time;              //(定时班)出发时间 /滚动班有效时间
@property (nonatomic, assign) float     totalAmount;       //总金额
@property (nonatomic, assign) float     amount;            //实际支付总额（若订单已经支付
@property (nonatomic, assign) int       type;              //3:滚动班 2:定时班

@property (nonatomic, strong) NSString *contactPhone;     //取票人电话
@property (nonatomic, strong) NSString *payTime;          //支付时间
@property (nonatomic, assign) float     ticketPrice;      //单张票价格
@end
