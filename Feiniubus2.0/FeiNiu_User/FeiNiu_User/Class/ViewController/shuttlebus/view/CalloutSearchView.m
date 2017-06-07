//
//  CalloutView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CalloutSearchView.h"

@implementation CalloutSearchView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        self = [[[NSBundle mainBundle] loadNibNamed:@"CalloutSearchView" owner:self options:nil] firstObject];
        self.frame = CGRectMake(0, 0, 140, 58);
        timeLab.layer.borderColor = [UIColor colorWithRed:0.553 green:0.573 blue:0.588 alpha:1.000].CGColor;
    }
    return self;
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
