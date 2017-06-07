//
//  DriverMainMenuViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/12.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverMainMenuViewController.h"
#import <FNUIView/REFrostedViewController.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>

@interface DriverMainMenuViewController ()

@end

@implementation DriverMainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)menuClick:(id)sender {
    [self.frostedViewController hideMenuViewController];
}


@end
