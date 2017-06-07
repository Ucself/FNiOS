//
//  DatePickerView.h
//  XRUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>
#import <FNCommon/FNCommon.h>


@protocol TopDatePickerViewDelegate <NSObject>

@optional
- (void)pickerViewCancel;
- (void)pickerViewOK:(NSString*)date;

@end
@interface TopDatePickerView : BaseUIView

@property(nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic,assign) id<TopDatePickerViewDelegate> delegate;
@property (nonatomic,strong) UIButton *btnCancel;
@property (nonatomic,strong) UIButton *btnOk;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *lineImageView;
@property (nonatomic,assign) BOOL isShowTitle;
@property (nonatomic) UIDatePickerMode datePickerMode;


- (void)showInView:(UIView *) view;
- (void)cancelPicker:(UIView *) view;
@end
