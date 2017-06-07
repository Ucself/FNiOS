//
//  DatePickerView.m
//  XRUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//

#import "DatePickerView.h"
#import <FNCommon/FNCommon.h>

#define  kContentHeight    250
#define GloabalTintColor 0xFE714B

@interface DatePickerView ()

@property(nonatomic, strong) UIView *contentView;
@end

@implementation DatePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datePickerMode = UIDatePickerModeDate;
        self.isShowTitle = NO;
        [self iniUI];
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}
-(void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    _datePickerMode = datePickerMode;
    self.datePicker.datePickerMode = datePickerMode;
}

-(void)setIsShowTitle:(BOOL)isShowTitle
{
    _isShowTitle = isShowTitle;
    if (isShowTitle) {
        [self datePickerValueChanged:nil];
    }
}
- (void)setMinDate:(NSDate *)minDate{
    self.datePicker.minimumDate = minDate;
}

- (NSDate *)minDate{
    return self.datePicker.minimumDate;
}

- (void)setMaxDate:(NSDate *)maxDate{
    self.datePicker.maximumDate = maxDate;
}

- (NSDate *)maxDate{
    return self.datePicker.maximumDate;
}
-(void)iniUI
{
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];

    [self addSubview:_contentView];
    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.width.equalTo(self);
        make.top.equalTo(self.bottom);
        make.height.equalTo(kContentHeight);
    }];
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _datePicker.datePickerMode = UIDatePickerModeDate;

    [_datePicker addTarget:self
                    action:@selector(datePickerValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [_contentView addSubview:_datePicker];
    
    [_datePicker makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(40);
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.bottom.equalTo(_contentView);
    }];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_btnCancel setTintColor:UIColorFromRGB(0xb4b4b4)];
    [_btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnCancel];
    
    [_btnCancel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView.left).offset(10);
        make.top.equalTo(_contentView.top);
        make.width.equalTo(40);
        make.height.equalTo(40);
    }];
    
    _btnOk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnOk setTitle:@"确定" forState:UIControlStateNormal];
//    [_btnOk setTintColor:UIColorFromRGB(0x06c1ae)];
    [_btnOk setTintColor:UIColorFromRGB(GloabalTintColor)];
    [_btnOk addTarget:self action:@selector(btnOKClick) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnOk];
    
    [_btnOk makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_contentView.right).offset(-10);
        make.top.equalTo(_contentView);
        make.width.equalTo(40);
        make.height.equalTo(40);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel setTextColor:UIColorFromRGB(0x06c1ae)];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setText:[NSDate formatDate:_datePicker.minimumDate format:@"yyyy-MM-dd HH:mm:ss"]];
    [_contentView addSubview:_titleLabel];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_btnOk.left).offset(-10);
        make.left.equalTo(_btnCancel.right).offset(10);
        make.top.equalTo(_contentView);
        make.height.equalTo(40);
    }];
    
    _lineImageView = [[UIImageView alloc]init];
//    _lineImageView.backgroundColor = UIColorFromRGB(0x06c1ae)
    [_lineImageView setBackgroundColor:UIColorFromRGB(GloabalTintColor)];
    [_contentView addSubview:_lineImageView];
    [_lineImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.top.equalTo(_contentView);
        make.height.equalTo(3);
    }];
    
}

- (void)showInView:(UIView *) view
{
    self.tag = 11108;
    if ([view viewWithTag:11108]) {
        return;
    }
    
    [view addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(view);
            make.top.equalTo(view.bottom).offset(-kContentHeight);
            make.height.equalTo(kContentHeight);
        }];
        
        [view layoutIfNeeded];
        
    }];
    
}
- (void)setCurrentDate:(NSDate *)currentDate{
    if (!currentDate) {
        currentDate = self.datePicker.minimumDate;
    }
    self.datePicker.date = currentDate;
    [self datePickerValueChanged:self.datePicker];
}
- (NSDate *)currentDate{
    return self.datePicker.date;
}

- (void)cancelPicker:(UIView *) view
{
    //包含视图再设置取消
    if (![view viewWithTag:11108]) {
        return;
    }
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self);
            make.top.equalTo(self.bottom);
            make.height.equalTo(kContentHeight);
        }];
        
        [self layoutIfNeeded];
    }
    completion:^(BOOL finished){
        
        [self removeFromSuperview];
                         
    }];
}

-(void)btnCancelClick
{
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(pickerViewCancel)]) {
        [self.delegate pickerViewCancel];
    }else{
        [self cancelPicker:self.superview];
    }
}

-(void)btnOKClick
{
    if ([_datePicker.minimumDate compare:_datePicker.date] == NSOrderedDescending) {
        self.currentDate = self.datePicker.minimumDate;
//        self.datePicker.date = _datePicker.minimumDate;
    }
    
    NSString *date = [NSDate formatDate:self.datePicker.date format:[self getFormat]];
    
    [self.delegate pickerViewOK:date];
    [self cancelPicker:self.superview];
}

- (void)tapBackGround:(UITapGestureRecognizer *)paramSender
{
//    [self.delegate pickerViewCancel];
    [self cancelPicker:self.superview];
}

-(void)datePickerValueChanged:(id)sender
{
    NSDate *selected = [self.datePicker date];
    NSString *date = [NSDate formatDate:self.datePicker.date format:[self getFormat]];
    NSLog(@"date: %@", selected);
    
    if (self.isShowTitle) {
        self.titleLabel.text = date;
    }
}

- (NSString *)getFormat
{
    NSString *str = nil;
    if (self.datePickerMode == UIDatePickerModeDateAndTime) {
        str = @"yyyy-MM-dd HH:mm";
    }else if(self.datePickerMode == UIDatePickerModeDate){
        str = @"yyyy-MM-dd";
    }else if(self.datePickerMode == UIDatePickerModeTime){
        str = @"HH:mm";
    }else{
        str = nil;
    }
    return str;
}
@end
