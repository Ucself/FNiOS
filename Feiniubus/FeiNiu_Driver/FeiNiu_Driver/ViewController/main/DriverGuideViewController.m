//
//  GuideViewController.m
//  XinRanApp
//
//  Created by tianbo on 14-12-4.
//  Copyright (c) 2014年 deshan.com All rights reserved.
//

#import "DriverGuideViewController.h"
#import <FNDataModule/EnvPreferences.h>
#import <FNCommon/FNCommon.h>
//#import "ProtocolCarOwner.h"
#import "ProtocolDriver.h"


@interface DriverGuideViewController ()<UITableViewDelegate>{
    //guide1
    UIImageView *guide1Image;
    UIImageView *guide1Text;
    //guide2
    UIImageView *guide2Image;
    UIImageView *guide2Text;
    //guide3
    UIImageView *guide3Image;
    UIImageView *guide3Text;
}

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView1;
@property (weak, nonatomic) IBOutlet UIView *uiView11;
@property (weak, nonatomic) IBOutlet UIView *uiView21;
@property (weak, nonatomic) IBOutlet UIView *uiView31;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl1;

@end

@implementation DriverGuideViewController

- (void)awakeFromNib{
    
    //初始化界面
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //滚动试图协议
    self.mainScrollView1.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark --

- (IBAction)btnToLoginClick:(id)sender {
    //故事版
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //先跳入主视图mainViewControllerIdent
    UIViewController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"mainControllerIdent"];
    [self.navigationController pushViewController:mainController animated:YES];
    //对鉴权进行查看
    NSString *token = [[EnvPreferences sharedInstance] getToken];
    NSString *userId = [[EnvPreferences sharedInstance] getUserId];
    DBG_MSG(@"The local token and userId is %@+%@", token,userId);
    //查看是否有授权数据，未授权弹出登录窗口
    if (!(token && userId))
    {
        //故事版
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //登录相关控制器
        UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
        //先进入登录进行测试
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else
    {
        //设置鉴权
        [[ProtocolDriver sharedInstance] setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", userId,token, EMUserRole_Driver]];
    }
}


#pragma mark --- UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.view.frame.size.width;
    int page = floor((self.mainScrollView1.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl1.currentPage=page;
    
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
   
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    //return [super httpRequestFailed:notification];
}
@end
