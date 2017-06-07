//
//  DriverContainerViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/12.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverContainerViewController.h"
#import <FNUIView/UIViewController+REFrostedViewController.h>

@interface DriverContainerViewController ()

@end

@implementation DriverContainerViewController

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
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationControllerIdent"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenuControllerIdent"];
    self.limitMenuViewSize = YES;
    self.minimumMenuViewSize = CGSizeMake(200, deviceHeight);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ---


@end








