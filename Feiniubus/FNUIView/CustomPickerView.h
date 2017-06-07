//
//  DatePickerView.h
//  XRUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"

@protocol CustomPickerViewDelegate <NSObject>

- (void)pickerViewCancel;
- (void)pickerViewOK:(int)index useType:(int)useType;

@end

@interface CustomPickerView : BaseUIView

@property(nonatomic, assign) id<CustomPickerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame dataSourceArray:(NSArray*)dataSourceArray useType:(int)useType;
- (void)setDefaultValue: (NSObject *)value;
- (void)showInView:(UIView *) view;
- (void)cancelPicker:(UIView *) view;

@end
