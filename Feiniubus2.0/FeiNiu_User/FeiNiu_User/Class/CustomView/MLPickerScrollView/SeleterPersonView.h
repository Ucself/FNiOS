//
//  SeleterPersonView.h
//  MLPickerScrollView
//
//  Created by CYJ on 16/3/24.
//  Copyright © 2016年 MelodyLuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeleterPersonView : UIView

@property (nonatomic,assign)NSInteger discount;

@property(nonnull,copy) void (^clickSeleterPersonCount)(NSInteger personString);

- (void)showInView:(UIView * _Nonnull )view;

@end
