//
//  CustomPickerCarView.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/9/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CustomPickerCarView.h"


#define  kContentHeight    260

@interface CustomPickerCarView()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic, strong) UIPickerView *carPicker;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, strong) NSArray *dataSourceArray;
@property(nonatomic, assign) NSUInteger seatIndex;
@property(nonatomic, assign) NSUInteger levelIndex;
@property(nonatomic, assign) NSUInteger amountIndex;
@end
@implementation CustomPickerCarView

-(instancetype)initWithFrame:(CGRect)frame dataSourceArray:(NSArray*)dataSourceArray seatIndex:(NSUInteger)seatIndex levelIndex:(NSUInteger)levelIndex amountIndex:(NSUInteger)amountIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
        [self addGestureRecognizer:gesture];
        //数据源
        self.dataSourceArray = dataSourceArray;
        _seatIndex       = seatIndex;
        _levelIndex      = levelIndex;
        _amountIndex     = amountIndex;
        self.isShowTitle = NO;

        [self iniUI];
        //设置协议
        _carPicker.delegate = self;
        _carPicker.dataSource = self;
        
    }
    
    return self;
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
    
    _carPicker = [[UIPickerView alloc] init];
    [bgView addSubview:_carPicker];
    [_carPicker setBackgroundColor:[UIColor whiteColor]];
    
    [_carPicker makeConstraints:^(MASConstraintMaker *make) {
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
    [btnOk setTintColor:UIColorFromRGB(0x06C1AE)];
    [btnOk addTarget:self action:@selector(btnOKClick) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btnOk];
    
    [btnOk makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_contentView.right).offset(-10);
        make.top.equalTo(_contentView).offset(2);
        make.width.equalTo(40);
        make.height.equalTo(40);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel setTextColor:UIColorFromRGB(0x06c1ae)];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_contentView addSubview:_titleLabel];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btnOk.left).offset(-10);
        make.left.equalTo(btnCancel.right).offset(10);
        make.top.equalTo(_contentView);
        make.height.equalTo(40);
    }];
    _lineImageView = [[UIImageView alloc]init];
    _lineImageView.backgroundColor = UIColorFromRGB(0x06c1ae);
    [_contentView addSubview:_lineImageView];
    [_lineImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.top.equalTo(_contentView);
        make.height.equalTo(3);
    }];
    
    [self getTitleText:0];
}
-(void)setIsShowTitle:(BOOL)isShowTitle
{
    _isShowTitle = isShowTitle;
    if (isShowTitle) {
        [self getTitleText:0];
    }
}

- (void)getTitleText:(int)type
{
    switch (type) {
        case 0:
            
            break;
        case 1:
            if (self.seatIndex > 0) {
                
                self.seatIndex = self.seatIndex - 1;
            }

            break;
        case 2:
            if (self.amountIndex > 0) {
                
                self.amountIndex = self.amountIndex - 1;
            }
            break;
        default:
            break;
    }
    
    NSArray *seatArray = _dataSourceArray[0];
    NSString *seatStr = seatArray[self.seatIndex];
    
    NSArray *levelArray = _dataSourceArray[1];
    NSString *levelStr = levelArray[self.levelIndex];
    
    NSArray *amountArray = _dataSourceArray[2];
    NSString *amountStr = amountArray[self.amountIndex];
    if (self.isShowTitle) {
        _titleLabel.text = [NSString stringWithFormat:@"%@,%@,%@",seatStr,levelStr,amountStr];
    }
}
- (void)showInView:(UIView *) view
{
    self.parentView = view;
    self.tag = 11106;
    if ([self.parentView  viewWithTag:11106]) {
        return;
    }
    
    [self.parentView  addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.parentView );
    }];
    [self.parentView  layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self.parentView );
            make.top.equalTo(self.parentView .bottom).offset(-kContentHeight);
            make.height.equalTo(kContentHeight);
        }];
        [self.parentView  layoutIfNeeded];

        [_carPicker selectRow:_seatIndex   inComponent:0 animated:NO];
        [_carPicker selectRow:_levelIndex  inComponent:1 animated:NO];
        [_carPicker selectRow:_amountIndex inComponent:2 animated:NO];
    }];
    
}

- (void)cancelPicker:(UIView *) view
{
    //如果传入的视图不是父视图
    if (![self.parentView isEqual:view]) {
        return;
    }
    //包含视图再设置取消
    if (![self.parentView  viewWithTag:11106]) {
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
        
        
    }completion:^(BOOL finished){
        [self removeFromSuperview];
                         
    }];
}

-(void)btnCancelClick
{
    //取消视图
    [self cancelPicker:self.parentView];
    //协议返回
    if ([self.delegate respondsToSelector:@selector(pickerCarViewCancel)]) {
        [self.delegate pickerCarViewCancel];
    }
    
}

-(void)btnOKClick
{
    if([self.delegate respondsToSelector:@selector(pickerCarViewOKSeatIndex:levelIndex:amountIndex:title:pickerCarView:)]) {
        
        [self.delegate
         pickerCarViewOKSeatIndex:self.seatIndex
         levelIndex:self.levelIndex
         amountIndex:self.amountIndex
         title:self.titleLabel.text
         pickerCarView:self];
    }
    //取消视图
    [self cancelPicker:self.parentView];
}

- (void)tapBackGround:(UITapGestureRecognizer *)paramSender
{
    [self btnCancelClick];
}

#pragma mark --- UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSArray *array = self.dataSourceArray[component];
    
    if ([array isKindOfClass:[NSArray class]]) {
        
        NSString *str = array[row];
        
        return str;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"da");
    
    int i = 0;
    
    if (component == 0) {
        
        self.seatIndex = row + 1;
        i = 1;
        
    }else if (component == 1){
        
        self.levelIndex = row;
        
        self.carTypeAndLevelId = (int)row;
    
    }else{
        
        self.amountIndex = row + 1;
        
        i = 2;
    }
    
    [self getTitleText:i];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45.f;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        
        return self.frame.size.width/3 - 40;//left width
        
    }else if (component == 1){
        
        return self.frame.size.width/3 + 50;//middle width
        
    }else{
        
        return self.frame.size.width/3 - 40;//right width
    }
}
#pragma mark --- UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *array = _dataSourceArray[component];
    
    if ([array isKindOfClass:[NSArray class]]) {
        
        return array.count;
        
    }
    
    return 0;
}

@end
