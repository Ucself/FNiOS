//
//  ProtocolCarOwner.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/7.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ProtocolCarOwner.h"
#import "JsonBuilderCarOwner.h"
#import <FNCommon/FNCommon.h>

@implementation ProtocolCarOwner

+(ProtocolCarOwner*)sharedInstance
{
    static ProtocolCarOwner *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

//设置鉴权
-(void)setAuthorization:(NSString*)auth
{
    [[NetInterfaceManager sharedInstance] setAuthorization:auth];
}
#pragma mark-- 通信协议接口

/**
 *  获取运营公司-GET
 *
 *  @param version 
 */
-(void)getCompany:(NSString*)version
{
    NSString *body = [[JsonBuilderCarOwner sharedInstance] jsonWithCompany:version];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, Kurl_company];
    
    [self getRequst:url body:body requestType:KRequestType_company];
}

@end
