//
//  BorderButton.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "BorderButton.h"

@implementation BorderButton

- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.cornerRadius = self.cornerRadius;
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
}

/*
* Only override drawRect: if you perform custom drawing.
 
* An empty implementation adversely affects performance during animation.
 
*/
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
////    clipPath.usesEvenOddFillRule = YES;
//    [clipPath addClip];
//    
////    [self.borderColor set];
////    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, 1) cornerRadius:self.cornerRadius];
////    path.lineWidth = 2;
////    [path stroke];
//
//    
//}


@end
