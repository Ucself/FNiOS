//
//  UITextFieldPlaceholderColor.m
//  FeiNiu_User
//
//  Created by tianbo on 2017/2/21.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import "UITextFieldPlaceholderColor.h"

@implementation UITextFieldPlaceholderColor

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setValue:UITextColor_LightGray forKeyPath:@"_placeholderLabel.textColor"];
        [self setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        UIButton *clearButton = [self valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setValue:UITextColor_LightGray forKeyPath:@"_placeholderLabel.textColor"];
        [self setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        UIButton *clearButton = [self valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    }
    return self;
}

@end
