//
//  MainViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//
#import "TFCarEvaluationVC.h"
#import "MainViewController.h"
#import <QuartzCore/CALayer.h>

#import "UIColor+Hex.h"
#import "CharteredViewController.h"
#import "CarpoolViewController.h"
#import "TravelViewController.h"
#import "TravelHistoryViewController.h"

#import <FNUIView/REFrostedViewController.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>
#import "EditCharterViewController.h"
#import "AirportViewController.h"
#import "CharteredViewController.h"

#import "LoginViewController.h"
#import "MainMenuViewController.h"

#import <FNNetInterface/FNNetInterface.h>
#import <FNUIView/MBProgressHUD.h>
#import <FNNetInterface/AFNetworking.h>
#import <FNUIView/BannerView.h>
#import "BaiDuCarViewController.h"
#import "TianfuCarHomeVC.h"
#import "MapCoordinaterModule.h"
#import "CachedataPreferences.h"
#import "RuleViewController.h"
#import <UIKit/UIApplicationShortcutItem.h>
#import "AppDelegate.h"

#define KMenuWidth    260
#define kLineLength   105
#define NavigationBarColor [UIColor colorWithRed:254/255.0 green:113/255.0 blue:75/255.0 alpha:1]
#define BackgroundColor [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()<UIAlertViewDelegate,BannerViewDelegate>{
    BOOL hasNotfinishOrder;
    BOOL isConnectStatus;
    BOOL isShowMenu;
//    CGFloat bannerHeight;
//    CGFloat buttonHeight;
}

//@property (nonatomic, strong) MainViewController *mainMenu;
//@property (weak, nonatomic) IBOutlet UIView *topView;
//@property (strong, nonatomic) UIImageView *banner;
@property (strong, nonatomic) BannerView  *banner;
@property (strong, nonatomic) UIButton    *btnCarpool;
@property (strong, nonatomic) UIButton    *btnChartered;
@property (strong, nonatomic) UIButton    *btnAirport;
@property (strong, nonatomic) UIButton    *btnMajorCar;
@property (strong, nonatomic) UIButton    *btnTianFuNew;

@property (strong, nonatomic) MapCoordinaterModule *coordateModule;

//请求的图片地址
@property (strong,nonatomic) NSMutableArray *bannerInfor;


@end

@implementation MainViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self setupNavigationBar];
	
	//请求服务器banner
	[NetManagerInstance sendRequstWithType:FNUserRequestType_GetCarouselindex params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];

    if (isConnectStatus == YES) {
      [self initRequestCoordinater];
    }
    //注册3DTouch 通知，
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchExecutionNotice:) name:KNotification_shortcutItem object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.banner startTimer];
    [self listenNetworkStatus];
    //self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //执行3DTouch通知，防止AppDelegate 通知的时候此对象未初始化
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_shortcutItem object:((AppDelegate*)[[UIApplication sharedApplication] delegate]).shortcutItem];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.banner stopTimer];
    //self.navigationController.navigationBarHidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark ----


- (void)initRequestCoordinater
{
    //[ProtocolInstance apiGetFence];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_Fence params:^(NetParams *params) {
        params.data = @{@"adCode": @(510100)};
    }];
}

