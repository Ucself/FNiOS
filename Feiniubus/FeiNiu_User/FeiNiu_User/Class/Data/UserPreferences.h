//
//  UserPreferences.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/26.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>

#import "User.h"

@interface UserPreferences : EnvPreferences

+(UserPreferences*)sharedInstance;


-(void)setUserInfo:(User*)user;
-(User*)getUserInfo;

@end
