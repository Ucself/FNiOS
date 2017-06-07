//
//  ProtocolDriver.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ProtocolDriver.h"

@implementation ProtocolDriver

+(ProtocolDriver*)sharedInstance
{
    static ProtocolDriver *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
