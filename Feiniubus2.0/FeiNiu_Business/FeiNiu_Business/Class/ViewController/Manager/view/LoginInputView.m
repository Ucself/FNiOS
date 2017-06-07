//
//  LoginInputView.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/30.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "LoginInputView.h"

@interface LoginInputView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIImage *imgNormal;
@property (nonatomic, strong) UIImage *imgHigh;

@end

@implementation LoginInputView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initControls];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initControls];
    }
    return self;
}

-(NSString *)text
{
    return self.textField.text;
}

-(void)setText:(NSString *)text
{
    self.textField.text = text;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    self.textField.placeholder = placeholder;
}


- (void)initControls
{
    self.layer.borderWidth = 0.7;
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _limit = 20;
    _rightViewAlway = YES;
    
    _imgView = [[UIImageView alloc] init];
    [self addSubview:_imgView];
    
    [_imgView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(5);
        make.centerY.equalTo(self);
        make.width.equalTo(25);
        make.height.equalTo(25);
    }];
    
    _textField = [[UITextField alloc] init];
    //_textField.backgroundColor = [UIColor lightGrayColor];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.delegate = self;
    _textField.font = [UIFont systemFontOfSize:14];
    [self addSubview:_textField];
    
    [_textField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgView.right).offset(5);
        make.centerY.equalTo(self);
        make.height.equalTo(30);
        make.right.equalTo(self.right).offset(-5);

    }];
    
}


-(void)setLeftImageNormal:(UIImage *)imageNormal imageHigh:(UIImage*)imageHigh
{
    self.imgNormal = imageNormal;
    self.imgHigh = imageHigh;
    self.imgView.image = imageNormal;
}


-(void)setRightButton:(UIButton*)button width:(CGFloat)width hight:(CGFloat)hight
{
    _rightView = button;
    [self addSubview:_rightView];

    [_rightView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(-10);
        make.centerY.equalTo(self);
        make.width.equalTo(width);
        make.height.equalTo(hight);
    }];
    
    [_textField remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgView.right).offset(5);
        make.centerY.equalTo(self);
        make.height.equalTo(30);
        make.right.equalTo(_rightView.left).offset(-10);
    }];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.layer.borderColor = UIColor_DefOrange.CGColor;
    self.imgView.image = self.imgHigh;

    self.rightView.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgView.image = self.imgNormal;
    
    if (!self.rightViewAlway) {
        self.rightView.hidden = YES;
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField.text.length > _limit)
        return NO;
    
    return YES;
}

-(void)resignFirstResponder
{
    [self.textField resignFirstResponder];
}

-(void)becomeFirstResponder
{
    [self.textField becomeFirstResponder];
}
@end
