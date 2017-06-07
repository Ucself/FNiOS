//
//  AppDelegate.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/7/29.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "AppDelegate.h"
#import <FNDataModule/EnvPreferences.h>
#import <FNNetInterface/APService.h>
#import <FNCommon/FNCommon.h>
#import "CarOwnerPreferences.h"
#import <FNCommon/DateUtils.h>
//Constants.h
#import <FNCommon/Constants.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //监听异常
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
    // Override point for customization after application launch.
    //注册地图key
    [MAMapServices sharedServices].apiKey = @"050e9dde4181cbb7b80bc51fe0c687db";
    self.mapView = [[MAMapView alloc] init];
    //设置角色类型
    [[EnvPreferences sharedInstance] setUserRole:@"3"];
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
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotifyBecomeActive object:nil];
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
    [self handleNotificationCallback:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    DBG_MSG(@"userInfo2==%@",userInfo);
    // IOS 7 Support Required
    completionHandler(UIBackgroundFetchResultNewData);
    [self handleNotificationCallback:userInfo];
}

#pragma mark --- 处理通知回调

-(void)handleNotificationCallback:(NSDictionary*)userInfo
{
    //如果推送过来是抢单 processType == 3 新的抢单
    if(userInfo && [[userInfo objectForKey:@"processType"] isEqualToString:@"3"])
    {
        //发送更新通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_PushGrabOrder object:nil];
    }
    //抢单结果
    if(userInfo && [[userInfo objectForKey:@"processType"] isEqualToString:@"4"])
    {
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
        [resultDic setObject:[userInfo objectForKey:@"orderId"] ? [userInfo objectForKey:@"orderId"] :@"" forKey:@"orderId"];
        [resultDic setObject:[userInfo objectForKey:@"processType"] ? [userInfo objectForKey:@"processType"] :@"" forKey:@"processType"];
        [resultDic setObject:[userInfo objectForKey:@"result"] ? [userInfo objectForKey:@"result"] :@"" forKey:@"result"];
        //发送更新通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_GrabOrderResult object:resultDic];
    }
    //付款
    if(userInfo && [[userInfo objectForKey:@"processType"] isEqualToString:@"11"])
    {
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
        [resultDic setObject:[userInfo objectForKey:@"orderId"] ? [userInfo objectForKey:@"orderId"] :@"" forKey:@"orderId"];
        [resultDic setObject:[userInfo objectForKey:@"processType"] ? [userInfo objectForKey:@"processType"] :@"" forKey:@"processType"];
        [resultDic setObject:[userInfo objectForKey:@"state"] ? [userInfo objectForKey:@"state"] :@"" forKey:@"state"];
        //发送更新通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_OrderPayResult object:resultDic];
    }
    //司机任务开始推送给车主端
    if(userInfo && [[userInfo objectForKey:@"processType"] isEqualToString:@"22"])
    {
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
        [resultDic setObject:[userInfo objectForKey:@"orderId"] ? [userInfo objectForKey:@"orderId"] :@"" forKey:@"orderId"];
        [resultDic setObject:[userInfo objectForKey:@"processType"] ? [userInfo objectForKey:@"processType"] :@"" forKey:@"processType"];
        //发送更新通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DriverStartTask object:resultDic];
    }
    //司机任务结束推送给车主端
    if(userInfo && [[userInfo objectForKey:@"processType"] isEqualToString:@"23"])
    {
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
        [resultDic setObject:[userInfo objectForKey:@"orderId"] ? [userInfo objectForKey:@"orderId"] :@"" forKey:@"orderId"];
        [resultDic setObject:[userInfo objectForKey:@"processType"] ? [userInfo objectForKey:@"processType"] :@"" forKey:@"processType"];
        //发送更新通知
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DriverEndTask object:resultDic];
    }
}

#pragma mark --- 异常处理
void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    DBG_MSG(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
}


@end







