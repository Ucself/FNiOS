//
//  CarOwnerBaseViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/11/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerBaseViewController.h"

@interface CarOwnerBaseViewController ()

@end

@implementation CarOwnerBaseViewController

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
