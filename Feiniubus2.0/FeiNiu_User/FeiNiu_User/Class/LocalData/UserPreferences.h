//
//  UserPreferences.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/26.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>


#define UserPreferInstance  [UserPreferences sharedInstance]

@class User;
@interface UserPreferences : EnvPreferences

+(UserPreferences*)sharedInstance;


-(void)setUserInfo:(User*)user;
-(User*)getUserInfo;


//本地保存的app版本
-(NSString*)getAppVersion;
-(void)setAppVersion:(NSString*)version;

//客户端类型缓存缓存信息
-(void)setUserRole:(NSString *)userRole;
-(NSString*)getUserRole;

//检查更新日期
-(void)setCheckData:(NSString*)data;
-(NSString*)getCheckData;

//线路详情
-(void)setLineGuide:(NSString *)name;
-(NSString*)getLineGuide;
//车票信息
-(void)setTicketGuide:(NSString *)name;
-(NSString*)getTicketGuide;

//测试版本自定议Server地址
-(void)setTestServerAddr:(NSString*)addr;
-(NSString*)getTextServerAddr;
-(void)setTestAuthorizeAddr:(NSString*)addr;
-(NSString*)getTextAuthorizeAddr;
-(void)setTestLocationAddr:(NSString*)addr;
-(NSString*)getTextLocationAddr;

//广告信息
-(void)setAdvertInfo:(NSDictionary*)dict;
-(NSDictionary*)getAdvertInfo;
@end
