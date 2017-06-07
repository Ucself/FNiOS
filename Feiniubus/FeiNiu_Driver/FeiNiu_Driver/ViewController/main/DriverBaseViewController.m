//
//  DriverBaseViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/9/24.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "DriverBaseViewController.h"

@interface DriverBaseViewController ()

@end

@implementation DriverBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarSelf];
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

#pragma mark ---
-(void)setNavigationBarSelf
{
//    self.navigationItem.leftBarButtonItem = nil;
    
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xFC5338)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
//    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"backbtn"]];
//    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backbtn"]];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = backItem;
    
}
#pragma mark --- 数据请求返回通知

-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
}
-(void)httpRequestFailed:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSError *error = [dict objectForKey:@"error"];
    int type = [[dict objectForKey:@"type"] intValue];
    ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:type];
    //如果是鉴权失败不提示
    if (result.resultCode == 401 || result.resultCode == 403)
    {
        
        DBG_MSG(@"httpRequestFailed: resultcode= %d", result.resultCode);
    }
    else
    {
        [super httpRequestFinished:notification];
    }
}
@end
