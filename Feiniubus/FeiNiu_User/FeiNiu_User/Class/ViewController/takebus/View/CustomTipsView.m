//
//  CustomTipsView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/23.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CustomTipsView.h"

@implementation CustomTipsView

+ (instancetype)sharedInstance{
    
    CustomTipsView *view = [[[NSBundle mainBundle] loadNibNamed:@"CustomTipsView" owner:nil options:nil] firstObject];
    
    return view;
}

- (IBAction)backGroundClick:(id)sender {
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
