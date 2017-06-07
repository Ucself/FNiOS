//
//  PhoneNumberView.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNumberView : UIView

- (void)showInView:(UIView *)view;

/**
 * @breif 用于弹出通讯录
 */
@property(nonatomic,assign) id addressDelegate;

@property (copy, nonatomic) void (^clickComplete)(NSString *phoneNumber);

@end
