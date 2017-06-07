//
//  AuthorizeCache.h
//  FeiNiu_Business
//
//  Created by tianbo on 16/7/5.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>


#define AuthorizeCacheInstance  [AuthorizeCache sharedInstance]


@interface AuthorizeCache : EnvPreferences


@property (nonatomic, copy, getter=getAccessToken)  NSString *accessToken;
@property (nonatomic, copy, getter=getRefreshToken) NSString *refreshToken;
@property (nonatomic, copy, getter=getUserId)  NSString *userId;
@property (nonatomic, copy, getter=getUserId)  NSString *userName;

+(AuthorizeCache*)sharedInstance;

-(void)clean;
@end
