//
//  FUDriverResultParse.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "FUDriverResultParse.h"
#import <FNCommon/FNCommon.h>

@implementation FUDriverResultParse

-(id)initWithDictionary:(NSDictionary *)dict
{
    NSDictionary *data = [dict objectForKey:@"data"];
    int requestType = [[dict objectForKey:@"type"] intValue];
    
    self = [super initWithDictionary:data reqType:requestType];
    if (self) {
        
    }
    return self;
}

//将返回的字典数据转化为相应的类
-(void)parseData:(NSDictionary*)dict
{
    self.data = dict;
}

#pragma mark ---
/**
 *  解析登录返回数据
 *
 *  @param dict
 */
-(void)parseLoginData:(NSDictionary*)dict
{
    
}

@end
