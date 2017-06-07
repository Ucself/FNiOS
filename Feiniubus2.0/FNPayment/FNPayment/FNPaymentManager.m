//
//  XDPayManager.m
//  XinRanApp
//
//  Created by tianbo on 15-3-12.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//

#import "FNPaymentManager.h"
#import "FNPaymentAli.h"
#import "FNPaymentWeChat.h"
#import "FNPaymentUnion.h"

@interface FNPaymentManager ()
{
    //XDPayBase *xdPay;
    
}

@property(nonatomic, strong) NSString *wechatAPPID;
@end

@implementation FNPaymentManager

/**
 *  类实例方法
 *
 *  @return 类实例
 */
+(FNPaymentManager*)instance
{
    static FNPaymentManager *instance = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        instance = [FNPaymentManager new];
    });
    
    return instance;
}

-(FNPaymentBase*)payInstanceWithType:(int)type
{
    FNPaymentBase *xdPay;
    switch (type) {
        case PayType_WeChat: {
            xdPay = [FNPaymentWeChat instance];
        }
            break;
        case PayType_Ali: {
            xdPay = [FNPaymentAli instance];
        }
            break;
        case PayType_Union: {
            xdPay = [FNPaymentUnion instance];
        }
            
        default:
            break;
    }
    
    return xdPay;
}

/**
 *  微信注册
 */
-(void)wechatRegister:(NSString*)appId
{
    self.wechatAPPID = appId;
    [[FNPaymentWeChat instance] registerApp:appId];
}


/**
 *  支付宝注册
 */
-(void)aliRegister
{
    //[[XDPayAli instance] registerApp:@""];
}

-(void)wechatLogin
{
    [[FNPaymentWeChat instance] login];
}

//-(void)payWithType:(FNPayType)type order:(void(^)(FNPayOrder *order))block
//{
//    FNPayOrder *order;
//    switch (type) {
//        case PayType_Ali:
//            order = [FNAliOrder new];
//            break;
//        case PayType_WeChat:
//            order = [FNWeChatOrder new];
//            break;
//        case PayType_Union:
//            break;
//        default:
//            break;
//    }
//    block(order);
//    [[self payInstanceWithType:type] payOrder:order];
//}

//-(void)payWithType:(FNPayType)type order:(void(^)(FNPayOrder *order))orderBlock result:(void(^)(int code))resultBlock;
//{
//    FNPayOrder *order;
//    switch (type) {
//        case PayType_Ali:
//            order = [FNAliOrder new];
//            break;
//        case PayType_WeChat:
//            order = [FNWeChatOrder new];
//            break;
//        case PayType_Union:
//            break;
//        default:
//            break;
//    }
//    
//    //生成订单数据
//    orderBlock(order);
//    
//    //调用相应支付接口
//    [[self payInstanceWithType:type] payOrder:order result:resultBlock];
//}

/**
 *  支付方法
 *
 *  @param type  支付类型
 *  @param block 构建订单信息block
 *  @param controller  一网通支付需要, 其它传nil
 */
-(void)payWithType:(FNPayType)type controller:(UIViewController*)controller order:(void(^)(FNPayOrder *order))orderBlock result:(void(^)(PayRetCode))resultBlock
{
    FNPayOrder *order;
    switch (type) {
        case PayType_Ali:
            order = [FNAliOrder new];
            break;
        case PayType_WeChat:
            order = [FNWeChatOrder new];
            break;
        case PayType_Union:
            order = [FNUnionOrder new];
            break;
        default:
            break;
    }
    
    //生成订单数据
    orderBlock(order);
    

    //调用相应支付接口
    [[self payInstanceWithType:type] payOrder:order controller:controller result:resultBlock];

    
}

/**
 *  微信,支付宝回调处理方法
 *
 *  @param application
 *  @param url
 */
-(void)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [[FNPaymentWeChat instance] application:application handleOpenURL:url];
}

-(void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *urls = [url absoluteString];
    if([urls rangeOfString:self.wechatAPPID].location !=NSNotFound) {
         [[FNPaymentWeChat instance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    else {
         [[FNPaymentAli instance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    NSString *urls = [url absoluteString];
    if([urls rangeOfString:self.wechatAPPID].location !=NSNotFound) {
        [[FNPaymentWeChat instance] application:app openURL:url options:options];
    }else {
        [[FNPaymentAli instance] application:app openURL:url options:options];
    }
    
    return YES;
}


@end
