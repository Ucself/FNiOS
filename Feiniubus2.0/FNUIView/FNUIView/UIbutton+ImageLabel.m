//
//  UIbutton+ImageLabel.m
//  XinRanApp
//
//  Created by tianbo on 15-1-8.
//  Copyright (c) 2015年 mac.com All rights reserved.
//

#import "UIbutton+ImageLabel.h"


@implementation UIButton (UIButtonImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType {

    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-16.0,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];
    
    [self setImage:image forState:stateType];
    

    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    //[self.titleLabel setTextColor:[UIColor greenColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(20.0,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    
    [self setTitle:title forState:stateType];
    
}

@end

