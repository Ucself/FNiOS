//
//  RefundTipsView.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "RefundTipsView.h"

@interface RefundTipsView ()

@property (strong, nonatomic) UIView *viewContent;
@property (strong, nonatomic) UILabel *labelTitle;
@property (copy, nonatomic) doneBlock block;
@end

@implementation RefundTipsView


-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initControls];
        self.backgroundColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.4];
    }
    return self;
}

-(void)initControls
{
    _viewContent = [UIView new];
    _viewContent.backgroundColor = [UIColor whiteColor];
    _viewContent.layer.cornerRadius = 5;
    [self addSubview:_viewContent];
    
    [_viewContent makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-20);
        make.height.equalTo(190);
        make.width.equalTo(250);
    }];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"succeed_icon"]];
    [_viewContent addSubview:img];
    
    [img makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(15);
        make.centerX.equalTo(_viewContent);
        make.width.equalTo(30);
        make.height.equalTo(30);
    }];
    
    _labelTitle = [UILabel new];
    _labelTitle.textColor = [UIColor darkTextColor];
    _labelTitle.font = [UIFont boldSystemFontOfSize:17];
    _labelTitle.text = @"您的车票已退票成功!";
    [_viewContent addSubview:_labelTitle];
    
    [_labelTitle makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(img.bottom).offset(10);
        make.centerX.equalTo(_viewContent);

    }];
    
    UILabel *labelDesc = [UILabel new];
    labelDesc.textColor = [UIColor lightGrayColor];
    labelDesc.font = [UIFont boldSystemFontOfSize:14];
    labelDesc.text = @"您的车费将在3-7个工作日退还到您的帐户．";
    labelDesc.textAlignment = NSTextAlignmentCenter;
    labelDesc.numberOfLines = 0;
    [_viewContent addSubview:labelDesc];
    
    [labelDesc makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_labelTitle.bottom).offset(10);
        make.centerX.equalTo(_viewContent);
        make.width.equalTo(_viewContent.width).offset(-30);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:UIColor_DefOrange];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnOKClick) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    [_viewContent addSubview:btn];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelDesc.bottom).offset(10);
        make.centerX.equalTo(self);
        make.height.equalTo(40);
        make.width.equalTo(180);
        
    }];
}

-(void)btnOKClick
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;

    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.block) {
            self.block();
        }
    }];
}


+(void)showInfoView:(UIView*)view tips:(NSString*)tips;
{
    RefundTipsView *tipsView = [[RefundTipsView alloc] init];
    tipsView.labelTitle.text = tips;
    [view addSubview:tipsView];
    
    [tipsView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    tipsView.viewContent.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.2 animations:^{
        tipsView.viewContent.transform = CGAffineTransformMakeScale(1.1, 1.1);
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 animations:^{
            tipsView.viewContent.transform = CGAffineTransformIdentity;
        }];
    }];
}

+(void)showInfoView:(UIView*)view tips:(NSString*)tips done:(doneBlock)doneBlock
{
    RefundTipsView *tipsView = [[RefundTipsView alloc] init];
    tipsView.labelTitle.text = tips;
    tipsView.block = doneBlock;
    [view addSubview:tipsView];
    
    [tipsView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    tipsView.viewContent.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.2 animations:^{
        tipsView.viewContent.transform = CGAffineTransformMakeScale(1.1, 1.1);
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 animations:^{
            tipsView.viewContent.transform = CGAffineTransformIdentity;
        }];
    }];
}
@end
