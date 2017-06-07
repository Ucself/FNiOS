//
//  CouponsViewController.h
//  FeiNiu_User
//
//  Created by Nick on 15/10/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@class CouponObj;
@interface CouponCell:UITableViewCell

-(void)setCouponCell:(CouponObj*)coupon;

@end

@interface CouponsViewController : UserBaseUIViewController


@property (nonatomic, strong) NSArray<CouponObj *> *coupons;                        //优惠卷数据源
@property (nonatomic, strong) CouponObj *selectedCoupon;                            //选择的优惠卷
@property (nonatomic, strong) NSDictionary *couponsParams;                          //请求参数
@property (nonatomic, strong) void (^selectedCouponsCallback)(CouponObj *coupon);   //回调

@end
