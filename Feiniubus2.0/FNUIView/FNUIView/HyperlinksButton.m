//
//  HyperlinksButton.m
//  FNUIView
//
//  Created by tianbo on 16/3/29.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import "HyperlinksButton.h"

@interface HyperlinksButton ()

@property (nonatomic, strong) UIColor *sLineColor;
@end

@implementation HyperlinksButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)setColor:(UIColor *)color{
    _sLineColor = [color copy];
    //[self setNeedsDisplay];
}


- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGFloat descender = self.titleLabel.font.descender;
    CGContextSetStrokeColorWithColor(contextRef, UIColor_DefOrange.CGColor);

    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender+1);
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender+1);
    
    CGContextClosePath(contextRef);
    CGContextDrawPath(contextRef, kCGPathStroke);
}
@end