- (void)setupNavigationBar {
    
    [self.navigationController.navigationBar setBarTintColor:NavigationBarColor];
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbkgreen"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.navigationItem.hidesBackButton =YES;
    self.navigationItem.title = @"飞牛巴士";
    
    UIImage *image = [UIImage imageNamed:@"personalcenter"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:buttonFrame];
    [btnLeft addTarget:self action:@selector(btnMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    self.navigationItem.leftBarButtonItem = item;
    
    image = [UIImage imageNamed:@"trip_manager"];
    UIButton *btnRight = [[UIButton alloc] initWithFrame:buttonFrame];
    [btnRight addTarget:self action:@selector(btnTravelClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setImage:image forState:UIControlStateNormal];
    
    item = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = item;
    
}

-(void)initUI
{
    //self.topView.backgroundColor = UIColor_DefGreen;
    
//    self.banner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner"]];
    self.banner = [[BannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/1.f, self.view.bounds.size.width/2.f)];
    [self.view addSubview:self.banner];
    
//    self.btnCarpool = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.btnCarpool setImage:[UIImage imageNamed:@"intercity_ carpooling_home"] forState:UIControlStateNormal];
//    [self.btnCarpool addTarget:self action:@selector(btnCarpoolClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnCarpool];
    
//    self.btnChartered = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.btnChartered setImage:[UIImage imageNamed:@"buschartered_home"] forState:UIControlStateNormal];
//    [self.btnChartered addTarget:self action:@selector(btnCharteredClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnChartered];
    
//    self.btnAirport = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.btnAirport setImage:[UIImage imageNamed:@"airport_home"] forState:UIControlStateNormal];
//    [self.btnAirport addTarget:self action:@selector(btnAirportClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnAirport];
    
//    self.btnMajorCar = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.btnMajorCar setImage:[UIImage imageNamed:@"tianfucar"] forState:UIControlStateNormal];
//    [self.btnMajorCar addTarget:self action:@selector(btnMajorCarClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnMajorCar];
//    
//    [self.banner mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
//        make.height.equalTo(self.banner.mas_width).multipliedBy(0.5);
//    }];
    
    self.banner.autoTurning = YES;
    self.banner.placeholderImage = @"banner";
    self.banner.delegate = self;
    _bannerInfor = [[CachedataPreferences sharedInstance] getBannerInfor];
    //获取图片地址
    NSMutableArray *imageInfor = [[NSMutableArray alloc] init];
    for (NSDictionary *tempDic in _bannerInfor) {
        if ([tempDic objectForKey:@"image"]) {
            [imageInfor addObject:[tempDic objectForKey:@"image"]];
        }
    }
    //有缓存数据读取缓存
    if (imageInfor.count > 0) {
        [self.banner loadImagesUrl:imageInfor];
        [self.banner addTimer];
    }
    else
    {
        //没有缓存数据读取默认默认一个
        [self.banner loadImagesUrl:@[@""]];
        [self.banner addTimer];
    }

    
//    [self.btnCarpool mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(_banner.mas_bottom).offset(10);
//
//        make.left.mas_equalTo(self.view).offset(10);
//        make.width.mas_equalTo(self.btnCarpool.mas_height).with.multipliedBy(0.58);
//    }];
    
//    [self.btnChartered mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.btnCarpool.top);
//        make.centerX.mas_equalTo(self.view);
//        make.left.mas_equalTo(self.btnCarpool.mas_right).with.offset(10);
//        make.width.and.height.mas_equalTo(self.btnCarpool);
//    }];
//    
//    [self.btnAirport mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.btnChartered.mas_right).with.offset(10);
//        make.right.equalTo(self.view.right).offset(-10);
//        make.top.equalTo(self.btnCarpool.top);
//        make.width.and.height.equalTo(self.btnCarpool);
//    }];
//    
//    [self.btnMajorCar mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//        make.centerX.equalTo(self.view);
//        make.bottom.equalTo(self.view).offset(15);
//        make.width.equalTo(self.view).multipliedBy(0.5);
//        make.height.equalTo(self.btnMajorCar.mas_width).with.multipliedBy(0.5);
//    }];

//    [backgroudView makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.btnMajorCar);
//        make.centerX.equalTo(self.btnMajorCar);
//        make.width.equalTo(self.btnMajorCar).offset(60);
//        make.height.equalTo(backgroudView.mas_width).multipliedBy(0.5);
//    }];
    
    /*************  去掉包车版本 *************/
    self.btnCarpool = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCarpool setImage:[UIImage imageNamed:@"carpool_ticket"] forState:UIControlStateNormal];
    [self.btnCarpool addTarget:self action:@selector(btnCarpoolClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnCarpool];
    
    self.btnTianFuNew = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnTianFuNew setImage:[UIImage imageNamed:@"home_tifu_new"] forState:UIControlStateNormal];
    [self.btnTianFuNew addTarget:self action:@selector(btnMajorCarClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnTianFuNew];

    UIImageView *ivLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_logo"]];
    [self.view addSubview:ivLogo];
    
    UIButton *btnHotLine = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHotLine setTitle:@"客服电话：400-0820-112" forState:UIControlStateNormal];
    [btnHotLine setTitleColor:[UIColor colorWithHex:0xA4A4A4] forState:UIControlStateNormal];
    [btnHotLine addTarget:self action:@selector(actionHotLine:) forControlEvents:UIControlEventTouchUpInside];
    btnHotLine.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:btnHotLine];
    
    [self.btnCarpool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_banner.mas_bottom).offset(5);
        
        make.left.mas_equalTo(self.view).offset(25);
        make.width.mas_equalTo(self.btnCarpool.mas_height).with.multipliedBy(0.58);
    }];
    [self.btnTianFuNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.btnCarpool.mas_top);
        make.right.mas_equalTo(self.view).offset(-25);
        make.left.mas_equalTo(self.btnCarpool.mas_right).with.offset(25);
        make.width.and.height.mas_equalTo(self.btnCarpool);
    }];
    
    [btnHotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [ivLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(btnHotLine.mas_top).offset(5);
    }];
}

-(void)requstFerryOrderCheckExists{
//    [self startWait];
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
        
    }];
}

#pragma mark -- BannerViewDelegate

