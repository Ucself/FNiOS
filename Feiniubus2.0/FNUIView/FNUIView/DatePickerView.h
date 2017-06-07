//
//  DatePickerView.h
//  XRUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"
@class DatePickerView;
@protocol DatePickerViewDelegate <NSObject>
@optional
- (void)pickerViewCancel;
- (void)pickerView:(DatePickerView*)view selectDate:(NSString*)date;
@end
@interface DatePickerView : BaseUIView

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnOk;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, assign) BOOL isShowTitle;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic) UIDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;
@property(nonatomic) NSInteger minuteInterval;

@property (copy, nonatomic) void (^clickComplete)(NSString *resultString);

- (void)showInView:(UIView *) view;
- (void)cancelPicker:(UIView *) view;
@end
