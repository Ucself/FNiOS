//
//  CarpoolTravelStatusProgressView.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolTravelStatusProgressView.h"
#import "UIColor+Hex.h"
#import "UserBaseUIViewController.h"

#define LineWidth 1.5
#define MarginSide 30
#define M_2_CircleRadius 15

@interface CarpoolTravelStatusProgressView ()
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* labels;
@end
@implementation CarpoolTravelStatusProgressView
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (CGFloat)space{
    return (self.frame.size.width - 2 * MarginSide - (self.labels.count) * M_2_CircleRadius) / (self.labels.count - 1);
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat centerY = [self offsetY] + M_2_CircleRadius / 2 + 12;
    CGFloat space = [self space];

    for (int i = 0; i < self.labels.count; i++) {
        CGFloat centerX = MarginSide + M_2_CircleRadius / 2 + i * (space + M_2_CircleRadius );
        UILabel *label = self.labels[i];
        [label sizeToFit];
        [label setCenter:CGPointMake(centerX, centerY)];
        if (i <= _state) {
            label.textColor = [UIColor colorWithHex:GloabalTintColor];
        }
    }
}

#pragma mark - Setter & Getter
- (void)setState:(NSInteger)state{
    _state = state;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
- (CGFloat)offsetY{
    return self.frame.size.height / 2 - 8;
}
- (CGPoint)progressP{
    CGFloat space = (self.frame.size.width - 2 * MarginSide) / (self.labels.count - 1);
    CGFloat x = MarginSide + _state * space;
    if (_state >= self.labels.count - 1) {
        x = self.frame.size.width;
    }
    return CGPointMake(x, [self offsetY]);
}
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, [self offsetY]);
    CGContextAddLineToPoint(context, rect.size.width, [self offsetY]);
    CGContextSetLineWidth(context, LineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHex:0xE0E0E0].CGColor);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 0, [self offsetY]);
    CGContextAddLineToPoint(context, [self progressP].x, [self offsetY]);
    CGContextSetLineWidth(context, LineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHex:GloabalTintColor].CGColor);
    CGContextStrokePath(context);
    CGContextSaveGState(context);
    
    CGFloat space = (rect.size.width - 2 * MarginSide - (self.labels.count) * M_2_CircleRadius) / (self.labels.count - 1);
    DBG_MSG(@"%@", @(_state));
    for (int i = 0; i < self.labels.count; i++) {
        CGRect circleRect = CGRectMake(MarginSide + i * (space + M_2_CircleRadius ), [self offsetY] - M_2_CircleRadius / 2, M_2_CircleRadius, M_2_CircleRadius);
        if (i <= _state) {
            CGContextSetFillColorWithColor(context, [UIColor colorWithHex:0xFFFFFF].CGColor);
        }else{
            CGContextSetFillColorWithColor(context, [UIColor colorWithHex:0xE0E0E0].CGColor);
        }
        CGContextFillEllipseInRect(context, circleRect);
        if (i <= _state) {
            [[UIImage imageNamed:@"carpool_process_mark"] drawInRect:circleRect];
        }
    }
}

@end
