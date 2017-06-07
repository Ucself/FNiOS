//
//  ContainerViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/10.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Me" bundle:nil];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainnavicontroller"];
    self.menuViewController = [[UINavigationController alloc]initWithRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"MainMenuViewController"]];
}

//- (IBAction)btnMenuClick:(id)sender {
//    
//    [self presentMenuViewController];
//    
//}



@end
