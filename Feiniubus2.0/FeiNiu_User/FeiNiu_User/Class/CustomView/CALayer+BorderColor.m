//
//  CALayer+BorderColor.m
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CALayer+BorderColor.h"

@implementation CALayer (BorderColor)


- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end
