//
//  RootViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import "CarOwnerRootViewController.h"
#import <FNDataModule/EnvPreferences.h>
#import <FNDataModule/DataVersionCache.h>
#import "ProtocolCarOwner.h"
#import <FNCommon/FNCommon.h>
#import "CarOwnerLoginViewController.h"
#import <FNUIView/MBProgressHUD.h>
#import <FNNetInterface/PushConfiguration.h>


@implementation CarOwnerRootViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    //激光推送车主注册通知
//    [[PushConfiguration sharedInstance] setTag:feiniuBusOwenersTag];
    //系统选择跳转
    [self checkSystem];
    //通知注册
    [self noticeRegistration];
    //检测缓存的数据版本
//    [self checkCacheDateVersion];
    //设置状态颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark ----

-(void)btnBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *  检测系统跳转
 */
-(void)checkSystem
{
    //根据版本号区分是否显示引导页
    NSString *locVer = [[EnvPreferences sharedInstance] getAppVersion];
    //打印当前版本
    DBG_MSG(@"The local version is %@", locVer);
    NSString *curVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
//    if (locVer && [curVer isEqualToString:locVer]) {
        //先跳入主视图
        [self performSegueWithIdentifier:@"toMain" sender:nil];
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
            [[ProtocolCarOwner sharedInstance] setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", userId,token,EMUserRole_CarOwner]];
        }
//    }
//    else {
//        [self performSegueWithIdentifier:@"toGuide" sender:nil];
//        [[EnvPreferences sharedInstance] setAppVersion:curVer];
//    }
}
/**
 *  注册系统图通知
 */
-(void)noticeRegistration
{
    //注册系统通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationEnterBackGround) name:KNotifyEnterBackGround object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationBecomeActive) name:KNotifyBecomeActive object:nil];
    
    //注册网络请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
    
    //弹回登录窗口
    //注册通知弹回登录控制器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLoginControler) name:KNotification_GotoLoginControl object:nil];
}
/**
 *  检测缓存数据版本
 */
-(void)checkCacheDateVersion
{
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_Cache requestType:KRequestType_GetCache];
}

//跳转到登录控制器
-(void)gotoLoginControler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //判断是否是登陆control
        for (UIViewController *tempController in self.navigationController.viewControllers) {
            if ([tempController isKindOfClass:[CarOwnerLoginViewController class]]) {
                [self.navigationController popToViewController:tempController animated:YES];
            }
        }
    });
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_GetCache:
            //获取缓存版本
        {
            if (resultParse.resultCode == 0) {
                NSDictionary *dataDic = resultParse.data;
                //1、查看运营范围是否更新
                NSString *businessScopeVersion = @"";
                //获取数据
                if ([dataDic objectForKey:@"businessScopeVersion"]) {
                    businessScopeVersion = (NSString*)[dataDic objectForKey:@"businessScopeVersion"];
                }
                //对比版本,不一样则更新版本
                if (![[[DataVersionCache sharedInstance] getBusinessScopeVersion] isEqualToString:businessScopeVersion]) {
                    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_BusinessScope requestType:KRequestType_GetBusinessScope];
                }
                //2、检查车辆等级是否有更新
                NSString *vehicleLevelVersion = @"";
                //获取数据
                if ([dataDic objectForKey:@"vehicleLevelVersion"]) {
                    vehicleLevelVersion = (NSString*)[dataDic objectForKey:@"vehicleLevelVersion"];
                }
                //对比版本,不一样则更新版本
                if (![[[DataVersionCache sharedInstance] getVehicleLevelVersion] isEqualToString:vehicleLevelVersion]) {
                    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_VehicleLevel requestType:KRequestType_GetVehicleLevel];
                }
                
                //3、检查车辆类型版本值是否有更新
                NSString *vehicleTypeVersion = @"";
                //获取数据
                if ([dataDic objectForKey:@"vehicleTypeVersion"]) {
                    vehicleTypeVersion = (NSString*)[dataDic objectForKey:@"vehicleTypeVersion"];
                }
                //对比版本,不一样则更新版本
                if (![[[DataVersionCache sharedInstance] getVehicleTypeVersion] isEqualToString:vehicleTypeVersion]) {
                    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_VehicleType requestType:KRequestType_GetVehicleType];
                }
            }
        }
            break;
        case KRequestType_GetBusinessScope:
            //获取经营范围数据
        {
            if (resultParse.resultCode == 0) {
                //                NSLog(@"KRequestType_GetBusinessScope=%@",resultParse.data);
                //存储数据
                if ([resultParse.data objectForKey:@"list"]) {
                    [[DataVersionCache sharedInstance] setBusinessScope:(NSArray *)[resultParse.data objectForKey:@"list"]];
                }
                //存储版本
                if ([resultParse.data objectForKey:@"version"]) {
                    [[DataVersionCache sharedInstance] setBusinessScopeVersion:(NSString *)[resultParse.data objectForKey:@"version"]];
                }
            }
        }
            break;
        case KRequestType_GetVehicleLevel:
            //获取车辆等级数据
        {
            if (resultParse.resultCode == 0) {
                //                NSLog(@"KRequestType_GetVehicleLevel=%@",resultParse.data);
                //存储数据
                if ([resultParse.data objectForKey:@"list"]) {
                    [[DataVersionCache sharedInstance] setVehicleLevel:(NSArray *)[resultParse.data objectForKey:@"list"]];
                }
                //存储版本
                if ([resultParse.data objectForKey:@"version"]) {
                    [[DataVersionCache sharedInstance] setVehicleLevelVersion:(NSString *)[resultParse.data objectForKey:@"version"]];
                }
            }
        }
            break;
        case KRequestType_GetVehicleType:
            //获取车辆类型数据
        {
            if (resultParse.resultCode == 0) {
                //                NSLog(@"KRequestType_GetVehicleType=%@",resultParse.data);
                //存储数据
                if ([resultParse.data objectForKey:@"list"]) {
                    [[DataVersionCache sharedInstance] setVehicleType:(NSArray *)[resultParse.data objectForKey:@"list"]];
                }
                //存储版本
                if ([resultParse.data objectForKey:@"version"]) {
                    [[DataVersionCache sharedInstance] setVehicleTypeVersion:(NSString *)[resultParse.data objectForKey:@"version"]];
                }
            }
        }
            break;
        default:
            break;
    }
    
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    NSError *error = [dict objectForKey:@"error"];
    int type = [[dict objectForKey:@"type"] intValue];
    ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:type];
    
    DBG_MSG(@"httpRequestFailed: resultcode= %d", result.resultCode);
    
    if (result.resultCode == 401 || result.resultCode == 403) {
        //
        [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        //鉴权失效重置token
        [[EnvPreferences sharedInstance] setToken:nil];
        [[EnvPreferences sharedInstance] setUserId:nil];
        
        //故事版
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //登录相关控制器
        UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
        //先进入登录进行测试
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
        //重置别名
        [[PushConfiguration sharedInstance] resetTagAndAlias];
//        //注册通知别名
//        [[PushConfiguration sharedInstance] resetAlias];
//        [[PushConfiguration sharedInstance] resetTag];
        return ;
    }
}

#pragma mark- system notification
-(void)onApplicationEnterBackGround
{
    DBG_MSG(@"Enter");
}

-(void)onApplicationBecomeActive
{
    DBG_MSG(@"Enter");
}



@end







