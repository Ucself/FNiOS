//
//  UserQueQueView.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/30.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserQueQueView.h"

@implementation UserQueQueView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat queRadius = 15;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width / 2 - queRadius, 0)];
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width/2, 0) radius:queRadius startAngle:M_PI endAngle:0 clockwise:NO];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, 0)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [bezierPath addLineToPoint:CGPointMake(0, rect.size.height)];
    [bezierPath closePath];
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
}

@end
