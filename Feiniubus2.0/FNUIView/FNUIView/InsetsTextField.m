//
//  InsetsTextField.m
//  FNUIView
//
//  Created by tianbo on 16/7/8.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import "InsetsTextField.h"

@implementation InsetsTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(CGRect) leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += _insetsLeft;
    return iconRect;

}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += _insetsLeft;
    return textRect;
}

-(void)setInsetsLeft:(int)insetsLeft
{
    _insetsLeft = insetsLeft;
    //[self setNeedsLayout];
}

@end
