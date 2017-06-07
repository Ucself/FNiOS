//
//  UIColor+Hex.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)
+ (UIColor *)colorWithHex:(NSUInteger)hex{
    return [self colorWithHex:hex alpha:1];
}


+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha{
    NSInteger red = (hex & 0xFF0000) >> 16;
    NSInteger green = (hex & 0x00FF00) >> 8;
    NSInteger blue = (hex & 0x0000FF);
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:alpha];
}

@end
