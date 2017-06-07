//
//  CustomAlertView.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/28.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"

@protocol CustomAlertViewDelegate <NSObject>

- (void)customAlertViewCancel;
- (void)customAlertViewOK:(NSString*)result  useType:(int)useType;

@end

@interface CustomAlertView : BaseUIView

@property(nonatomic, strong) UITextField *inputDate;
@property(nonatomic, assign) id<CustomAlertViewDelegate> delegate;
@property(nonatomic, assign) int limitCount; //限制输入个数

-(instancetype)initWithFrame:(CGRect)frame alertName:(NSString*)alertName alertInputContent:(NSString*)alertInputContent alertUnit:(NSString*)alertUnit keyboardType:(UIKeyboardType)keyboardType  useType:(int)useType;
- (void)showInView:(UIView *) view;
- (void)cancelPicker:(UIView *) view;

@end
