//
//  DotLineView.m
//  FNUIView
//
//  Created by tianbo on 2017/5/22.
//  Copyright © 2017年 feiniu.com. All rights reserved.
//

#import "DotLineView.h"

@interface DotLineView ()

@property (nonatomic, assign) int lineLength;
@property (nonatomic, assign) int lineSpacing;
@property (nonatomic, strong) UIColor *lineColor;
@end

@implementation DotLineView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initParams];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initParams];
    }
    return self;
}

-(void)initParams
{
    self.backgroundColor = [UIColor whiteColor];
    _lineLength = 1;
    _lineSpacing = 1;
    _lineColor = UIColorFromRGB(0xbbbbbb);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context,1);
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGFloat lengths[] = {_lineLength,_lineSpacing};
    CGContextSetLineDash(context, 0.2, lengths,2);
    CGContextMoveToPoint(context, 0.2, 0);
    CGContextAddLineToPoint(context, 0.2, self.frame.size.height);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}

@end