-(void)bannerViewWithIndex:(int)index
{
    //点击了某一个bannar 跳转网页
    if (_bannerInfor.count > index) {
        //获取字典数据
        NSMutableDictionary *bannerDic = _bannerInfor[index];
        if ([bannerDic objectForKey:@"url"] && ![[bannerDic objectForKey:@"url"] isEqualToString:@""]) {
            //使用webView查看
            RuleViewController *ruleViewController = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
            ruleViewController.vcTitle = [bannerDic objectForKey:@"title"] ? [bannerDic objectForKey:@"title"] :@"";
            ruleViewController.urlString = [bannerDic objectForKey:@"url"];
            
            [self.navigationController pushViewController:ruleViewController animated:YES];
        }
    }
}


#pragma mark -- http response

- (void)httpRequestFinished:(NSNotification *)notification{
    [self stopWait];
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_Fence) {
        if (resultData.resultCode == 0) {
            //key
            @try {
                //围栏数据
                _coordateModule = [MapCoordinaterModule sharedInstance];
                //提取围栏数据
                if ([resultData.data[@"list"] isKindOfClass:[NSArray class]])
                {
                    _coordateModule.fenceArray = resultData.data[@"list"];
                }
                
                //以下为老数据，三环未删除防治功能报错
                
//                NSString *firstKey  = (NSString *)((notification.object[@"data"][@"list"])[0])[@"key"];
                //                NSString *secondKey = (NSString *)((notification.object[@"data"][@"list"])[1])[@"key"];
                //                NSString *thirdKey  = (NSString *)((notification.object[@"data"][@"list"])[2])[@"key"];
                //setting
//                NSArray *firstArr  = (NSArray *)((notification.object[@"data"][@"list"])[0])[@"fences"];
                //                NSArray *secondArr = (NSArray *)((notification.object[@"data"][@"list"])[1])[@"fences"];
                //                NSArray *thirdArr  = (NSArray *)((notification.object[@"data"][@"list"])[2])[@"fences"];
                
                _coordateModule = [MapCoordinaterModule sharedInstance];//coordinate module
                
                //设置key
//                [_coordateModule setRingKey:firstKey];
                //                [_coordateModule setTianfuKey:thirdKey];
                //                [_coordateModule setAirportKey:secondKey];
                //
                //设置fences
//                [_coordateModule setRingCoordinateArr   :firstArr];
                //                [_coordateModule setTianfuCoordinateArr :thirdArr];
                //                [_coordateModule setAirportCoordinateArr:secondArr];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
    else if (type == FNUserRequestType_GetCarouselindex)
    {
        //图片
        _bannerInfor = [resultData.data objectForKey:@"list"];
        //缓存数据
        [[CachedataPreferences sharedInstance] setBannerInfor:_bannerInfor];
        //获取图片地址
        NSMutableArray *imageInfor = [[NSMutableArray alloc] init];
        for (NSDictionary *tempDic in _bannerInfor) {
            if ([tempDic objectForKey:@"image"]) {
                [imageInfor addObject:[tempDic objectForKey:@"image"]];
            }
        }
        //根据数据获取
        if (imageInfor.count > 0) {
            [self.banner loadImagesUrl:imageInfor];
        }
        else
        {
            [self.banner loadImagesUrl:@[@""]];
        }
        [self.banner addTimer];
    }
    else if (type == KRequestType_FerryOrderCheck){
        
        if (resultData.resultCode == 0) {
            if ([resultData.data[@"isFerryBus"] integerValue] == 0) {
                [self showTipsView:@"该服务暂未开通，敬请期待！"];
            }else if ([resultData.data[@"isExists"] boolValue]) {  //存在
                UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"你有未完成的订单，是否现在查看?" delegate:self cancelButtonTitle:@"立即查看" otherButtonTitles:@"取消", nil];
                [alter show];
                
            }else{
                TianfuCarHomeVC* vc = [[TianfuCarHomeVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if (resultData.resultCode == 100002){
            
            //鉴权失效重置token
            [[UserPreferences sharedInstance] setToken:nil];
            [[UserPreferences sharedInstance] setUserId:nil];
            
            // 进入登录界面
            [LoginViewController presentAtViewController:self completion:^{
                //                [MBProgressHUD showTip:@"请登录！" WithType:FNTipTypeFailure];
            }callBalck:^(BOOL isSuccess, BOOL needToHome) {
                if(isSuccess){
                    [self requstFerryOrderCheckExists];
                }
            }];
            //重置别名
            [[PushConfiguration sharedInstance] resetAlias];
            //            [self showTipsView:[[JsonUtils jsonToDcit:msg] objectForKey:@"message"]];
        }
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}




- (void)httpRequestFailed:(NSNotification *)notification{
    [self stopWait];
    NSDictionary *dict = notification.object;
    int type = [[dict objectForKey:@"type"] intValue];
    if (type == KRequestType_FerryOrderCheck) {
        [MBProgressHUD showTip:@"服务器出错啦!" WithType:FNTipTypeFailure];
    }
}
#pragma mark - --3DTouch Notice
/**
 *  执行3DTouch
 *
 *  @param notification
 */
-(void)touchExecutionNotice:(NSNotification *)notification
{
    if(notification.object && [notification.object isKindOfClass:[UIApplicationShortcutItem class]])
    {
        //首先退回根控制器
        [self.navigationController popToRootViewControllerAnimated:YES];
        UINavigationController *menuNav = (UINavigationController*)self.frostedViewController.menuViewController;
        //如果存在菜单
        if (menuNav) {
            [menuNav popToRootViewControllerAnimated:NO];
            if (isShowMenu) {
                [self.frostedViewController hideMenuViewController];
                isShowMenu = NO;
            }
            
        }
        UIApplicationShortcutItem *shortItem = notification.object ;
        if ([shortItem.type isEqualToString:@"BusTicket"])
        {
            //客车订票
            [self btnCarpoolClick:nil];
        }
        else if ([shortItem.type isEqualToString:@"OrderManager"])
        {
            //订单管理
            [self btnTravelClick:nil];
        }
    }
    //执行一次后清空
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).shortcutItem = nil;
}

#pragma mark  -Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}


#pragma mark-
//天府专车
- (void)btnMajorCarClick{
    //judge network status
    if (isConnectStatus == NO) {
        
        [self popPromptView:@"亲，请检查网络连接"];
        
        return;
        
    }
    
    [self requstFerryOrderCheckExists];


}

- (void)btnAirportClick{
    
    //judge network status
    if (isConnectStatus == NO) {
        
        [self popPromptView:@"亲，请检查网络连接"];
        
        return;
        
    }
    
    AirportViewController *airportVc = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"AirportViewController"];
    
    [self.navigationController pushViewController:airportVc animated:YES];
    
}

- (void)btnMenuClick:(id)sender {

    if (![[UserPreferences sharedInstance] getToken]) {
        [LoginViewController presentAtViewController:self completion:nil callBalck:nil];
    }else {
        [self.frostedViewController presentMenuViewController];
        isShowMenu = YES;
    }
}

//拼车
- (void)btnCarpoolClick:(id)sender {
//    
//    TFCarEvaluationVC *tfcVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
//
//    tfcVC.isTianFuCar = YES;
//    [self.navigationController pushViewController:tfcVC animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TakeBus" bundle:nil];
    CarpoolViewController *c = [storyboard instantiateViewControllerWithIdentifier:@"CarpoolViewController"];
    c.networkingStatus = isConnectStatus;
    
    [self.navigationController pushViewController:c animated:YES];
}


//包车
- (void)btnCharteredClick:(id)sender {

    //judge network status
    if (isConnectStatus == NO) {
        
        [self popPromptView:@"亲，请检查网络连接"];
        return;
        
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TakeBus" bundle:nil];
  
    CharteredViewController *chartVc = [storyboard instantiateViewControllerWithIdentifier:@"CharteredViewController"];
    [self.navigationController pushViewController:chartVc animated:YES];

}

//行程
- (IBAction)btnTravelClick:(id)sender {
    
    //judge network status
    if (isConnectStatus == NO) {

        [self popPromptView:@"暂无网络"];
        return;
 
    }
    
    [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
//
//    TFCarEvaluationVC *evaluationVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
////    evaluationVC.orderDetailModel = _orderDetailModel;
////    evaluationVC.evaluationTypeId = _orderDetailModel.type;
//    
//    [self.navigationController pushViewController:evaluationVC animated:YES];
    
}
- (void)actionHotLine:(UIButton *)sender{
    [self takeAPhoneCallTo:@"4000820112"];
}
#pragma mark -- prompt animation 
- (void)popPromptView:(NSString *)text{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [hud setLabelText:text];
    [hud setMode:MBProgressHUDModeText];
    [hud hide:YES afterDelay:2];
    if (hud.hidden == YES) {
        [hud removeFromSuperview];
    }
}


#pragma mark -- network status

- (void)listenNetworkStatus{
    
    NSURL *baseURL = [NSURL URLWithString:@"http://example.com/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                isConnectStatus = YES;
                
                _coordateModule = [MapCoordinaterModule sharedInstance];
                
                [self initRequestCoordinater];

                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                isConnectStatus = YES;
                
                _coordateModule = [MapCoordinaterModule sharedInstance];
                
                [self initRequestCoordinater];

                break;
            case AFNetworkReachabilityStatusNotReachable:
                
                isConnectStatus = NO;

                break;
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    //开始监控
    [manager.reachabilityManager startMonitoring];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
    }
}

@end
