//
//  UIbutton+ImageLabel.h
//  XinRanApp
//
//  Created by tianbo on 15-1-8.
//  Copyright (c) 2015年 mac.comcom All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UIButtonImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType;

@end