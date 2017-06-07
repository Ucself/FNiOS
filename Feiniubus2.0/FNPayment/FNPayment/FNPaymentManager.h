//
//  XDPayManager.h
//  XinRanApp
//
//  Created by tianbo on 15-3-12.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//
//  支付接口类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FNPayOrder.h"

//支付通知结果
#define   KNotifyPayResult               @"NotifyPayResult"

//一网通支付返回url
#define KUnionPayCallbackURL             @"http://feiniubususer.com.paycallbak/"

typedef NS_ENUM(int, FNPayType)
{
    PayType_Ali = 1,           //支付宝支付
    PayType_WeChat,            //微信支付
    PayType_Union              //银行卡支付
};


#define KNotify

@class UIApplication;
@interface FNPaymentManager : NSObject

/**
 *  类实例方法
 *
 *  @return 类实例
 */
+(FNPaymentManager*)instance;

/**
 *  微信注册
 */
-(void)wechatRegister:(NSString*)appId;


/**
 *  支付宝注册
 */
-(void)aliRegister;


/**
 *  微信登录
 */
-(void)wechatLogin;


/**
 *  支付方法
 *
 *  @param type  支付类型
 *  @param block 构建订单信息block
 *  @param controller  一网通支付需要, 其它传nil
 */
//-(void)payWithType:(FNPayType)type order:(void(^)(FNPayOrder *order))block; (d)
//
//-(void)payWithType:(FNPayType)type order:(void(^)(FNPayOrder *order))orderBlock result:(void(^)(int))resultBlock;


-(void)payWithType:(FNPayType)type controller:(UIViewController*)controller order:(void(^)(FNPayOrder *order))orderBlock result:(void(^)(PayRetCode))resultBlock;


/**
 *  微信,支付宝回调处理方法
 *
 *  @param application
 *  @param url
 */
-(void)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
-(void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;
@end
