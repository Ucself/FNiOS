//
//  ConfigInfo.h
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
//  系统环境参数类

#import <Foundation/Foundation.h>

@interface EnvPreferences : NSObject
{
    
}
@property (nonatomic, strong) NSMutableDictionary  *preDict;

-(void)save;

+(EnvPreferences*)sharedInstance;

//本地保存的app版本
-(NSString*)getAppVersion;
-(void)setAppVersion:(NSString*)version;

//用户token信息
-(void)setToken:(NSString *)token;
-(NSString*)getToken;

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
