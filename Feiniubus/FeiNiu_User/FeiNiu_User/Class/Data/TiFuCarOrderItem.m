//
//  TiFuCarOrderItem.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/1.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TiFuCarOrderItem.h"

static TiFuCarOrderItem *tifucarOrderItem = nil;

@implementation TiFuCarOrderItem

+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        tifucarOrderItem = [[TiFuCarOrderItem alloc] init];
    });
    
    return tifucarOrderItem;
}

@end
