//
//  AppDelegate.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/7/28.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "AppDelegate.h"
#import <FNNetInterface/PushConfiguration.h>
#import <FNNetInterface/APService.h>
#import "MapViewManager.h"
#import "UserPreferences.h"
#import "PushNotificationAdapter.h"

#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "PingPPayUtil.h"

#import "ContainerViewController.h"
#import "CharteredTravelingViewController.h"
#import "CarpoolTravelingViewController.h"
#import "CarpoolOrderItem.h"
#import "CustomTipsView.h"
#import "UMSocial.h"
#import "MobClick.h"

#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"
#define PGY_APPKEY    @"d1b8862120e2d164a0cfcdcbe3ba6ca1"

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置状态条颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //初始化UM
    [self registerUmengShare];
    [self registerUmengAnalytic];
    //地图初始化
    [self initAMap];
    //设置客户端角色类型   1:用户
    [[UserPreferences sharedInstance] setUserRole:@"1"];
    //初始化鉴权信息
    [NetManagerInstance setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", [[UserPreferences sharedInstance] getUserId],[[UserPreferences sharedInstance] getToken],EMUserRole_User]];
    //初始化激光推送
    [self initJPush:launchOptions];
    
    [application setApplicationIconBadgeNumber:0];
    [[PushConfiguration sharedInstance] setBadge:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCustomTips) name:@"showtips" object:nil];
    // 开始监听网络状态
    [NetManagerInstance reach];
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setApplicationIconBadgeNumber:0];
    [[PushConfiguration sharedInstance] setBadge:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [[PushConfiguration sharedInstance] setBadge:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //解决用户关闭程序后又打开推送通知，需要在启动的时候注册一次
    [self registrationNotice];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//激光添加的代码
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    [APService handleRemoteNotification:userInfo];
    DBG_MSG(@"userInfo1==%@",userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_APNS object:userInfo];
    [PushNotificationAdapter addAPNSMessage:userInfo];
    if (application.applicationState != UIApplicationStateActive) {
        [self handleNotification:userInfo];
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    DBG_MSG(@"userInfo2==%@",userInfo);
    // IOS 7 Support Required
    completionHandler(UIBackgroundFetchResultNewData);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_APNS object:userInfo];
    [PushNotificationAdapter addAPNSMessage:userInfo];
    if (application.applicationState != UIApplicationStateActive) {
        [self handleNotification:userInfo];
    }
}

//UMeng call-back function
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    //    DBG_MSG(@"openUrl:%@, sourceApp:%@", url, sourceApplication);
    [Pingpp handleOpenURL:url withCompletion:^(NSString *result, PingppError *error) {
        // result : success, fail, cancel, invalid
        [[NSNotificationCenter defaultCenter] postNotificationName:FNPayResultNotificationName object:nil];
        NSString *msg;
        if (error == nil) {
            NSLog(@"PingppError is nil");
            msg = result;
        } else {
            NSLog(@"PingppError: code=%lu msg=%@", (unsigned long)error.code, [error getMsg]);
            msg = [NSString stringWithFormat:@"result=%@ PingppError: code=%lu msg=%@", result, (unsigned long)error.code, [error getMsg]];
        }
        DBG_MSG(@"%@", msg);
    }];
    
    [UMSocialSnsService handleOpenURL:url];
    
    return YES;
}

//UMeng call-back function
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    [Pingpp handleOpenURL:url sourceApplication:sourceApplication withCompletion:^(NSString *result, PingppError *error) {
        NSMutableDictionary *obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%@", result] forKey:FNPayResultResultKey];
        if (error) {
            [obj setObject:error forKey:FNPayResultErrorKey];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FNPayResultNotificationName object:obj];
    }];
    
    return  [UMSocialSnsService handleOpenURL:url];
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    self.shortcutItem = shortcutItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_shortcutItem object:shortcutItem];
}

#pragma mark -----
//初始化推送
- (void)initJPush:(NSDictionary *)launchOptions
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //激光推送代码
        // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            //可以添加自定义categories
            [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                           UIUserNotificationTypeSound |
                                                           UIUserNotificationTypeAlert)
                                               categories:nil];
        } else {
            //categories 必须为nil
            [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                           UIRemoteNotificationTypeSound |
                                                           UIRemoteNotificationTypeAlert)
                                               categories:nil];
        }
#else
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
#endif
        // Required
        [APService setupWithOption:launchOptions];
    });
}


