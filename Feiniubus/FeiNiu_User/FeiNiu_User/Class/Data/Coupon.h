//
//  Coupon.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

typedef NS_ENUM(NSInteger, CouponState) {
    CouponStateNormal = 1,  //未使用
    CouponStateUsed,        //已使用
    CouponStateExpired,     //过期
};

typedef NS_ENUM(NSInteger, CouponType) {
    CouponTypeCharter = 1,
    CouponTypeCarpool,
    CouponTypeSpecialCar,
};
@interface Coupon : BaseModel
@property (nonatomic, strong) NSString *couponId;
@property (nonatomic, strong) NSString *passengerId;

// 金额，单位分
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSString *orderId;

// 标题
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CouponState state;

// 过期时间
@property (nonatomic, strong) NSDate *expiry;

// 使用限制？
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) CouponType orderType;
@property (nonatomic, assign) BOOL deleted;
@end
