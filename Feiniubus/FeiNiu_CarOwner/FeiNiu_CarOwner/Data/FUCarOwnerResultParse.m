//
//  FUCarOwnerResultParse.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/10.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "FUCarOwnerResultParse.h"
#import <FNCommon/Constants.h>

@implementation FUCarOwnerResultParse

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
 *  @param dict <#dict description#>
 */
-(void)parseLoginData:(NSDictionary*)dict
{

}

@end
