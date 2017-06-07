//
//  CarOwnerMainViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/5.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerMainViewController.h"
#import <FNDataModule/EnvPreferences.h>
#import <FNCommon/Constants.h>

@interface CarOwnerMainViewController ()

@end

@implementation CarOwnerMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self initInterface];
    //注册抢单通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushGrabOrder:) name:KNotification_PushGrabOrder object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dealloc
{
    //注销抢单通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_PushGrabOrder object:nil];
}

-(void)awakeFromNib
{
    //初始化界面
    [self initTabController];
    //设置选中
    [self cameraClick:self.cameraBtn];
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

-(void) initInterface
{
    //故事版
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //登录相关控制器
    UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
    //先进入登录进行测试
    [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    return;
    NSString *token = [[EnvPreferences sharedInstance] getToken];
    NSString *userId = [[EnvPreferences sharedInstance] getUserId];
    //查看是否有授权数据，未授权弹出登录窗口
    if (!(token && userId))
    {
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
}

//初始化分类
-(void) initTabController
{
    
    //设置字体
    [[UITabBarItem appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                             forState: UIControlStateNormal];
    //车辆信息
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Vehicle" bundle:nil];
    UINavigationController *vehicleController = [storyboard instantiateInitialViewController];
    
    //司机信息
    storyboard = [UIStoryboard storyboardWithName:@"Driver" bundle:nil];
    UINavigationController *driverController = [storyboard instantiateInitialViewController];
    
    //我要抢单
    storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    UINavigationController *orderController = [storyboard instantiateInitialViewController];
    
    //任务管理
    storyboard = [UIStoryboard storyboardWithName:@"Task" bundle:nil];
    UINavigationController *taskController = [storyboard instantiateInitialViewController];
    
    //个人中心
    storyboard = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
    UINavigationController *personalController = [storyboard instantiateInitialViewController];
    
    NSArray *controllers = [NSArray arrayWithObjects:vehicleController,driverController, orderController,taskController,personalController, nil];
    
    [self setViewControllers:controllers];
}
#pragma mark --- KNotification_PushGrabOrder
//推送过来的通知
-(void)pushGrabOrder:(NSNotification*)notification
{
    //设置选中
    [self cameraClick:self.cameraBtn];
}

@end
