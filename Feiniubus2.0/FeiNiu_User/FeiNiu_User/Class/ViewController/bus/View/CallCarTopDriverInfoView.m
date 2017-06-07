//
//  CallCarStateTopView.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CallCarTopDriverInfoView.h"

@interface CallCarTopDriverInfoView()

@end

@implementation CallCarTopDriverInfoView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"CallCarTopDriverInfoView" owner:self options:nil][0];
        
        _gradeView.interval = 2;
        [_gradeView setImageDeselected:@"small_star_nor" halfSelected:@"small_star_half" fullSelected:@"small_star_press" andDelegate:nil];
        [_gradeView setIsIndicator:YES];        
    }
    return self;
}

- (IBAction)clickCallPhoneAction:(UIButton *)sender
{
    if (_clickPhoneAction) {
        _clickPhoneAction();
    }
}

@end
