//
//  NetParams.m
//  FNNetInterface
//
//  Created by tianbo on 16/1/15.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import "NetParams.h"

@implementation NetParams


-(instancetype)init
{
    self = [super init];
    if (self) {
        _method = EMRequstMethod_GET;
        _data = nil;
    }
    return self;
}
@end
