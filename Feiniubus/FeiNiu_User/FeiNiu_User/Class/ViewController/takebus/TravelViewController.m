//
//  TravelViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "TravelViewController.h"
#import "CarpoolViewController.h"
#import "EditCharterViewController.h"
#import "CharteredViewController.h"
#import "AirportViewController.h"
@interface TravelViewController ()

@end

@implementation TravelViewController

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

//去拼车
- (IBAction)btnCaroolClick:(id)sender {
    CarpoolViewController *c =  [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolViewController"];
    [self.navigationController pushViewController:c animated:YES];
}

//去包车
- (IBAction)btnCharteredClick:(id)sender {
    EditCharterViewController *vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"EditCharterViewController"];
    CharteredViewController *chartVc = [self.storyboard instantiateViewControllerWithIdentifier:@"CharteredViewController"];
    AirportViewController *airportVc = [self.storyboard instantiateViewControllerWithIdentifier:@"AirportViewController"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[chartVc,airportVc]];
    [vc setPages:array];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
