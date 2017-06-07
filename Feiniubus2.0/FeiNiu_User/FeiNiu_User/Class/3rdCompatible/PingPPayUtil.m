//
//  PingPPayUtil.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "PingPPayUtil.h"
//#import <FNNetInterface/NetInterfaceManager.h>
#import <FNNetInterface/NetInterface.h>

NSString *FNPayResultNotificationName = @"FNPayResultNotificationName";
NSString *FNPayResultResultKey = @"FNPayResultResultKey";
NSString *FNPayResultErrorKey = @"FNPayResultErrorKey";

@implementation PingPPayUtil
+ (void)payWithParams:(NSDictionary *)dic complete:(void (^)(NSDictionary *result))completion{
    NSString *url = [KPayServerAddr stringByAppendingString:@"charge"];
    [[NetInterface sharedInstance] httpPostRequest:url body:dic suceeseBlock:^(NSString *msg) {
        if (completion) {
            completion([JsonUtils jsonToDcit:msg]);
        }
    } failedBlock:^(NSError *msg) {
        if (completion) {
            if (!msg) {
                msg = [NSError errorWithDomain:@"Domain" code:11 userInfo:@{NSLocalizedDescriptionKey:@"未知错误"}];
            }
            completion(@{@"error": msg});
        }
    }];
}

+ (NSString *)channelStringValue:(PaymentChannel)channel{
    NSString *desc = @"";
    switch (channel) {
        case PaymentChannel_ALI:{
            desc = @"1";
            break;
        }
        case PaymentChannel_Weixin:{
            desc = @"13";
            break;
        }
        case PaymentChannel_UPMP:{
            desc = @"upmp";
            break;
        }
        case PaymentChannel_BFB:{
            desc = @"bfb";
            break;
        }
        case PaymentChannel_JD:{
            desc = @"jdpay_wap";
            break;
        }
        default:
            break;
    }
    return desc;
}

+ (nonnull NSString *)errorMessage:(PingppError *)error{
    NSString *message = [error getMsg];
    if (!message) {
        switch (error.code) {
            case PingppErrCancelled:{
                message = @"用户取消操作";
                break;
            }
            case PingppErrChannelReturnFail:{
                message = @"返回支付方式失败";
                break;
            }
            case PingppErrConnectionError:{
                message = @"连接错误";
                break;
            }
            case PingppErrInvalidChannel:{
                message = @"无效支付方式";
                break;
            }
            case PingppErrInvalidCharge:{
                message = @"无效订单";
                break;
            }
            case PingppErrInvalidCredential:{
                message = @"无效证书凭据";
                break;
            }
            case PingppErrTestmodeNotifyFailed:{
                message = @"测试模式通知失败";
                break;
            }
            case PingppErrViewControllerIsNil:{
                message = @"视图控制器设置失败";
                break;
            }
            case PingppErrWxAppNotSupported:{
                message = @"微信不支持";
                break;
            }
            case PingppErrWxNotInstalled:{
                message = @"还没安装微信客户端";
                break;
            }
            default:
            case PingppErrUnknownError:{
                message = @"未知错误";
                break;
            }
        }
    }
    return message;
}

@end
