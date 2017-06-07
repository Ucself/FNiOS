//
//  UserPreferences.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/26.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "UserPreferences.h"

@implementation UserPreferences


+(UserPreferences*)sharedInstance
{
    static UserPreferences *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    if ( !self )
        return nil;
   
    return self;
}


-(void)setUserInfo:(id)user
{
    [self.preDict  setValue:user forKey:@"userinfo"];
    [self save];
}

-(id)getUserInfo
{
    return [self.preDict objectForKey:@"userinfo"];
}


-(NSString*)getAppVersion
{
    NSString *version = [self.preDict valueForKey:@"Version"];
    return version;
}

-(void)setAppVersion:(NSString*)version
{
    [self.preDict  setValue:version forKey:@"Version"];
    [self save];
}

//用户id缓存信息
-(void)setUserId:(NSString *)userId
{
    [self.preDict setValue:userId forKey:@"UserId"];
    [self save];
}

-(NSString*)getUserId
{
    NSString *userId = [self.preDict valueForKey:@"UserId"];
    return userId;
}

//客户端类型缓存缓存信息
-(void)setUserRole:(NSString *)userRole
{
    [self.preDict setValue:userRole forKey:@"UserRole"];
    [self save];
}

-(NSString*)getUserRole
{
    NSString *userRole = [self.preDict valueForKey:@"UserRole"];
    return userRole;
}

//检查更新日期
-(void)setCheckData:(NSString*)data
{
    [self.preDict setValue:data forKey:@"CheckData"];
    [self save];
}

-(NSString*)getCheckData
{
    return [self.preDict objectForKey:@"CheckData"];
}
@end
