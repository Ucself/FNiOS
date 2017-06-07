//
//  MainViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/10.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNUIView/REFrostedViewController.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>

#import "MainViewController.h"
#import "OrderMainViewController.h"
#import "LoginViewController.h"
#import "CouponsViewController.h"
#import "FeedbackViewController.h"
#import "MessageViewController.h"
#import "MoreViewController.h"
#import "ShareViewController.h"
#import "UserInfoViewController.h"
#import "WebContentViewController.h"
#import <FNUIView/UserCustomAlertView.h>
#import "PushNotificationAdapter.h"
#import "PushConfiguration.h"
#import "AppDelegate.h"
#import "ApplyScheduledViewController.h"
#import "ApplySuccessViewController.h"
#import <FNUIView/WaitView.h>
#import "AuthorizeCache.h"
#import "AuthenticationLogic.h"
#import "ActivityCenterViewController.h"

#import "FeiNiu_User-Swift.h"

//测试
//#import "ScheduledTripViewController.h"
//#import "ScheduledEvaluationViewController.h"


@interface MainViewController () <UserCustomAlertViewDelegate>

@property (nonatomic, strong) NSDictionary *updateDict;
@property (nonatomic, strong) NSArray *activityArray;
@property (nonatomic, assign) BOOL  delayActivity;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //检查更新
    [self updateCheck];
    
    
    [self initTabController];
    //菜单宽度
    self.frostedViewController.rightMargin = 90;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMenuNotification:) name:KShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidSelectNotification:) name:KMenuDidSelectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification:) name:KLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivityNotivication:) name:KNotificationShowActivity object:nil];
    
    //接送状态推送处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callCarStateNotification:) name:FnPushType_BeginSendCar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callCarStateNotification:) name:FnPushType_BeginTheRoad object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callCarStateNotification:) name:FnPushType_EndCallCar object:nil];
    
    //注册网络请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
    
    //获取个人信息
//    NSString *token = [[AuthorizeCache sharedInstance] getAccessToken];
//    if (token && token.length != 0) {
//        [self requestUserInfo];
//    }
    [[AuthenticationLogic sharedInstance] addUserData:self];
    
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.mainController = self;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTabController
{
    //背景色
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tabBar.frame.size.width, 49)];
    backView.backgroundColor = UINavigationBKColor;
    [self.tabBar insertSubview:backView atIndex:0];
    self.tabBar.opaque = YES;

    //设置字体
    [[UITabBar appearance] setTintColor:UIColor_DefOrange];
    [[UITabBarItem appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                             forState: UIControlStateNormal];


//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MyTravel" bundle:nil];
//    UIViewController *orders = [storyboard instantiateInitialViewController];
//
//    UIStoryboard* ticketsStoryboard = [UIStoryboard storyboardWithName:@"Tickets" bundle:nil];
//    UIViewController *tickets = [ticketsStoryboard instantiateInitialViewController];
//    
//    UIStoryboard* busStoryboard = [UIStoryboard storyboardWithName:@"Bus" bundle:nil];
//    UIViewController *bus = [busStoryboard instantiateInitialViewController];
    
    UIStoryboard* scheduledBusStoryboard = [UIStoryboard storyboardWithName:@"ScheduledBus" bundle:nil];
    UINavigationController *naviScheduledBus = [scheduledBusStoryboard instantiateInitialViewController];
    
    //接送机
    UIStoryboard* shuttleBusStoryboard = [UIStoryboard storyboardWithName:@"ShuttleBus" bundle:nil];
    
    
    UINavigationController *naviAirport = [shuttleBusStoryboard instantiateInitialViewController];
    ShuttleBusViewController *airport = (ShuttleBusViewController*)naviAirport.topViewController;
    [airport setShuttleWithCategory:@"AirportPickup"];
    
    UINavigationController *naviTrain = [shuttleBusStoryboard instantiateViewControllerWithIdentifier:@"takeTrainNavigationController"];
    ShuttleBusViewController *trainStaion = (ShuttleBusViewController*)naviTrain.topViewController ;
    [trainStaion setShuttleWithCategory:@"TrainStationPickup"];
    
    UINavigationController *naviBus = [shuttleBusStoryboard  instantiateViewControllerWithIdentifier:@"takeCarNavigationController"];
    ShuttleBusViewController *busStaion = (ShuttleBusViewController*)naviBus.topViewController ;
    [busStaion setShuttleWithCategory:@"BusStationPickup"];
    
    NSArray *controllers = [NSArray arrayWithObjects:naviScheduledBus, naviAirport, naviTrain, naviBus,nil];
    [self setViewControllers:controllers]; 
}

#pragma mark -
-(void)showMenuNotification:(NSNotification*)notify
{
    if (![[AuthorizeCache sharedInstance] getAccessToken] || [[[AuthorizeCache sharedInstance] getAccessToken] isEqualToString:@""]) {
        [LoginViewController presentAtViewController:self completion:nil callBalck:nil];
    }else {
        [self.frostedViewController presentMenuViewController];
    }
}

