//
//  SharePanelViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/5/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "SharePanelView.h"


@interface SharePanelView ()


@end

@implementation SharePanelView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)initView
{
    self.panel = [[FXBlurView alloc] init];
    self.panel.dynamic = NO;
    self.panel.blurRadius = 40;
    self.panel.tintColor = UIColorFromRGB(0x26547b);
    [self addSubview:self.panel];
    
    [self.panel makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UILabel *label = [UILabel new];
    label.text = @"分享到";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.panel addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(100);
        make.centerX.equalTo(self.panel);
        make.width.equalTo(100);
        make.height.equalTo(24);
    }];
    
    //第一行
    UIView *btnWx = [self buttonView:@"微信" image:[UIImage imageNamed:@"wechat_icon"] action:@selector(btnWeixinClick)];
    [self.panel addSubview:btnWx];
    UIView *btnCircles = [self buttonView:@"朋友圈" image:[UIImage imageNamed:@"friend_icon"] action:@selector(btnCirclesClick)];
    [self.panel addSubview:btnCircles];
    UIView *btnSina = [self buttonView:@"新浪微博" image:[UIImage imageNamed:@"weibo_icon"] action:@selector(btnSinaClick)];
    [self.panel addSubview:btnSina];
    
    [btnWx makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.bottom).offset(30);
        make.left.equalTo(self.panel).offset(20);
        make.height.equalTo(100);
        make.width.equalTo(btnCircles);
    }];
    
    [btnCircles makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnWx.top);
        make.left.equalTo(btnWx.right);
        make.height.equalTo(100);
        make.width.equalTo(btnSina);
    }];
    
    [btnSina makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnWx.top);
        make.left.equalTo(btnCircles.right);
        make.right.equalTo(self.panel.right).offset(-20);
        make.height.equalTo(100);
        make.width.equalTo(btnWx);
    }];
    
    //第二行
    UIView *btnQQ = [self buttonView:@"QQ" image:[UIImage imageNamed:@"qq_icon"] action:@selector(btnQQClick)];
    [self.panel addSubview:btnQQ];
    UIView *btnKongjian = [self buttonView:@"QQ空间" image:[UIImage imageNamed:@"kongjian_icon"] action:@selector(btnKongjianClick)];
    [self.panel addSubview:btnKongjian];
//    UIView *btnTencent = [self buttonView:@"腾讯微博" image:[UIImage imageNamed:@"txwb_icon"] action:@selector(btnTencentClick)];
    UIView *btnTencent = [[UIView alloc] init];
    [self.panel addSubview:btnTencent];
    
    [btnQQ makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnSina.bottom).offset(20);
        make.left.equalTo(self.panel).offset(20);
        make.height.equalTo(100);
        make.width.equalTo(btnKongjian);
    }];
    
    [btnKongjian makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnQQ.top);
        make.left.equalTo(btnQQ.right);
        make.height.equalTo(100);
        make.width.equalTo(btnTencent);
    }];
    
    [btnTencent makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnQQ.top);
        make.left.equalTo(btnKongjian.right);
        make.right.equalTo(self.panel.right).offset(-20);
        make.height.equalTo(100);
        make.width.equalTo(btnQQ);
    }];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"close_white"];
    [btnClose setImage:image forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:btnClose];
    
    [btnClose makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.panel);
        make.bottom.equalTo(self.panel.bottom).offset(-20);
        make.height.equalTo(image.size.height);
        make.width.equalTo(image.size.width);
    }];

}

-(UIView*)buttonView:(NSString*)title image:(UIImage*)image action:(SEL)action
{
    UIView *view = [[UIView alloc] init];
    //view.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [view addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view);
        make.height.equalTo(20);
        make.width.equalTo(view);
        make.centerX.equalTo(view);
    }];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.width.equalTo(view);
        make.top.equalTo(view);
        make.bottom.equalTo(label).offset(-10);
    }];
    
    return view;
}

-(void)btnWeixinClick
{
    if (self.clickAction) {
        self.clickAction(Action_Wx);
    }
}

-(void)btnCirclesClick
{
    if (self.clickAction) {
        self.clickAction(Action_Circles);
    }
}

-(void)btnSinaClick
{
    if (self.clickAction) {
        self.clickAction(Action_Sina);
    }
}

-(void)btnQQClick
{

    if (self.clickAction) {
        self.clickAction(Action_QQ);
    }
}

-(void)btnKongjianClick
{
    if (self.clickAction) {
        self.clickAction(Action_Kongjian);
    }
}

-(void)btnTencentClick
{
    return;
    if (self.clickAction) {
        self.clickAction(Action_Tencent);
    }
    
}

-(void)btnCloseClick
{
    if (self.clickAction) {
        self.clickAction(Action_Close);
    }
}
@end
