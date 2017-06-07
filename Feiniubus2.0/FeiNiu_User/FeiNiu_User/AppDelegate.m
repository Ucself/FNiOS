//
//  AppDelegate.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AppDelegate.h"
#import <FNNetInterface/FNNetInterface.h>
#import <FNPayment/FNPaymentManager.h>
#import "MapViewManager.h"
#import "3rdConstants.h"

#import <UMMobClick/MobClick.h>
#import <UMSocialCore/UMSocialCore.h>

#import "PushConfiguration.h"
#import "PushNotificationAdapter.h"
#import "JPUSHService.h"
#import "AuthorizeCache.h"
#import "AuthenticationLogic.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //初始化网络鉴权
    [self initNetInterface2];
    [self initNetAuthorization];
    
    //初始化地图
    [self initAMap];
    
    //初始化UM
    [self registerUmengShare];
    [self registerUmengAnalytic];

    //初始化激光推送
    [self initJPush:launchOptions];
    
    //注册微信
    [[FNPaymentManager instance] wechatRegister:UMnegWeiXinAppId];

    [application setApplicationIconBadgeNumber:0];
    [[PushConfiguration sharedInstance] setBadge:0];
    
    //鉴权类
    //[AuthenticationLogic sharedInstance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotifyEnterBackGround object:nil];
    
    [self enterBackgroundHandle:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [[PushConfiguration sharedInstance] setBadge:0];
    
    [self willEnterForegroundHandle:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //解决用户关闭程序后又打开推送通知，需要在启动的时候注册一次
    [self registrationNotice];
    [application setApplicationIconBadgeNumber:0];
    [[PushConfiguration sharedInstance] setBadge:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotifyBecomeActive object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//激光添加的代码
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    [JPUSHService handleRemoteNotification:userInfo];
    DBG_MSG(@"userInfo1==%@",userInfo);
    [self handleJPushNotification:userInfo];
    [PushNotificationAdapter addAPNSMessage:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    
    [JPUSHService handleRemoteNotification:userInfo];
    DBG_MSG(@"userInfo2==%@",userInfo);
    // IOS 7 Support Required
    completionHandler(UIBackgroundFetchResultNewData);
    [self handleJPushNotification:userInfo];
    [PushNotificationAdapter addAPNSMessage:userInfo];
}

//UMeng call-back function
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //支付回调
    [[FNPaymentManager instance] application:application handleOpenURL:url];
    
    //友盟回调
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    
    return YES;
}

//UMeng call-back function
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{

    //支付回调
    [[FNPaymentManager instance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    //友盟回调
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return true;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    [[FNPaymentManager instance] application:app openURL:url options:options];
    return true;
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
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound |
                                                    UIUserNotificationTypeAlert)
                                          categories:nil];

        // Required
#ifdef DEBUG
        [JPUSHService setupWithOption:launchOptions appKey:JPushAppKey channel:nil apsForProduction:NO];
#else 
        [JPUSHService setupWithOption:launchOptions appKey:JPushAppKey channel:nil apsForProduction:YES];
#endif
        
    });
}

//激光服务器注册
- (void)registrationNotice
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *userId = [[AuthorizeCache sharedInstance] getUserId];
        if (userId && ![userId isEqualToString:@""]) {
            [[PushConfiguration sharedInstance] setAlias:PassengerAlias userId:userId];
        }
    });
}

- (void)registerUmengShare{
   
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //打开调试日志
        [[UMSocialManager defaultManager] openLog:YES];
        
        
        //设置友盟appkey
        [[UMSocialManager defaultManager] setUmSocialAppkey:UMengAppKey];
        NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
        
        //QQ and QQZone
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:UMengQQAppId  appSecret:nil redirectURL:UMengUniformUrl];
        
        //WeiXin
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:UMnegWeiXinAppId appSecret:UmengWeiXinAppSecret redirectURL:UMengUniformUrl];
        
        //sina
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:UMengSinaAppId  appSecret:UMengSianAppKey redirectURL:UMengSinaUrl];
    
    });
    
}

- (void)registerUmengAnalytic
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //注册友盟统计
        UMConfigInstance.appKey = UMengAppKey;
        [MobClick startWithConfigure:UMConfigInstance];
        
        [MobClick setAppVersion:BUILDVERSION];
        
#ifdef DEBUG
        [MobClick setLogEnabled:YES];
        [MobClick setCrashReportEnabled:NO];
#else
        [MobClick setCrashReportEnabled:YES];
#endif
    });
}

