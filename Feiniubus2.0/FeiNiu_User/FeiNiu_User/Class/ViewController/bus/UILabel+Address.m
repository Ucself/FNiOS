
//
//  UILabel+Address.m
//  FeiNiu_User
//
//  Created by CYJ on 16/4/19.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UILabel+Address.h"
#import <objc/runtime.h>

static char locationKey;

@implementation UILabel (Address)

- (void)setLocation:(FNLocation *)location
{
    objc_setAssociatedObject(self, &locationKey, location, OBJC_ASSOCIATION_RETAIN);
}

- (FNLocation *)location
{
    return objc_getAssociatedObject(self, &locationKey);
}

@end
