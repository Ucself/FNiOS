//
//  User.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/BaseModel.h>

@interface User : BaseModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSNumber *userType;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSNumber *accumulateMileage;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSNumber *couponsAmount;
@property (nonatomic, strong) NSNumber *phoneType;
@property (nonatomic, strong) NSString *registrationId;


@end
