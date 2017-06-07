//
//  XDPayAli.m
//  XinRanApp
//
//  Created by tianbo on 15-3-12.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//
//  支付宝支付类

#import "FNPaymentAli.h"
#import <AlipaySDK/AlipaySDK.h>
//#import "DataSigner.h"


@interface FNPaymentAli ()
{
    
}
@end


@implementation FNPaymentAli


/**
 *  类实例方法
 *
 *  @return 类实例
 */
+(FNPaymentAli*)instance
{
    static FNPaymentAli *instance = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        instance = [FNPaymentAli new];
    });
    
    return instance;
}

/**
 *  注册
 */
-(void)registerApp:(NSString*)appId
{
    
}



/**
 *  支付
 */

-(void)payOrder:(FNPayOrder*)order controller:(UIViewController*)controller result:(void(^)(int))result
{
    self.resultBlock = result;
    FNAliOrder *or = (FNAliOrder*)order;
    if (!or) {
        return;
    }
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"ali1057476865feiniubus";
    if (or.aliDescription != nil) {
        [[AlipaySDK defaultService] payOrder:or.aliDescription fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            //NSLog(@"reslut = %@",resultDic);
            //支付宝返回回调
            int code = [[resultDic objectForKey:@"resultStatus"] intValue];
            //回调
            self.resultBlock([self returnCodeConversion:code]);
        }];
    }
}

/**
 *  设置回调url
 *
 *  @param url url
 */
//-(void)setHandleOpenUrl:(NSURL*)url
//{
//    
//}

-(void)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
}

-(void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            int code = [[resultDic objectForKey:@"resultStatus"] intValue];
            self.resultBlock([self returnCodeConversion:code]);
        }];
    }
    return YES;
}
@end
