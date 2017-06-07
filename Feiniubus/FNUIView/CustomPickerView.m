//
//  DatePickerView.m
//  XRUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 deshan.com. All rights reserved.
//

#import "CustomPickerView.h"

#define  kContentHeight    260

@interface CustomPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic, strong) UIPickerView *datePicker;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, strong) NSArray *dataSourceArray;
@property(nonatomic, assign) int selectedIndex;
@property(nonatomic, assign) int useType;

@end

@implementation CustomPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame dataSourceArray:(NSArray*)dataSourceArray useType:(int)useType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
        [self addGestureRecognizer:gesture];
        //数据源
        self.dataSourceArray = dataSourceArray;
        self.useType = useType;
        [self iniUI];
        //设置协议
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    
    return self;
}

- (void)setDefaultValue: (NSObject *)value {
    int k;
    NSString *str;
    NSDictionary *dict;
    //如果是字符串
    if ([value isKindOfClass:[NSString class]]) {
        for(k = 0;k < _dataSourceArray.count;k ++) {
            str = (NSString *)_dataSourceArray[k];
            if([str isEqualToString: (NSString *)value]) {
                _selectedIndex = k;
                return;
            }
        }
        _selectedIndex = 0;
        return;
    }
    //如果是字典
    if ([value isKindOfClass:[NSDictionary class]]) {
        str = (NSString *)[(NSDictionary *)value objectForKey: @"name"];
        for(k = 0;k < _dataSourceArray.count;k ++) {
            dict = (NSDictionary *)_dataSourceArray[k];
            if([(NSString *)[dict objectForKey: @"name"] isEqualToString: str]) {
                _selectedIndex = k;
                return;
            }
        }
        _selectedIndex = 0;
        return;
    }
    _selectedIndex = 0;
}

-(void)iniUI
{
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [self addSubview:_contentView];
    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.width.equalTo(self);
        make.top.equalTo(self.bottom);
        make.height.equalTo(kContentHeight);
    }];
    
    //添加视图
    UIView *bgView = [[UIView alloc] init];
    [_contentView addSubview:bgView];
    [bgView setBackgroundColor:[UIColor redColor]];
    [bgView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(216);
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.bottom.equalTo(_contentView);
    }];
    
    _datePicker = [[UIPickerView alloc] init];
    [bgView addSubview:_datePicker];
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    [_datePicker makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView);
        make.left.equalTo(bgView);
        make.right.equalTo(bgView);
        make.bottom.equalTo(bgView);
    }];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTintColor:UIColorFromRGB(0xB5B8BB)];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btnCancel];
    
    [btnCancel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView.left).offset(10);
        make.top.equalTo(_contentView.top).offset(2);
        make.width.equalTo(40);
        make.height.equalTo(40);
    }];
    
    UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnOk setTitle:@"确定" forState:UIControlStateNormal];
    [btnOk setTintColor:UIColorFromRGB(0xFD5936)];
    [btnOk addTarget:self action:@selector(btnOKClick) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btnOk];
    
    [btnOk makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_contentView.right).offset(-10);
        make.top.equalTo(_contentView).offset(2);
        make.width.equalTo(40);
        make.height.equalTo(40);
    }];
    
    //上部的线条
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGB(0xFD5936);
    [_contentView addSubview:lineView];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.top.equalTo(_contentView);
        make.height.equalTo(3);
    }];
}

- (void)showInView:(UIView *) view
{
    self.parentView = view;
    self.tag = 11107;
    if ([self.parentView  viewWithTag:11107]) {
        return;
    }
    
    [self.parentView  addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.parentView );
    }];
    [self.parentView  layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self.parentView );
            make.top.equalTo(self.parentView .bottom).offset(-kContentHeight);
            make.height.equalTo(kContentHeight);
        }];
        
        [self.parentView  layoutIfNeeded];
    }];
    
    [self.datePicker selectRow:_selectedIndex inComponent:0 animated:YES];
}

- (void)cancelPicker:(UIView *) view
{
    //如果传入的视图不是父视图
    if (![self.parentView isEqual:view]) {
        return;
    }
    //包含视图再设置取消
    if (![self.parentView  viewWithTag:11107]) {
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
    //取消视图
    [self cancelPicker:self.parentView];
    //协议返回
    if ([self.delegate respondsToSelector:@selector(pickerViewCancel)]) {
        [self.delegate pickerViewCancel];
    }
    
}

-(void)btnOKClick
{
    if(self.selectedIndex >=0 && [self.delegate respondsToSelector:@selector(pickerViewOK:useType:)])
    {
        [self.delegate pickerViewOK:self.selectedIndex useType:_useType];
    }
    //取消视图
    [self cancelPicker:self.parentView];
}

- (void)tapBackGround:(UITapGestureRecognizer *)paramSender
{
    //暂时不需要取消
    return;
    [self btnCancelClick];
}

#pragma mark --- UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //如果是字符串
    if ([_dataSourceArray[row] isKindOfClass:[NSString class]]) {
        return _dataSourceArray[row];
    }
    //如果是字典
    if ([_dataSourceArray[row] isKindOfClass:[NSDictionary class]] || [_dataSourceArray[row] isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *tempObject = (NSDictionary*)_dataSourceArray[row];
        //名称
        if([tempObject objectForKey:@"name"])
        {
            return [tempObject objectForKey:@"name"];
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedIndex = (int)row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45.f;
}
#pragma mark --- UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _dataSourceArray.count;
}

@end
