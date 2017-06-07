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
//设置默认选中值
- (void)setDefaultValue: (NSObject *)value;

//修改数据源
-(void)updateDataSource:(NSArray*)dataSourceArray useType:(int)useType;

//设置界面显示
- (void)showInView:(UIView *) view;
- (void)cancelPicker:(UIView *) view;

//数据回调
@property (copy, nonatomic) void (^clickComplete)(NSString *resultString);
@property (copy, nonatomic) void (^clickCompleteIndex)(int index, int useType);

@end
