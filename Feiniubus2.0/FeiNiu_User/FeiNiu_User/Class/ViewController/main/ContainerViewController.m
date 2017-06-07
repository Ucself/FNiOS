//
//  ContainerViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/10.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ContainerViewController.h"
#import <FNUIView/UINavigationController+FDFullscreenPopGesture.h>

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fd_interactivePopDisabled = YES;
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Me" bundle:nil];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
    self.menuViewController = [[UINavigationController alloc]initWithRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"MainMenuViewController"]];
}
@end
