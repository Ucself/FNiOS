//
//  RatingViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "RatingViewController.h"
#import <FNUIView/RatingBar.h>
#import <FNUIView/PlaceHolderTextView.h>

@interface RatingViewController () <RatingBarDelegate>

@property (nonatomic, strong) RatingBar *ratingBarCar;
@property (nonatomic, strong) RatingBar *ratingBarDriver;
@property (nonatomic, strong) PlaceHolderTextView *textView;
@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI
{
    UIButton *btnbk = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnbk addTarget:self action:@selector(onbtnbkClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnbk];
    
    [btnbk makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.text =@"车辆评分";
    [self.view addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(84);
        make.centerX.equalTo(self.view);
        make.width.equalTo(100);
        make.height.equalTo(20);
    }];
    
    _ratingBarCar = [[RatingBar alloc] init];
    //ratingBar.isIndicator = YES;//指示器，就不能滑动了，只显示评分结果
    [_ratingBarCar setImageDeselected:@"star_nor" halfSelected:nil fullSelected:@"star_press" andDelegate:self];
    [self.view addSubview:_ratingBarCar];
    
    [_ratingBarCar makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(210);
        make.height.equalTo(35);
    }];
    
    label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.text =@"司机评分";
    [self.view addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ratingBarCar.bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(100);
        make.height.equalTo(20);
    }];
    
    _ratingBarDriver = [[RatingBar alloc] init];
    //ratingBar.isIndicator = YES;//指示器，就不能滑动了，只显示评分结果
    [_ratingBarDriver setImageDeselected:@"star_nor" halfSelected:nil fullSelected:@"star_press" andDelegate:self];
    [self.view addSubview:_ratingBarDriver];
    
    [_ratingBarDriver makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(210);
        make.height.equalTo(35);
    }];
    
    _textView = [[PlaceHolderTextView alloc] init];
    _textView.placeHolder = @"请输入您要表达的内容, 非常感谢!";
    _textView.numberLimit = 100;
    [self.view addSubview:_textView];
    
    [_textView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(10);
        make.top.equalTo(_ratingBarDriver.bottom).offset(20);
        make.right.equalTo(-10);
        make.height.equalTo(90);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView.bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(100);
        make.height.equalTo(35);
    }];
}

-(void)onbtnbkClick
{
    [_textView resignFirstResponder];
}

#pragma ratingbar delegate
- (void)ratingBar:(RatingBar*)ratingBar newRating:(float)newRating
{
    
}
@end
