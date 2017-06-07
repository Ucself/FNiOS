//
//  IBDesignableOnePixelConstant.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/10.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "IBDesignableOnePixelConstant.h"

@implementation IBDesignableOnePixelConstant

- (void)setOnePixelConstant:(NSInteger)onePixelConstant
{
    _onePixelConstant = onePixelConstant;
    self.constant = onePixelConstant * 1.0 / [UIScreen mainScreen].scale;
}


@end