//极光推送代码处理
- (void)handleJPushNotification:(NSDictionary *)userInfo{
    
    if (![userInfo objectForKey:kProccessType]) {
        return;
    }
    
    int type = [userInfo[kProccessType] intValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%d", type] object:userInfo];
}

/**
 *  初始化地图
 */
-(void)initAMap
{
    //注册key
    [[MapViewManager sharedInstance] registerAppKey:KMapAppKey];
    
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


/**
 *  初始化网络
 */
-(void)initNetInterface2
{
    [UrlMapsInstance resetUrlMaps:@{
                                    
            //4.0接口
            //{{鉴权接口
            @(EmRequestType_Login):                  REQUESTURL2(KPassportServer, UNI_Login),
            @(EMRequestType_RefreshToken):           REQUESTURL2(KPassportServer, UNI_RefreshToken),
            @(EmRequestType_GetVerifyCode):          REQUESTURL2(KPassportServer, UNI_VerifyCode),
            
            //检查更新
            @(EmRequestType_UpdateCheck):            REQUESTURL2(KUpdateServer, UNI_UpdateCheck),
            
            //个人中心
            @(EmRequestType_CouponList):             REQUESTURL2(KGatewayServer, UNI_CouponList),
            @(EmRequestType_CouponAll):              REQUESTURL2(KGatewayServer, UNI_CouponAll),
            @(EmRequestType_EditAccount):            REQUESTURL2(KGatewayServer, UNI_EditAccount),
            @(EmRequestType_GetAccount):             REQUESTURL2(KGatewayServer, UNI_GetAccount),
            @(EmRequestType_Feedback):               REQUESTURL2(KGatewayServer, UNI_Feedback),
            @(EmRequestType_Invite):                 REQUESTURL2(KGatewayServer, UNI_Invite),
            
            //接送机接口与公共接口
            @(EmRequestType_OpenCity):               REQUESTURL2(KGatewayServer, UNI_OpenCity),
            @(EmRequestType_CommuteOpenCity):        REQUESTURL2(KGatewayServer, UNI_CommuteOpenCity),
            @(EmRequestType_CityBusiness):           REQUESTURL2(KGatewayServer, UNI_CityBusiness),
            @(EMRequestType_StationInfo):            REQUESTURL2(KGatewayServer, UNI_StationInfo),
            @(EmRequestType_GetFence):               REQUESTURL2(KGatewayServer, UNI_GetFence),
            @(EmRequestType_FlightInfo):             REQUESTURL2(KGatewayServer, UNI_Flightinfo),
            @(EmRequestType_ConfigSendtime):         REQUESTURL2(KGatewayServer, UNI_ConfigSendtime),
            @(EmRequestType_CommuteShare):           REQUESTURL2(KGatewayServer, UNI_CommuteShare),
            @(EmRequestType_ComputePrice):           REQUESTURL2(KGatewayServer, UNI_ComputePrice),
            
            //接送机支付
            @(EmRequestType_PaymentCharge):          REQUESTURL2(KGatewayServer, UNI_PaymentCharge),
            @(EmRequestType_PaymentQuery):           REQUESTURL2(KGatewayServer, UNI_PaymentQuery),
            @(EmRequestType_PayRefund):              REQUESTURL2(KGatewayServer, UNI_PayRefund),
            @(EmRequestType_PayRefundQuery):         REQUESTURL2(KGatewayServer, UNI_PayRefundQuery),
            @(EmRequestType_PayRefundDetail):        REQUESTURL2(KGatewayServer, UNI_PayRefundDetail),
            
            //接送机订单
            @(EmRequestType_CreateOrder):               REQUESTURL2(KGatewayServer, UNI_CreateOrder),
            @(EmRequestType_OrderDetail):               REQUESTURL2(KGatewayServer, UNI_OrderDetail),
            @(EmRequestType_OrderList):                 REQUESTURL2(KGatewayServer, UNI_OrderList),
            @(EmRequestType_Order_Delete):              REQUESTURL2(KGatewayServer, UNI_Order_Delete),
            @(EmRequestType_OrderCancel):               REQUESTURL2(KGatewayServer, UNI_OrderCancel),
            @(EmRequestType_OrderReason):               REQUESTURL2(KGatewayServer, UNI_OrderReason),
            @(EmRequestType_ComplaintAdd):              REQUESTURL2(KGatewayServer, UNI_ComplaintAdd),
            @(EmRequestType_EvaluateGet):               REQUESTURL2(KGatewayServer, UNI_EvaluateGet),
            @(EmRequestType_EvaluatePost):              REQUESTURL2(KGatewayServer, UNI_EvaluatePost),
            @(EmRequestType_BillDetail):                REQUESTURL2(KGatewayServer, UNI_BillDetail),
            
            //定制通勤
            @(EmRequestType_CommuteList):                REQUESTURL2(KGatewayServer, UNI_CommuteList),
            @(EmRequestType_CommuteDetail):              REQUESTURL2(KGatewayServer, UNI_CommuteDetail),
            @(EmRequestType_CommuteSearch):              REQUESTURL2(KGatewayServer, UNI_CommuteSearch),
            @(EmRequestType_CommuteTicket):              REQUESTURL2(KGatewayServer, UNI_CommuteTicket),
            @(EmRequestType_ConfigAdvertisement):        REQUESTURL2(KGatewayServer, UNI_ConfigAdvertisement),
            @(EmRequestType_CouponBest):                 REQUESTURL2(KGatewayServer, UNI_CouponBest),
            @(EmRequestType_ConfigActivity):             REQUESTURL2(KGatewayServer, UNI_ConfigActivity),
            
            //定制通勤订单
            @(EmRequestType_CommuteOrderPost):           REQUESTURL2(KGatewayServer, UNI_CommuteOrderPost),
            @(EmRequestType_CommuteOrderTicket):         REQUESTURL2(KGatewayServer, UNI_CommuteOrderTicket),
            @(EmRequestType_CommuteOrderRefund):         REQUESTURL2(KGatewayServer, UNI_CommuteOrderRefund),
            @(EmRequestType_CommuteOrderList):           REQUESTURL2(KGatewayServer, UNI_CommuteOrderList),
            @(EmRequestType_CommuteOrderTicketDelete):   REQUESTURL2(KGatewayServer, UNI_CommuteOrderTicketDelete),
            @(EmRequestType_CommuteOrderCancel):         REQUESTURL2(KGatewayServer, UNI_CommuteOrderCancel),
            @(EmRequestType_CommuteTicketReason):        REQUESTURL2(KGatewayServer, UNI_CommuteTicketReason),
            @(EmRequestType_CommuteTicketComplaint):     REQUESTURL2(KGatewayServer, UNI_CommuteTicketComplaint),
            @(EmRequestType_CommuteTicketRefund):        REQUESTURL2(KGatewayServer, UNI_CommuteTicketRefund),
            @(EmRequestType_CommuteTicketEvaluate):      REQUESTURL2(KGatewayServer, UNI_CommuteTicketEvaluate),
            @(EmRequestType_CommuteTicketGetEvaluate):   REQUESTURL2(KGatewayServer, UNI_CommuteTicketGetEvaluate),
            @(EmRequestType_CommuteOrderCalc):           REQUESTURL2(KGatewayServer, UNI_CommuteOrderCalc),
            
            //通勤车支付
            @(EmRequestType_CommutePayment):             REQUESTURL2(KGatewayServer, UNI_CommutePaymentCharge),
            @(EmRequestType_CommuteMyTickets):           REQUESTURL2(KGatewayServer, UNI_CommuteMyTickets),
            @(EmRequestType_CommuteValidateTicket):      REQUESTURL2(KGatewayServer, UNI_CommuteValidateTicket),
            @(EmRequestType_CommuteApply):               REQUESTURL2(KGatewayServer, UNI_CommuteApply),
            @(EmRequestType_CommuteApplyGet):            REQUESTURL2(KGatewayServer, UNI_CommuteApplyGet),
            
            }];
}

-(void)initNetAuthorization
{
    //设置客户端角色类型   1:用户
    [UserPreferInstance setUserRole:@"1"];
    NSString *token  = [[AuthorizeCache sharedInstance] getAccessToken];
    [NetManagerInstance setAuthorization:[[NSString alloc] initWithFormat:@"Bearer %@",token]];
}

-(void)enterBackgroundHandle:(UIApplication *)application{
    
    if (!_needBgTask) {
        return;
    }
    
    _bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // 10分钟后执行这里，应该进行一些清理工作，如断开和服务器的连接等
        // ...
        // stopped or ending the task outright.
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    if (_bgTask == UIBackgroundTaskInvalid) {
        NSLog(@"failed to start background task!");
    }
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        NSTimeInterval timeRemain = 0;
        do{
            [NSThread sleepForTimeInterval:5];
            if (_bgTask!= UIBackgroundTaskInvalid) {
                timeRemain = [application backgroundTimeRemaining];
                NSLog(@"Time remaining: %f",timeRemain);
            }
        }while(_bgTask!= UIBackgroundTaskInvalid && timeRemain > 0);
        // 如果改为timeRemain > 5*60,表示后台运行5分钟
        // done!
        // 如果没到10分钟，也可以主动关闭后台任务，但这需要在主线程中执行，否则会出错
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_bgTask != UIBackgroundTaskInvalid)
            {
                // 和上面10分钟后执行的代码一样
                // ...
                // if you don't call endBackgroundTask, the OS will exit your app.
                [application endBackgroundTask:_bgTask];
                _bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}
-(void)willEnterForegroundHandle:(UIApplication *)application{
    // 如果没到10分钟又打开了app,结束后台任务
    if (_bgTask!=UIBackgroundTaskInvalid) {
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }
}

@end
