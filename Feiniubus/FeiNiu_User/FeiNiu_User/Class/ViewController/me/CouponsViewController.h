//
//  CouponsViewController.h
//  FeiNiu_User
//
//  Created by Nick on 15/10/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "Coupon.h"

OBJC_EXTERN NSString *FNRequestCouponTypeKey;
OBJC_EXTERN NSString *FNRequestCouponStateKey;
OBJC_EXTERN NSString *FNRequestCouponLimitKey;


@interface CouponsViewController : UserBaseUIViewController
@property (nonatomic, strong) NSArray<Coupon *> *coupons;
@property (nonatomic, strong) Coupon *selectedCoupon;
/**
 *  @author Nick
 *
 *  优惠券参数
 */
@property (nonatomic, strong) NSDictionary *couponsParams;

@property (nonatomic, strong) void (^selectedCouponsCallback)(Coupon *coupon);
@end