-(void)menuDidSelectNotification:(NSNotification*)notify
{
    //[self.frostedViewController hideMenuViewController];
    
    NSNumber *selIndex = notify.object;
    switch (selIndex.integerValue) {
        case 0:
        {
//            UIViewController *c = [ShuttleBusOrderListViewController instanceWithStoryboardName:@"ShuttleBusOrder"];
            UIViewController *c = [OrderMainViewController instanceWithStoryboardName:@"MyTravel"];
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
        }
            
            break;
        case 1: {
            UIViewController *c = [ScheduleTicketViewController instanceWithStoryboardName:@"ScheduledOrder"];
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
            
        }
            break;
        case 2: {
            CouponsViewController *c = [CouponsViewController instanceWithStoryboardName:@"Me"];
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
        }
            break;
        case 3: {
            UIViewController *c = [ApplyScheduledViewController instanceWithStoryboardName:@"Me"];
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
        }
            break;
//        case 4: {     //邀请有奖
//            UIViewController *c = [InviteViewController instanceWithStoryboardName:@"Me"];
//            [self.frostedViewController.navigationController pushViewController:c animated:YES];
//        }
            break;
//        case 5: {     //活动中心
//            UIViewController *c = [ActivityCenterViewController instanceWithStoryboardName:@"Me"];
//            [self.frostedViewController.navigationController pushViewController:c animated:YES];
//        }
//            break;
        case 4: {
            UIViewController *c = [MoreViewController instanceWithStoryboardName:@"Me"];
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
        }
            break;
        case 10: {
            ApplySuccessViewController *c = [ApplySuccessViewController instanceWithStoryboardName:@"Me"];
            NSDictionary *dict = notify.userInfo;
            if (dict) {
                c.homeAddr    = dict[@"homeAddr"];
                c.componyAddr = dict[@"componyAddr"];
                c.onworkTime  = dict[@"onworkTime"];
                c.offworkTime = dict[@"offworkTime"];
            }
            
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
        }
            break;
        case 11:
        {
            UIViewController *c = [UserInfoViewController instanceWithStoryboardName:@"Me"];
            [self.frostedViewController.navigationController pushViewController:c animated:YES];
        }
            
        default:
            break;
    }

}

//接送机状态处理
- (void)callCarStateNotification:(NSNotification *)notification
{
    if ([notification.object[@"success"] integerValue] == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
    }
}

-(void)logoutNotification:(NSNotification*)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.frostedViewController hideMenuViewController];
    });
}

-(void)showActivityNotivication:(NSNotification*)notification
{
    self.activityArray = notification.object;

    if (self.updateDict && [self.updateDict[@"update"] boolValue]) {
        self.delayActivity = YES;
        return;
    }
    //活动数据大于0才显示活动
    [self showActivity];
}

-(void)showActivity
{
    if (!self.activityArray || self.activityArray.count == 0) {
        return;
    }
    AdvertView *advertView = [AdvertView initWithDataArrayWithDataArray:self.activityArray];
    [advertView showInViewWithParentView:self.view];
    
    __weak __typeof(self)weakSelf = self;
    advertView.clickCallback = ^(NSInteger index){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *dict = strongSelf.activityArray[index];
        WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
        webViewController.vcTitle = @"活动详情";
        webViewController.urlString = dict[@"detail_url"];
        [strongSelf.frostedViewController.navigationController pushViewController:webViewController animated:YES];
    };
}



#pragma mark - UserAlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (alertView.tag == 100) {
        if (btnIndex == 0) {
            BOOL isForce = [self.updateDict[@"force_update"] boolValue];;
            if (isForce) {
                exit(0);
            }
            else {
                [alertView hide:YES];
                
                if (self.delayActivity) {
                    [self showActivity];
                }
            }
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateDict[@"apk_url"]]];
        }
    }
    
}

- (void)startWait{
    //[LoadingViewController showInWindow];
    [[WaitView sharedInstance] start];
}
- (void)stopWait{
    //[LoadingViewController hideLoadingViewInWindow];
    [[WaitView sharedInstance] stop];
}


#pragma mark- http request handler
- (void)requestUserInfo{
    //    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_GetUserInfo params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
}

-(void)updateCheck {
    [NetManagerInstance sendRequstWithType:EmRequestType_UpdateCheck params:^(NetParams *params) {
        NSString *version = BUILDVERSION;
        NSArray  *array = [version componentsSeparatedByString:@"."];
        version = [array lastObject];
        params.data = @{@"appKey": KUpdateAppKey,
                        @"version_code": [NSString stringWithFormat:@"%d", [version intValue]]};
    }];
}

-(void)httpRequestFinished:(NSNotification *)notification
{
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.type == EmRequestType_GetUserInfo) {
        
        User *user = [User mj_objectWithKeyValues:result.data];
        [UserPreferInstance setUserInfo:user];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_RequestFinished object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_RequestFailed object:nil];
    }
    else if (result.type == EmRequestType_UpdateCheck) {
        self.updateDict = [NSDictionary dictionaryWithDictionary: result.data];
        if (!self.updateDict) {
            return;
        }
        
        BOOL update = [self.updateDict[@"update"] boolValue];
        if (update) {
            UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:
                                              [NSString stringWithFormat:@"发现新版本V%@", self.updateDict[@"new_version_name"]]
                                                                             message:self.updateDict[@"update_log"]
                                                                            delegate:self
                                                                             buttons:@[@"忽略此版本", @"现在更新"]];
            alertView.tag = 100;
            alertView.disableDismiss = YES;
            [alertView showInView:KWindow];
            [KWindow bringSubviewToFront:alertView];
            
        }
    }
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    ResultDataModel *result = notification.object;
    if (result.type == EmRequestType_GetUserInfo) {
        if (result.code == EmCode_AuthError) {
            //鉴权失效重置token
            [[AuthorizeCache sharedInstance] clean];
            
            //重置别名
            [[PushConfiguration sharedInstance] resetAlias];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_RequestFinished object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_RequestFailed object:nil];
        }
    }
}

@end
