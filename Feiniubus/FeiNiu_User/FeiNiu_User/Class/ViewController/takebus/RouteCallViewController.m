//
//  RouteCallViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "RouteCallViewController.h"

@interface RouteCallViewController ()

@end

@implementation RouteCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(0, 0, 70, 44);
    [btnRight addTarget:self action:@selector(cancelRoute) forControlEvents:UIControlEventTouchUpInside];
    btnRight.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [btnRight setTitle:@"取消订单" forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = item;
}
- (void)cancelRoute
{
    
}

@end
