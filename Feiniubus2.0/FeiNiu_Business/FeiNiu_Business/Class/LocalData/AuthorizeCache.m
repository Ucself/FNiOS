//
//  AuthorizeCache.m
//  FeiNiu_Business
//
//  Created by tianbo on 16/7/5.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AuthorizeCache.h"

@implementation AuthorizeCache


+(AuthorizeCache*)sharedInstance
{
    static AuthorizeCache *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _accessToken = [self.preDict objectForKey:@"accessToken"];
        _refreshToken = [self.preDict objectForKey:@"refreshToken"];
    }
    return self;
}


-(void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    [self.preDict setValue:_accessToken forKey:@"accessToken"];
    [self save];
}


-(void)setRefreshToken:(NSString *)refreshToken
{
    _refreshToken = refreshToken;
    [self.preDict setValue:_refreshToken forKey:@"refreshToken"];
    [self save];
}


-(void)clean
{
    _accessToken = nil;
    _refreshToken = nil;
    [self.preDict setValue:@"" forKey:@"accessToken"];
    [self.preDict setValue:@"" forKey:@"refreshToken"];
    [self save];
}
@end