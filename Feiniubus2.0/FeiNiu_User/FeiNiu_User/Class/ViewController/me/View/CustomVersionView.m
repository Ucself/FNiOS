//
//  CustomVersionView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/14.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CustomVersionView.h"
#import <FNUIView/FNUIView.h>

@interface CustomVersionView ()


@end

@implementation CustomVersionView

+ (instancetype)sharedInstance{
    
    CustomVersionView *customView = [CustomVersionView loadFromNIB];
    
    return customView;
}

- (void)showInView:(UIView *)view{
    
    self.parentView = view;
    
    self.tag = 444;
    
    if ([self.parentView  viewWithTag:444]) {
        return;
    }
    
    [self.parentView  addSubview:self];
    
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.parentView);
    }];
    [self.parentView  layoutIfNeeded];
}

- (IBAction)selectButtonClick:(id)sender {
    
    
}

- (IBAction)upDateAtOnceClick:(id)sender {
    
    
}

- (IBAction)cancelButtonClick:(id)sender {
    
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