//激光服务器注册
- (void)registrationNotice
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *userId = [[UserPreferences sharedInstance] getUserId];
        if (userId && ![userId isEqualToString:@""]) {
            [[PushConfiguration sharedInstance] setAlias:PassengerAlias userId:userId];
        }
    });
}

- (void)registerUmengShare{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [UMSocialData setAppKey:UMengAppKey];//设置友盟appkey
        
        //QQ and QQZone
        [UMSocialQQHandler setQQWithAppId:UMengQQAppId appKey:UMengQQAppKey url:UMengUniformUrl];
        
        //WeiXin
        [UMSocialWechatHandler setWXAppId:UMnegWeiXinAppId appSecret:UmengWeiXinAppSecret url:UMengUniformUrl];
    });
    
}

- (void)registerUmengAnalytic
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //注册友盟统计
        [MobClick startWithAppkey:UMengAppKey];

        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [MobClick setAppVersion:version];

    #ifdef DEBUG
        [MobClick setLogEnabled:YES];
        [MobClick setCrashReportEnabled:NO];
    #else
        [MobClick setCrashReportEnabled:YES];
    #endif
    });
}

//极光推送代码处理
- (void)handleNotification:(NSDictionary *)userInfo{
    
    @try {
        ContainerViewController *container = (ContainerViewController *)[[UIApplication sharedApplication].keyWindow.rootViewController presentedViewController];
        UINavigationController *nav = (UINavigationController *)container.contentViewController;
        UIViewController *rootVC = [nav.viewControllers firstObject];
        
        FNPushProccessType type = [userInfo[kProccessType] integerValue];
        switch (type) {
            case FNPushProccessType_CharterOrderCreate:
            case FNPushProccessType_CharterForceToWaitingStart:
            case FNPushProccessType_CharterOrderGrab:
            case FNPushProccessType_CharterOrderInvalid:
            case FNPushProccessType_CharterOrderPayTimeout:
            case FNPushProccessType_CharterOrderTimeout:
            case FNPushProccessType_CharterPayFeedback:
            case FNPushProccessType_CharterTravelEnd:
            case FNPushProccessType_CharterTravelStart:{
                NSString *mainOrderId = userInfo[@"mainOrderId"];
                if (!mainOrderId) {
                    mainOrderId = userInfo[@"orderId"];
                }
                CharteredTravelingViewController *charterVC = [CharteredTravelingViewController instanceFromStoryboard];
                charterVC.orderId = mainOrderId;
                [nav setViewControllers:@[rootVC, charterVC] animated:YES];
                
                break;
            }
            case FNPushProccessType_CarpoolCallBaidu:
            case FNPushProccessType_CarpoolCallBaiduSuccess:
            case FNPushProccessType_CarpoolChildOrderCreate:
            case FNPushProccessType_CarpoolInvalidForNoPaid:
            case FNPushProccessType_CarpoolOrderCreate:
            case FNPushProccessType_CarpoolPayFeedback:
            case FNPushProccessType_CarpoolStartTime:
            case FNPushProccessType_CarpoolTravelEnd:
            case FNPushProccessType_CarpoolTravelStart:{
                NSString *mainOrderId = userInfo[@"mainOrderId"];
                if (!mainOrderId) {
                    return;
                }
                CarpoolOrderItem *orderItem = [[CarpoolOrderItem alloc]init];
                orderItem.orderId = mainOrderId;
                
                CarpoolTravelingViewController *carpoolVC = [CarpoolTravelingViewController instanceFromStoryboard];
                carpoolVC.carpoolOrder = orderItem;
                [nav setViewControllers:@[rootVC, carpoolVC] animated:YES];
                break;
            }
            default:
                break;
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)showCustomTips{
    
    CustomTipsView *customView = [CustomTipsView sharedInstance];
    [customView setFrame:CGRectMake(0, 0, _window.frame.size.width, _window.frame.size.height)];
    [_window addSubview:customView];
}
/**
 *  初始化地图
 */
-(void)initAMap
{
    //注册key
    [[MapViewManager sharedInstance]registerAppKey:KMapAppKey];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; //控制定位精度,越高耗电量越大。
        _locationManager.distanceFilter = 100; //控制定位服务更新频率。单位是“米”
        [_locationManager startUpdatingLocation];
        //在ios 8.0下要授权
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [_locationManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
        }
    }
}

@end
