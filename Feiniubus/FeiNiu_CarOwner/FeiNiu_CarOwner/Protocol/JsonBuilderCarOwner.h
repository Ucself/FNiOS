//
//  JsonBuilderCarOwner.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/7.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <FNNetInterface/FNNetInterface.h>

@interface JsonBuilderCarOwner : JsonBaseBuilder

/**
 *  单例
 *
 *  @return 单例对象
 */
+(JsonBuilderCarOwner*)sharedInstance;
#pragma mark ---
/**
 *  获取
 *
 *  @param version 获取运营公司-GET
 *
 *  @return 请求json body
 */
-(NSString*)jsonWithCompany:(NSString*)version;

@end
