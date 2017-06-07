//
//  SubmitStyleButton.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "SubmitStyleButton.h"
#import "UIColor+Hex.h"
#import "CommonDefines.h"

@implementation SubmitStyleButton

- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.cornerRadius = 4;
    self.backgroundColor = [UIColor colorWithHex:GloabalTintColor];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:17];
}

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
