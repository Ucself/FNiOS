//
//  DriverRootViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/12.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverRootViewController.h"
#import "ProtocolDriver.h"
#import <FNUIView/MBProgressHUD.h>
#import "DriverLocationUploadModel.h"
#import "AppDelegate.h"
#import <MAMapKit/MAMapKit.h>
#import <FNCommon/DateUtils.h>
#import "ProtocolDriver.h"
#import "DriverLocationUploadModel.h"


@interface DriverRootViewController ()<MAMapViewDelegate>
{
    //高德地图当前对象
    NSMutableDictionary *_locationDic;
}

@property(nonatomic,strong) NSTimer *timerControl;
//全局只用一个地图对象
@property (nonatomic,strong) MAMapView *mapView;

@end

@implementation DriverRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //激光推送车主注册通知
//    [[PushConfiguration sharedInstance] setTag:feiniuBusDrvierTag];
    //关闭回退手势
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //检查系统
    [self checkSystem];
    //注册通知
    [self noticeRegistration];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //设置地图获取定位
//    _mapView = ((AppDelegate*)[[UIApplication sharedApplication]delegate]).mapView;
    _mapView = [MAMapView new];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ----
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
        //故事版
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //主界面
        UIViewController *mianControl = [storyboard instantiateViewControllerWithIdentifier:@"mainControllerIdent"];
        //进入主控制器
//        [self.navigationController presentViewController:mianControl animated:YES completion:nil];
        [self.navigationController pushViewController:mianControl animated:YES];
        //鉴权查看
        NSString *token = [[EnvPreferences sharedInstance] getToken];
        NSString *userId = [[EnvPreferences sharedInstance] getUserId];
        DBG_MSG(@"The local token and userId is %@+%@", token,userId);
        //查看是否有授权数据，未授权弹出登录窗口
        if (!(token && userId))
        {
            //登录相关控制器
            UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
            //先进入登录进行测试
            [self.navigationController presentViewController:loginNav animated:YES completion:nil];
        }
        else
        {
            //设置鉴权
            [[ProtocolDriver sharedInstance] setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", userId,token,EMUserRole_Driver]];
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
    
    //注册开始任务，结束任务通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(driverStartTaskFinished:) name:KNotification_DriverStartTask object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(driverEndTaskFinished:) name:KNotification_DriverEndTask object:nil];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark --- 处理任务开始结束通知回调通知
/**
 *  任务开始，上传地理位置通知
 *
 *  @param notification 通知回调
 */
-(void)driverStartTaskFinished:(NSNotification *)notification
{
    DriverLocationUploadModel *tempDriverLocationUploadModel =  notification.object;
    ((AppDelegate*)[[UIApplication sharedApplication]delegate]).locationUploadModel = tempDriverLocationUploadModel;
    //请求一次
    [self startTaskControl:nil];
    //时间控制
    if (!_timerControl) {
        _timerControl = [NSTimer scheduledTimerWithTimeInterval:30.f target:self selector:@selector(startTaskControl:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timerControl forMode:NSRunLoopCommonModes];
    }
}
//开始任务
-(void)startTaskControl:(id)sender
{
    //地理位置未更新，直接返回
    if (!_locationDic) {
        return;
    }
    //地理位置未更改无需提交
    if (_locationDic && [[_locationDic objectForKey:@"isUpdate"] isEqualToString:@"0"]) {
        return;
    }
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    DBG_MSG(@"当前时间：%@,执行了一次位置提交",localeDate);
    //提交坐标
    DriverLocationUploadModel *tempDriverLocationUploadModel = ((AppDelegate*)[[UIApplication sharedApplication]delegate]).locationUploadModel;
    //初始化数组
    if (!tempDriverLocationUploadModel.locationsArray) {
        tempDriverLocationUploadModel.locationsArray = [[NSMutableArray alloc] init];
    }
    //复制一份数据出来
    NSMutableDictionary *copyLocationDic = [[NSMutableDictionary alloc] initWithDictionary:_locationDic copyItems:YES];
    [tempDriverLocationUploadModel.locationsArray  addObject:copyLocationDic];
//    //数组转换为json字符串
//    NSError *error = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDriverLocationUploadModel.locationsArray
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData
//                                                 encoding:NSUTF8StringEncoding];
//    //消除空格 消除换行
//    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //拼车还是包车
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:tempDriverLocationUploadModel.orderId forKey:@"OrderId"];
    [requestDic setObject:tempDriverLocationUploadModel.locationsArray forKey:@"locations"];
    if ([tempDriverLocationUploadModel.taskType isEqualToString:@"包车"])
    {
        [[ProtocolDriver sharedInstance] postLocationWithNSDictionary:requestDic urlSuffix:Kurl_CharterLocation requestType:KRequestType_postCharterLocation];
    }
    else if ([tempDriverLocationUploadModel.taskType isEqualToString:@"拼车"])
    {
        [[ProtocolDriver sharedInstance] postLocationWithNSDictionary:requestDic urlSuffix:Kurl_CarpoolLocation requestType:KRequestType_postCarpoolLocation];
    }
    
    //数据已经使用
    [_locationDic setObject:@"0" forKey:@"isUpdate"];
    
}

/**
 *  任务结束，通知
 *
 *  @param notification 通知回调
 */
-(void)driverEndTaskFinished:(NSNotification *)notification
{
    //数据缓存清空
    ((AppDelegate*)[[UIApplication sharedApplication]delegate]).locationUploadModel = nil;
    //记时关闭
    [_timerControl invalidate];
    _timerControl = nil;
}

#pragma mark --- MAMapViewDelegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        DBG_MSG(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        if (!_locationDic) {
            _locationDic = [[NSMutableDictionary alloc] init];
            [_locationDic setObject:@"0" forKey:@"speed"];
        }
        //设置更新的数据
//        [_locationDic setObject:[[NSString alloc] initWithFormat:@"%f,%f" ,userLocation.coordinate.longitude,userLocation.coordinate.latitude] forKey:@"location"];
        [_locationDic setObject:[[NSString alloc] initWithFormat:@"%f" ,userLocation.coordinate.longitude] forKey:@"longitude"];
        [_locationDic setObject:[[NSString alloc] initWithFormat:@"%f" ,userLocation.coordinate.latitude] forKey:@"latitude"];
        [_locationDic setObject:[DateUtils now] forKey:@"time"];
        [_locationDic setObject:@"手写地址" forKey:@"address"];
        //设置地理位置已更新
        [_locationDic setObject:@"1" forKey:@"isUpdate"];
    }
    
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    ResultDataModel *resultParse = (ResultDataModel *)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_postCharterLocation:
        {
            if (resultParse.resultCode == 0) {
                //如果上传成功，清除地理位置
                ((AppDelegate*)[[UIApplication sharedApplication]delegate]).locationUploadModel.locationsArray = [[NSMutableArray alloc] init];
            }
        }
            break;
        case KRequestType_postCarpoolLocation:
        {
            if (resultParse.resultCode == 0) {
                //如果上传成功，清除地理位置
                ((AppDelegate*)[[UIApplication sharedApplication]delegate]).locationUploadModel.locationsArray = [[NSMutableArray alloc] init];
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
        //重置推送
        [[PushConfiguration sharedInstance] resetTagAndAlias];
//        //注销推送
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
