//
//  FNPaymentUnion.m
//  FNPayment
//
//  Created by tianbo on 2016/11/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "FNPaymentUnion.h"
#import "UnionPayViewController.h"


#import <FNUIView/WaitView.h>

@interface FNPaymentUnion ()

@end

@implementation FNPaymentUnion


-(instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

/**
 *  类实例方法
 *
 *  @return 类实例
 */
+(FNPaymentUnion*)instance
{
    static FNPaymentUnion *instance = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        instance = [FNPaymentUnion new];
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
    FNUnionOrder *or = (FNUnionOrder*)order;
    if (!or) {
        return;
    }
    
    UnionPayViewController *payController = [[UnionPayViewController alloc] init];
    payController.url = or.url;
    payController.body = or.data;
    payController.successCallback = ^(BOOL success){
        if (success) {
            //支付成功
            self.resultBlock(PaySuccess);
        }
        else {
            //需要查询
            self.resultBlock(ErrCodePayProcessing);
        }
    };
    [controller.navigationController pushViewController:payController animated:YES];
     
}



@end
