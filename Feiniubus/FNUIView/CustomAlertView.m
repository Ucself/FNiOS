//
//  CustomAlertView.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/28.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CustomAlertView.h"

#define  kContentHeight    245

@interface CustomAlertView()<UITextFieldDelegate>

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, strong) NSString *alertName;
@property(nonatomic, strong) NSString *alertInputContent;
@property(nonatomic, strong) NSString *alertUnit;
@property(nonatomic, assign) UIKeyboardType keyboardType;
@property(nonatomic, assign) int useType;

@end

@implementation CustomAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame alertName:(NSString*)alertName alertInputContent:(NSString*)alertInputContent alertUnit:(NSString*)alertUnit keyboardType:(UIKeyboardType)keyboardType  useType:(int)useType
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        self.alertName = alertName;
        self.alertInputContent = alertInputContent;
        self.alertUnit = alertUnit;
        self.keyboardType = keyboardType;
        self.useType = useType;
        [self initUI];
    }
    
    return self;
}
//加载页面
-(void)initUI
{
    //设置整个弹出框布局
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    [self addSubview:_contentView];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    _contentView.layer.cornerRadius = 5.f;
    _contentView.clipsToBounds = YES;
    //添加标题
    UILabel *titleLabel = [[UILabel alloc] init];
    [_contentView addSubview:titleLabel];
    titleLabel.text =_alertName ? _alertName : @"";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.f];
    titleLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.top.equalTo(_contentView);
        make.height.equalTo(44);
    }];
    
    //添加取消按钮
    UIButton *cancelButton = [[UIButton alloc] init];
    [_contentView addSubview:cancelButton];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.bottom.equalTo(_contentView.bottom);
        make.right.equalTo(_contentView.centerX);
        make.height.equalTo(44);
    }];
    
    CALayer *topBorder = [CALayer layer];//设置一个上边框
    topBorder.frame = CGRectMake(0.0f, 0.0f, 135.f, 1.0f);
    topBorder.backgroundColor = UIColorFromRGB(0xE5E5E5).CGColor;
    [cancelButton.layer addSublayer:topBorder];
    CALayer *middleBorder = [CALayer layer];//设置一个中边框
    middleBorder.frame = CGRectMake(135.f, 0.0f, 1.f, 44.f);
    middleBorder.backgroundColor = UIColorFromRGB(0xE5E5E5).CGColor;
    [cancelButton.layer addSublayer:topBorder];
    [cancelButton.layer addSublayer:middleBorder];
    [cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside]; //点击事件
    //添加确认按钮
    UIButton *okButton = [[UIButton alloc] init];
    [_contentView addSubview:okButton];
    [okButton setTitle:@"确认" forState:UIControlStateNormal];
    [okButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [okButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_contentView);
        make.bottom.equalTo(_contentView.bottom);
        make.left.equalTo(_contentView.centerX);
        make.height.equalTo(44);
    }];
    CALayer *topBorder2 = [CALayer layer];//设置一个上边框
    topBorder2.frame = CGRectMake(0.0f, 0.0f, 135.f, 1.0f);
    topBorder2.backgroundColor = UIColorFromRGB(0xE5E5E5).CGColor;
    [okButton.layer addSublayer:topBorder2];
    [okButton addTarget:self action:@selector(okClick:) forControlEvents:UIControlEventTouchUpInside]; //点击事件
    //添加中部的输入框
    _inputDate = [[UITextField alloc] init];
    [_contentView addSubview:_inputDate];
    _inputDate.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _inputDate.layer.borderWidth = 1.0f;
    _inputDate.textAlignment = NSTextAlignmentCenter;
    _inputDate.font = [UIFont boldSystemFontOfSize:17.f];
    _inputDate.font = [UIFont systemFontOfSize:17.f];
    _inputDate.text = _alertInputContent;
    _inputDate.keyboardType = _keyboardType;
    _inputDate.returnKeyType = UIReturnKeyDone;
    _inputDate.delegate = self;
    _inputDate.tag = 1001;
    [_inputDate addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_inputDate makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_contentView);
        make.centerY.equalTo(_contentView);
        make.width.equalTo(240);
        make.height.equalTo(49);
    }];
    //添加单位视图
    UILabel *unitLabel = [[UILabel alloc] init];
    [_contentView addSubview:unitLabel];
    unitLabel.textAlignment = NSTextAlignmentRight;
    unitLabel.font = [UIFont systemFontOfSize:17.f];
    unitLabel.text = _alertUnit;
    unitLabel.textColor = UIColorFromRGB(0xFF5A37);
    [unitLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_inputDate.right).offset(-15);
        make.centerY.equalTo(_contentView);
        make.height.equalTo(40);
        make.width.equalTo(40);
    }];
}

#pragma mark --- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_inputDate) {
        [_inputDate resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    switch (textField.tag) {
        case 1001:
        {
            if (textField.text.length > _limitCount && _limitCount !=0) {
                textField.text = [textField.text substringToIndex:_limitCount];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark --- delegate
-(void)cancelClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(customAlertViewCancel)]) {
        [self.delegate customAlertViewCancel];
    }
    [self cancelPicker:self.parentView];
}

-(void)okClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(customAlertViewOK:useType:)] && _inputDate) {
        [self.delegate customAlertViewOK:_inputDate.text useType:_useType];
    }
    [self cancelPicker:self.parentView];
}
#pragma mark ---
- (void)showInView:(UIView *) view
{
//    [[UIApplication sharedApplication] keyWindow];
    self.parentView = view;
    self.tag = 11105;
    if ([self.parentView  viewWithTag:11105]) {
        return;
    }
    
    [self.parentView  addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.parentView);
    }];
    
    [self.parentView  layoutIfNeeded];
    
    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(270);
        make.height.equalTo(176);
        make.centerX.equalTo(self.centerX);
        make.bottom.equalTo(self.parentView.top).priorityLow();
    }];
    
    [self.parentView  layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{

        [_contentView makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bottom).offset(-[UIScreen mainScreen].bounds.size.height/2 - 10);
        }];
        
        [self.parentView  layoutIfNeeded];
    }];
    
}

- (void)cancelPicker:(UIView *) view
{
    //如果传入的视图不是父视图
    if (![self.parentView isEqual:view]) {
        return;
    }
    //包含视图再设置取消
    if (![self.parentView  viewWithTag:11105]) {
        return;
    }
    [UIView animateWithDuration:0.0 animations:^{
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

@end
