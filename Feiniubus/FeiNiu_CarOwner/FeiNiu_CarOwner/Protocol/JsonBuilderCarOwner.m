//
//  JsonBuilderCarOwner.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/7.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "JsonBuilderCarOwner.h"

@implementation JsonBuilderCarOwner

/**
 *  单例
 *
 *  @return 单例对象
 */
+(JsonBuilderCarOwner*)sharedInstance
{
    static JsonBuilderCarOwner *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}
#pragma mark ---
/**
 *  获取
 *
 *  @param version 获取运营公司-GET
 *
 *  @return 请求json body
 */
-(NSString*)jsonWithCompany:(NSString*)version
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:version forKey:@"version"];
    NSString *jsonString = [self generateJsonWithDictionary:dict];
    return jsonString;
}
@end
