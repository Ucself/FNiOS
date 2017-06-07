//
//  UINameView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UINameView.h"

@implementation UINameView

+ (instancetype)sharedInstance{
    
    UINameView *view = [[[NSBundle mainBundle] loadNibNamed:@"UINameView" owner:self options:nil] firstObject];
    return view;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
