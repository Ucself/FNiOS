//
//  ProtocolCarOwner.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/7.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <FNNetInterface/FNNetInterface.h>

@interface ProtocolCarOwner : ProtocolBase

+(ProtocolCarOwner*)sharedInstance;

//设置鉴权
-(void)setAuthorization:(NSString*)auth;
#pragma mark-- 通信协议接口
/**
 *  获取运营公司-GET
 *
 *  @param version
 */
-(void)getCompany:(NSString*)version;
@end
