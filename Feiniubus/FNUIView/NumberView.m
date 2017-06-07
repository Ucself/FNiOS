//
//  NumberView.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "NumberView.h"

@interface NumberView ()
{
    int number;
}

@property(nonatomic, strong) UITextField *textNumber;
@property(nonatomic, strong) UIButton *btnAdd;
@property(nonatomic, strong) UIButton *btnSub;
@end

@implementation NumberView



-(instancetype)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        number = 1;
        
        [self initUI];
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.6;
        self.layer.borderColor = [UIColorFromRGB(0xcdcdcd) CGColor];
    }
    
    return self;
}

-(void)initUI
{
    _textNumber = [[UITextField alloc] init];
    _textNumber.textAlignment = NSTextAlignmentCenter;
    _textNumber.text = [NSString stringWithFormat:@"%d", number];
    _textNumber.keyboardType = UIKeyboardTypeNumberPad;
    [self addSubview:_textNumber];
    
    _btnSub = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnSub.backgroundColor = [UIColor lightGrayColor];
    [_btnSub setTitle:@"-" forState:UIControlStateNormal];
    [_btnSub addTarget:self action:@selector(btnSubClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnSub];
    
    _btnAdd = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnAdd.backgroundColor = UIColor_DefGreen;
    [_btnAdd setTitle:@"+" forState:UIControlStateNormal];
    [_btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnAdd];
    
    
    [_btnSub makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self.height);
    }];
    
    [_textNumber makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_btnAdd makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right);
        make.top.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self.height);
    }];
}

-(void)btnAddClick
{
    if (number > 30) {
        number = 20;
    }
    else {
        number ++;
    }
    self.textNumber.text = [NSString stringWithFormat:@"%d", number];
}

-(void)btnSubClick
{
    if (number == 1) {
        number = 1;
    }
    else {
        number -- ;
    }
    self.textNumber.text = [NSString stringWithFormat:@"%d", number];
}
@end
