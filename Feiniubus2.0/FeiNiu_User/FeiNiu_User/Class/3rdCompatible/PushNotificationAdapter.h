//
//  PushNotificationAdapter.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>


OBJC_EXTERN NSString *kNotification_APNS;

OBJC_EXTERN NSString *kProccessType;

OBJC_EXTERN NSString *kAPNSItemDate;
OBJC_EXTERN NSString *kAPNSItemMessage;
OBJC_EXTERN NSString *kAPNSItemIsRead;


//typedef NS_ENUM(NSInteger, FNPushProccessType) {
//    FNPushProccessType_BusTicketsGenerateOrder = 63,          // 客车订票生成订单
//    FNPushProccessType_CallCarGenerateOrder = 60,             // 接送机生成订单
//};


//推送类型
#define FNPushType_CallCarGenerateOrder         @"60"    //接送机生成订单
#define FnPushType_CallCarPayCharge             @"61"    //接送机获取支付凭证
#define FnPushType_CallCarPaySuccess            @"62"    //接送机支付成功
#define FnPushType_CallCarRefundApply           @"67"    //接送机退款申请
#define FnPushType_CallCarRefundSuccess         @"69"    //接送机退款成功

#define FnPushType_BeginSendCar                 @"70"    //接送机派单
#define FnPushType_BeginTheRoad                 @"71"    //接送机行程开始
#define FnPushType_EndCallCar                   @"72"    //接送机行程结束

#define FNPushType_BusTicketsGenerateOrder      @"63"    //客车订票生成订单
#define FNPushType_BusTicketsPayCharge          @"64"    //客车订票获取支付凭证
#define FNPushType_BusTicketsSuccess            @"65"    //客车订票支付成功
#define FNPushType_BusTicketsRefundApply        @"66"    //客车订票退款申请
#define FNPushType_BusTicketsRefundSuccess     @"68"    //客车订票退款成功


//接送bus推送
#define FNPushType_ShttleWaiting             @"31001"
#define FNPushType_ShttleOngoing             @"31002"
#define FNPushType_ShttleArrived             @"31003"



@interface PushNotificationAdapter : NSObject
+ (NSString *)apnsListFilePath;


+ (void)addAPNSMessage:(NSDictionary *)message;

// 将所有的消息设置为已读
+ (void)readAll;

// 是否有未读消息（新消息）
+ (BOOL)hasNewMessage;
+ (NSArray *)getAPNSList;
+ (void)clearAPNSList;
@end
