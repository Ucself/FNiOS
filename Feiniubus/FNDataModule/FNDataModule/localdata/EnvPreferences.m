//
//  ConfigInfo.m
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import "EnvPreferences.h"
#import <FNCommon/FileManager.h>

@interface EnvPreferences ()
{
    
}
////token
//@property (copy, nonatomic) NSString *token;
////用户id
//@property (copy, nonatomic) NSString *userId;

@end


@implementation EnvPreferences

+(EnvPreferences*)sharedInstance
{
    static EnvPreferences *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(void)save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:@"Preferences.plist"];
        
        if (![NSKeyedArchiver archiveRootObject:_preDict toFile:fullPath]) {
            DBG_MSG(@"wirte file 'Preferences.plist' failed!");
        }
    });
}

-(id)init
{
    self = [super init];
    if ( !self )
        return nil;
    NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:@"Preferences.plist"];
    _preDict = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    if (_preDict == nil)
    {
        _preDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)dealloc
{
    [self save];
}


#pragma mark--

-(NSString*)getAppVersion
{
    NSString *version = [_preDict valueForKey:@"Version"];
    return version;
}

-(void)setAppVersion:(NSString*)version
{
    [_preDict  setValue:version forKey:@"Version"];
    [self save];
}

//用户token信息
-(void)setToken:(NSString *)token
{
    [_preDict setValue:token forKey:@"Token"];
    [self save];
}

-(NSString*)getToken
{
    NSString *token = [_preDict valueForKey:@"Token"];
//    DBG_MSG(@"The token version is %@", token);
    return token;
}

//用户id缓存信息
-(void)setUserId:(NSString *)userId
{
    [_preDict  setValue:userId forKey:@"UserId"];
    [self save];
}

-(NSString*)getUserId
{
    NSString *userId = [_preDict valueForKey:@"UserId"];
    return userId;
}

//客户端类型缓存缓存信息
-(void)setUserRole:(NSString *)userRole
{
    [_preDict  setValue:userRole forKey:@"UserRole"];
    [self save];
}

-(NSString*)getUserRole
{
    NSString *userRole = [_preDict valueForKey:@"UserRole"];
    return userRole;
}

//检查更新日期
-(void)setCheckData:(NSString*)data
{
    [_preDict setValue:data forKey:@"CheckData"];
    [self save];
}

-(NSString*)getCheckData
{
    return [_preDict objectForKey:@"CheckData"];
}


@end
