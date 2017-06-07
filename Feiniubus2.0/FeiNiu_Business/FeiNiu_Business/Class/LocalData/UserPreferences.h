//
//  UserPreferences.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/26.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>

//#import "User.h"

#define UserPreferInstance  [UserPreferences sharedInstance]

@interface UserPreferences : EnvPreferences

+(UserPreferences*)sharedInstance;


-(void)setUserInfo:(id)user;
-(id)getUserInfo;

//本地保存的app版本
-(NSString*)getAppVersion;
-(void)setAppVersion:(NSString*)version;

//用户id缓存信息
-(void)setUserId:(NSString *)userId;
-(NSString*)getUserId;

//客户端类型缓存缓存信息
-(void)setUserRole:(NSString *)userRole;
-(NSString*)getUserRole;

//检查更新日期
-(void)setCheckData:(NSString*)data;
-(NSString*)getCheckData;
@end
