//
//  SelectView.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "SelectView.h"
#import "UIImage+bundle.h"
#import <QuartzCore/QuartzCore.h>

#define  kContentHeight      132
#define  FontColor           [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1]
#define  CancelFontColor     [UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1]
#define  LineColor           [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1]

@interface SelectView ()
{
   
}
@property(nonatomic, strong) UIView *contentView;

@end


@implementation SelectView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self iniUI];
        
        self.backgroundColor = UITranslucentBKColor;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
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
    
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.font = [UIFont systemFontOfSize:17];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_labelTitle];
    
    [_labelTitle makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.top.equalTo(_contentView);
        make.centerX.equalTo(_contentView);
        make.height.equalTo(0);//没有标题
    }];
    
    _btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btn1 setTitleColor:FontColor forState:UIControlStateNormal];
    _btn1.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btn1 addTarget:self action:@selector(onSelect1) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btn1];
    
    [_btn1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.height.equalTo(kContentHeight/3);
        make.top.equalTo(_labelTitle.bottom);
    }];
    
    _btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btn2 setTitleColor:FontColor forState:UIControlStateNormal];
    _btn2.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btn2 addTarget:self action:@selector(onSelect2) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btn2];
    
    [_btn2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.height.equalTo(kContentHeight/3);
        make.top.equalTo(_btn1.bottom);
    }];
    
    
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [btnClose setTitleColor:CancelFontColor forState:UIControlStateNormal];
    btnClose.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnClose setTitle:@"取消" forState:UIControlStateNormal];
    [_contentView addSubview:btnClose];
    
    [btnClose makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.height.equalTo(kContentHeight/3);
        make.top.equalTo(_btn2.bottom);
    }];

    //第一根线
    UIView *line = [UIView new];
    line.backgroundColor = LineColor;
    [_contentView addSubview:line];
    
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(1);
        make.top.equalTo(_btn2.top);
    }];
    //第二个根线
    UIView *line2 = [UIView new];
    line2.backgroundColor = LineColor;
    [_contentView addSubview:line2];
    
    [line2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(1);
        make.top.equalTo(btnClose.top);
    }];
    
    if (self.type == SelectType_Image) {
        //_labelTitle.text = @"选择头像";
        [_btn1 setTitle:@"拍照" forState:UIControlStateNormal];
        [_btn2 setTitle:@"本地图片" forState:UIControlStateNormal];
    }
    else {
        //_labelTitle.text = @"选择性别";
        [_btn1 setTitle:@"男" forState:UIControlStateNormal];
        [_btn2 setTitle:@"女" forState:UIControlStateNormal];
    }
    
}



- (void)showInView:(UIView *) view
{
    self.tag = 11109;
    
    if ([view viewWithTag:11109]) {
        return;
    }
    
    [view addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(view);
            make.top.equalTo(view.bottom).offset(-kContentHeight);
            make.height.equalTo(kContentHeight);
        }];
        
        [view layoutIfNeeded];
    }];
}

- (void)cancelSelect:(UIView *) view
{
    //包含视图再设置取消
    if (![view viewWithTag:11109]) {
        return;
    }
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self);
            make.top.equalTo(self.bottom);
            make.height.equalTo(kContentHeight);
        }];

        
        [view layoutIfNeeded];
    }
    completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

-(void)btnCloseClick
{
    [self.delegate selectViewCancel];
}

-(void)onSelect1
{
    [self.delegate selectView:0];
}

-(void)onSelect2
{
    [self.delegate selectView:1];
}

- (void)tapBackGround:(UITapGestureRecognizer *)paramSender
{
    [self.delegate selectViewCancel];
}
@end
