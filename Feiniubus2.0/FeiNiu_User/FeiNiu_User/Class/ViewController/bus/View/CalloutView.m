//
//  CalloutView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CalloutView.h"


@implementation CalloutView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        self = [[[NSBundle mainBundle] loadNibNamed:@"CalloutView" owner:self options:nil] firstObject];
        self.frame = CGRectMake(0, 0, 185, 58);
        timeLab.layer.borderColor = [UIColor colorWithRed:0.553 green:0.573 blue:0.588 alpha:1.000].CGColor;
    }
    return self;
}

- (IBAction)clickTapAction:(UIGestureRecognizer *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(jumpAction)]) {
        [self.delegate jumpAction];
    }
}

- (void)setDesStr:(NSString *)desStr
{
    if (desStr && desStr.length > 0) {
        descLab.text = desStr;
    }
}

- (void)setTimeStr:(NSString *)timeStr
{
    if (timeStr && timeStr.length > 0) {
        timeLab.text = timeStr;
    }
}

- (void)setAttributdesStr:(NSAttributedString *)attributdesStr
{
    if (attributdesStr) {
        descLab.attributedText = attributdesStr;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
