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


-(void)setUserInfo:(User*)user
{
    [self.preDict  setValue:user forKey:@"userinfo"];
    [self save];
}

-(User*)getUserInfo
{
    return [self.preDict objectForKey:@"userinfo"];
}

@end
