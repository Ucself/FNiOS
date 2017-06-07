//
//  AppDelegate.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/7/29.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "AppDelegate.h"
#import <FNNetInterface/APService.h>
#import <FNCommon/FNCommon.h>
#import "DriverPreferences.h"
#import <FNNetInterface/PushConfiguration.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //监听异常
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
    //注册地图key
    [MAMapServices sharedServices].apiKey = @"9e70c6645e6e47ca99dd37d3065f7518";
    self.mapView = [[MAMapView alloc] init];
    
    //状态栏设置为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //配置极光推送
    [self pushTheConfiguration:launchOptions];
    //获取本地缓存的地理位置信息
    _locationUploadModel = [[DriverPreferences sharedInstance] getDriverLocationUploadModel];
    
    //设置应用上的图标显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //向极光服务器设置
    [[PushConfiguration sharedInstance] setBadge:0];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
    //设置应用上的图标显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //向极光服务器设置
    [[PushConfiguration sharedInstance] setBadge:0];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    DBG_MSG(@"userInfo2==%@",userInfo);
    // IOS 7 Support Required
    completionHandler(UIBackgroundFetchResultNewData);
    //设置应用上的图标显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //向极光服务器设置
    [[PushConfiguration sharedInstance] setBadge:0];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --- 极光推送配置
-(void)pushTheConfiguration:(NSDictionary *)launchOptions
{
    //激光推送代码
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //categories
        [APService
         registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound |
                                             UIUserNotificationTypeAlert)
         categories:nil];
    } else {
        //categories nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
#else
         //categories nil
                                           categories:nil];
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
#endif
         // Required
                                           categories:nil];
        [APService setupWithOption:launchOptions];
    }
}

#pragma mark --- 异常处理
void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    NSLog(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
}

@end
