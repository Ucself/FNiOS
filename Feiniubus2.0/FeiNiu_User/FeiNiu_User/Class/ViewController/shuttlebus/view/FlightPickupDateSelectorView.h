//
//  DateSelectorVV.h
//  FeiNiu_User
//
//  Created by CYJ on 16/4/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlightPickupDateSelectorView : UIView

@property (nonatomic,copy) void (^clickCompleteBlock)(int interval);

- (void)showInView:(UIView *)view;

- (instancetype)initWithFrame:(CGRect)frame;

@end
