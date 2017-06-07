//
//  PingPPayUtil.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Pingpp.h"

typedef NS_ENUM(NSInteger, FNUserPayOrderType) {
    FNUserPayOrderType_CharterOrder = 1,
    FNUserPayOrderType_CarpoolOrder,
    FNUserPayOrderType_TianfuCarOrder,
};

OBJC_EXTERN NSString * _Nonnull FNPayResultNotificationName;
OBJC_EXTERN NSString * _Nonnull FNPayResultResultKey;
OBJC_EXTERN NSString * _Nonnull FNPayResultErrorKey;

typedef NS_ENUM(NSInteger, PaymentChannel) {
    PaymentChannel_ALI,
    PaymentChannel_Weixin,
    PaymentChannel_UPMP,         // 企业对公转账（银联转账）
    PaymentChannel_BFB,          // 百度钱包
    PaymentChannel_JD,           // 京东支付
    
    PaymentChannel_EarnestFeiniu = 0x10,// 飞牛bus定金支付
//    PaymentChannel_Duigong,      // 企业对公转账
};
@interface PingPPayUtil : NSObject
+ (void)payWithParams:(nullable NSDictionary *)dic complete:(void ( ^ _Nullable )( NSDictionary * _Nonnull result))completion;
+ (nonnull NSString *)channelStringValue:(PaymentChannel)channel;

+ (nonnull NSString *)errorMessage:(PingppError *)error;
@end
