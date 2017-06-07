//
//  MapCoordinaterModule.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "MapCoordinaterModule.h"
#import <FNCommon/JsonUtils.h>

@implementation MapCoordinaterModule

+ (instancetype)sharedInstance{
    
    static MapCoordinaterModule *mapCoordinater = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapCoordinater = [[MapCoordinaterModule alloc] init];
    });
    
    return mapCoordinater;
}

@end
