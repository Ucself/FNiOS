//
//  BorderButton.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BorderButton : UIButton
@property (nonatomic, assign) IBInspectable NSInteger cornerRadius;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@end
