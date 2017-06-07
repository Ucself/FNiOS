//
//  UserPreferences.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/26.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "UserPreferences.h"
#import "FeiNiu_User-Swift.h"

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


-(void)setUserInfo:(User*)user
{
    if (!user) {
        return;
    }
    [self.preDict  setValue:user forKey:@"userinfo"];
    [self save];
}

-(User*)getUserInfo
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
    if (!version) {
        return;
    }
    [self.preDict  setValue:version forKey:@"Version"];
    [self save];
}

//客户端类型缓存缓存信息
-(void)setUserRole:(NSString *)userRole
{
    if (!userRole) {
        return;
    }
    
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
    if (!data) {
        return;
    }
    [self.preDict setValue:data forKey:@"CheckData"];
    [self save];
}

-(NSString*)getCheckData
{
    return [self.preDict objectForKey:@"CheckData"];
}
///////////////////////////
-(void)setLineGuide:(NSString*)name
{
    if (!name) {
        return;
    }
    [self.preDict  setValue:name forKey:@"lineGuide"];
    [self save];
}

-(NSString*)getLineGuide
{
    return [self.preDict objectForKey:@"lineGuide"];
}

-(void)setTicketGuide:(NSString*)name
{
    if (!name) {
        return;
    }
    [self.preDict  setValue:name forKey:@"ticketGuide"];
    [self save];
}

-(NSString*)getTicketGuide
{
    return [self.preDict objectForKey:@"ticketGuide"];
}

//广告信息
-(void)setAdvertInfo:(NSDictionary*)dict
{
    if (!dict) {
        return;
    }
    [self.preDict setValue:dict forKey:@"AdvertInfo"];
    [self save];
}
-(NSDictionary*)getAdvertInfo
{
    return [self.preDict objectForKey:@"AdvertInfo"];
}

//////////////////////测试版本自定议Server地址/////////////////////////////////
//{{
-(void)setTestServerAddr:(NSString*)addr
{
    [self.preDict setValue:addr forKey:@"TestServerAddr"];
    [self save];
}
-(NSString*)getTextServerAddr
{
    return [self.preDict objectForKey:@"TestServerAddr"];
}

-(void)setTestAuthorizeAddr:(NSString*)addr
{
    [self.preDict setValue:addr forKey:@"AuthorizeAddr"];
    [self save];
}
-(NSString*)getTextAuthorizeAddr
{
    return [self.preDict objectForKey:@"AuthorizeAddr"];
}
-(void)setTestLocationAddr:(NSString*)addr
{
    [self.preDict setValue:addr forKey:@"LocationAddr"];
    [self save];
}
-(NSString*)getTextLocationAddr
{
    return [self.preDict objectForKey:@"LocationAddr"];
}

//}}
//////////////////////测试版本自定议Server地址/////////////////////////////////
@end
