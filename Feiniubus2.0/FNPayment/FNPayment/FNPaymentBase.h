//
//  XDPayBase.h
//  XinRanApp
//
//  Created by tianbo on 15-3-12.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//
//  支付基础类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FNPayOrder.h"

typedef void (^ResultBlock)(int code);
@interface FNPaymentBase : NSObject

{
    
}
@property(nonatomic, copy)ResultBlock resultBlock;

/**
 *  注册
 */
-(void)registerApp:(NSString*)appId;

/**
 *  登录
 */
-(void)login;


/**
 *  支付方法, 由子类自己去实现
 */

-(void)payOrder:(FNPayOrder*)order controller:(UIViewController*)controller result:(void(^)(int))result;


/**
 * 微信与支付宝支付返回码转换
 *
 */
-(PayRetCode)returnCodeConversion:(int)returnCode;

/**
 *  设置回调url
 *
 *  @param url url
 */
//-(void)setHandleOpenUrl:(NSURL*)url;

-(void)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
-(void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;
@end
