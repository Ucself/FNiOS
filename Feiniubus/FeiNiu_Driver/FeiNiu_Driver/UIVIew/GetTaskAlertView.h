//
//  CustomAlertView.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/28.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BaseUIView.h"
#import <FNUIView/BaseUIView.h>
#import <FNCommon/FNCommon.h>

@protocol GetTaskAlertViewDelegate <NSObject>

- (void)getTaskAlertViewCancel;
- (void)getTaskAlertViewOK:(NSString*)firstContent  secondContent:(NSString*)secondContent;

@end

@interface GetTaskAlertView : BaseUIView

@property(nonatomic, assign) id<GetTaskAlertViewDelegate> delegate;
@property(nonatomic, strong) UITextField *inputDate;
@property(nonatomic, strong) UITextField *secondDate;

-(instancetype)initWithFrame:(CGRect)frame alertName:(NSString*)alertName alertInputContent:(NSString*)alertInputContent alertUnit:(NSString*)alertUnit keyboardType:(UIKeyboardType)keyboardType  useType:(int)useType;
-(instancetype)init;
-(void)showInView:(UIView *)view;
-(void)cancelPicker:(UIView *)view;

@end
