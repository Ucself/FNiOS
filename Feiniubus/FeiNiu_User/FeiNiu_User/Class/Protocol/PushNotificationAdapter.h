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

typedef NS_ENUM(NSInteger, FNPushProccessType) {
    FNPushProccessType_CharterOrderCreate = 1,          // 包车订单生成
    FNPushProccessType_CharterOrderTimeout = 2,         // 包车订单超时
    FNPushProccessType_CharterOrderGrab = 5,            // 包车订单被抢中
    FNPushProccessType_CharterPayFeedback = 7,          // 包车支付反馈
    FNPushProccessType_CarpoolOrderCreate = 8,          // 拼车生成订单
    FNPushProccessType_CharterOrderPayTimeout = 9,      // 包车等待支付超时
    FNPushProccessType_CarpoolPayFeedback = 10,         // 拼车支付反馈
    FNPushProccessType_CharterOrderInvalid = 13,        // 包车订单时间等待过长，订单失效通知
    FNPushProccessType_CarpoolChildOrderCreate = 14,    // 拼车儿童票订单生成反馈
    FNPushProccessType_CarpoolStartTime = 15,           // 拼车发车时间地点通知
    FNPushProccessType_CarpoolTravelStart = 16,         // 拼车行程开始
    FNPushProccessType_CarpoolTravelEnd = 17,           // 拼车行程结束
    FNPushProccessType_CarpoolCallBaidu = 18,           // 呼叫摆渡车反馈
    FNPushProccessType_CarpoolInvalidForNoPaid = 19,    // 拼车长时间未付款取消订单通知
    FNPushProccessType_CarpoolCallBaiduSuccess = 20,    // 拼车呼叫摆渡车订单生成反馈通知
    FNPushProccessType_CharterForceToWaitingStart = 21, // 包车后台服务强制推送等待开始通知
    FNPushProccessType_CharterTravelStart = 22,         // 包车行程开始
    FNPushProccessType_CharterTravelEnd = 23,           // 包车司机任务结束
    FNPushProccessType_TianfuWaitBus = 24,              // 天府专车等待派车
};


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
