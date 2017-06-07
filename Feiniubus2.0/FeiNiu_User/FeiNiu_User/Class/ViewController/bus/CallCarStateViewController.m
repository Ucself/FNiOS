//
//  CallCarStateViewController.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CallCarStateViewController.h"
#import "ContainerViewController.h"
#import "MainViewController.h"
#import "EvaluationViewController.h"
#import "OrderMainViewController.h"
#import "MapViewManager.h"

#import "CallCarTopDriverInfoView.h"
#import "CallCarTopPlaceView.h"
#import "CallCarInfoView.h"
#import "PushNotificationAdapter.h"
#import "CancelledSeasonViewController.h"
#import "RefundTipsView.h"
#import "FeedbackViewController.h"
#import "FNSearchManager.h"
#import <FNCommon/NSTimer+Blocks.h>
#import <FNCommon/NSTimer+Addition.h>

@interface CallCarStateViewController ()<MAMapViewDelegate,UserCustomAlertViewDelegate,AMapSearchDelegate>
{
    __weak IBOutlet UILabel *navTitleLab;
    __weak IBOutlet NSLayoutConstraint *locationButtonTop;
    __weak IBOutlet UIButton *rightButton;
    
    
    UIButton* annotationBtn;
    UIView *maskView;   //遮罩View
    ShuttleModel *shuttleModel;
    
    BOOL cancelOrderNotification;   //取消订单是否收到推送
    
    NSTimer *timer;                 //callcarInfoView 使用
    NSTimer *locationTimer;         //专车位置使用
    NSTimeInterval timerInterval;
    
    MAPointAnnotation* endAnnotation;   //终点大头针
    MAPointAnnotation* starAnnotation;  //起点大头针
    MAPointAnnotation* busLocationAnno; //专车位置
    NSMutableArray *allAnnotaions;      //所有大头针
    
    NSDictionary *busLocationDic;       //当前专车位置集合
}

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

@property(nonatomic,retain)MAMapView *mapView;

@property(nonatomic,retain)CallCarTopDriverInfoView *topDriverView;

@property(nonatomic,retain)CallCarTopPlaceView *topPlaceView;

//中心点 View
@property(nonatomic,retain)CallCarInfoView *callCarInfoView;

@end

@implementation CallCarStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    allAnnotaions = @[].mutableCopy;
    
    [self initMapview];
    [self configCustomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginSendCarNotification:) name:FnPushType_BeginSendCar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginTheRoadNotification:) name:FnPushType_BeginTheRoad object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endCallCarNotification:) name:FnPushType_EndCallCar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefundSuccessNotification:) name:FnPushType_CallCarRefundApply object:nil];
    //添加遮罩View
    maskView = [UIView new];
    maskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.equalTo(0);
        make.bottom.equalTo(0);
        make.right.equalTo(0);
    }];
    
    [self startWait];
    [self fetchOrderInfoRequest];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //关timer
    [timer invalidate];
    timer = nil;
    [locationTimer invalidate];
    locationTimer = nil;
}

- (void)fetchOrderInfoRequest
{
    //查询订单信息
    [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedOrder params:^(NetParams *params) {
        params.data = @{@"orderId":_orderID};
    }];
}

//设置控制器状态  配置界面数据
- (void)setControllerType:(EmShuttleStatus)controllerType
{
    if (_controllerType != controllerType) {
        _controllerType = controllerType;
        
        [_topDriverView removeFromSuperview];
        [_topPlaceView removeFromSuperview];
        
        [self configCustomView];

//暂时不用
//        if (_topPlaceView) {
//            
//            _topPlaceView.startAddressLab.text = shuttleModel.starting;
//            _topPlaceView.endAddressLab.text = shuttleModel.endString;
//            
//            NSString *timeString = @"15";
//            NSString *timeAllString = [NSString stringWithFormat:@"约%@分钟",timeString];
//            _topPlaceView.timeLab.attributedText = [self helpAttributeAllString:timeAllString intact:timeString];
//            
//            NSString *mileageString = [NSString stringWithFormat:@"%.2f",[shuttleModel.mileage doubleValue]/1000];
//            NSString *mileageAllString = [NSString stringWithFormat:@"约%@公里",timeString];
//            _topPlaceView.mileageLab.attributedText = [self helpAttributeAllString:mileageAllString intact:mileageString];
//        }
        if (_topDriverView) {
            [_topDriverView.avatarImage setImageWithURL:[NSURL URLWithString:shuttleModel.driver.avatar] placeholderImage:[UIImage imageNamed:@"menu_header_large"]];
//            _topDriverView.driverInfoLab.text = [NSString stringWithFormat:@"%@ %@",shuttleModel.driver.name,shuttleModel.driver.license];
//            [_topDriverView.gradeView setRating:[shuttleModel.driver.driverLevel floatValue]];
//            
//            _topDriverView.scoreLab.text = [NSString stringWithFormat:@"%@分",shuttleModel.driver.driverLevel];
            
            //拨打电话
            NSString *phone = shuttleModel.driver.phone;
            _topDriverView.clickPhoneAction = ^(){
                if (phone != nil) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phone]]];
                }
            };
        }
    }
}

//配置自定义试图
- (void)configCustomView
{
    switch (_controllerType) {
            //        case EmShuttleStatus_WaitAssgin:         //等待派车
            //        {
            //            navTitleLab.text = @"等待派车";
            //
            //            _topPlaceView = [[CallCarTopPlaceView alloc] init];
            //            _topPlaceView.frame = CGRectMake(10, 10+62, ScreenW-20, 90);
            //            [self.view addSubview:_topPlaceView];
            //
            //            [rightButton setTitle:@"取消用车" forState:UIControlStateNormal];
            //        }
            //            break;
        case EmShuttleStatus_WaitAssgin: 
        case EmShuttleStatus_WaitGetOn:           //等待上车
        {
            navTitleLab.text = @"等待上车";
            
            _topDriverView = [[CallCarTopDriverInfoView alloc] init];
            _topDriverView.frame = CGRectMake(10, 10+62, ScreenW-20, 90);
            [self.view addSubview:_topDriverView];
            
            [rightButton setTitle:@"取消用车" forState:UIControlStateNormal];
        }
            break;
//        case CallCarStateControllerBeginSendCar:        //正在派车
//        {
//            navTitleLab.text = @"正在派车";
//            locationButtonTop.constant = 12;
//            [rightButton setTitle:@"取消用车" forState:UIControlStateNormal];
//        }
//            break;
        case EmShuttleStatus_Processing:        //行进中
        {
            navTitleLab.text = @"行进中";
            
            _topDriverView = [[CallCarTopDriverInfoView alloc] init];
            _topDriverView.frame = CGRectMake(10, 10+62, ScreenW-20, 90);
            [self.view addSubview:_topDriverView];
            
            [rightButton setTitle:@"投诉" forState:UIControlStateNormal];
        }
            break;
        case EmShuttleStatus_ReserveSuccess:        //预约成功
        {
            navTitleLab.text = @"派车成功";
            
            _topDriverView = [[CallCarTopDriverInfoView alloc] init];
            _topDriverView.frame = CGRectMake(10, 10+62, ScreenW-20, 90);
            [self.view addSubview:_topDriverView];
            
            [rightButton setTitle:@"取消用车" forState:UIControlStateNormal];
        }
            break;
            
        case EmShuttleStatus_Finished1: //已完成---未评价
        {
//            ContainerViewController *container = (ContainerViewController *)[[UIApplication sharedApplication].keyWindow.rootViewController presentedViewController];
//            UINavigationController *nav = (UINavigationController *)container.contentViewController;
//            MainViewController *rootVC = [nav.viewControllers firstObject];
//            
//            //显示飞牛行程订单列表
//            UINavigationController *orderNav = rootVC.selectedViewController;
//            OrderMainViewController *orderMainController = [orderNav.viewControllers firstObject];
//            [orderMainController setSelectIndex:0];
//    
//            EvaluationViewController *controller = [EvaluationViewController instanceWithStoryboardName:@"FeiniuOrder"];
//            controller.hasEvaluation = NO;
//            controller.orderId = [shuttleModel.orderId stringValue];
//            
//            [nav setViewControllers:@[rootVC, controller] animated:YES];
//            
//            [self.navigationController popToRootViewControllerAnimated:NO];
            
            EvaluationViewController *controller = [EvaluationViewController instanceWithStoryboardName:@"FeiniuOrder"];
            controller.hasEvaluation = NO;
            controller.orderId = [shuttleModel.orderId stringValue];
            
            NSMutableArray *array =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [array removeObjectAtIndex:array.count-1];
            [array addObject:controller];
            
            [self.navigationController setViewControllers:array animated:YES];
        }
            
        default:
            break;
    }
}

- (void)initMapview{
    
    _mapView = [[MapViewManager sharedInstance] getMapView];
    _mapView.frame = CGRectMake(0, 62, ScreenW, self.view.frame.size.height - 62);
    _mapView.userTrackingMode  = 1;
    _mapView.showsUserLocation = YES;
    _mapView.delegate          = self;
    _mapView.showsCompass      = NO;
    _mapView.showsScale        = YES;
    _mapView.rotateEnabled     = NO;
    _mapView.scrollEnabled     = NO;
    [_mapView setZoomLevel:11];
    [self.view addSubview:_mapView];
    [self.view sendSubviewToBack:_mapView];
    
    _callCarInfoView = [[CallCarInfoView alloc] init];
//    _callCarInfoView.fs_size = CGSizeMake(100, 90);
//    _callCarInfoView.fs_origin = CGPointMake(self.view.fs_centerX - _callCarInfoView.fs_width/2, self.view.fs_centerY-45);
    _callCarInfoView.infoString = nil;
    [self.view addSubview:_callCarInfoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark action

- (IBAction)btnBack:(id)sender {
    [self popViewController];
}

//当前位置
- (IBAction)btnClickCurrentLocation:(id)sender
{
    if ((shuttleModel.sLatitude <= 0.0 || shuttleModel.sLongitude <= 0.0)) {
        return;
    }
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(shuttleModel.sLatitude, shuttleModel.sLongitude)];
}

- (IBAction)rightButtonAction:(UIButton *)sender {
    //行进中--- 投诉
    if (_controllerType == EmShuttleStatus_Processing) {
        
        CancelledSeasonViewController *c = [CancelledSeasonViewController instanceWithStoryboardName:@"FeiniuOrder"];
        c.isComplain = YES;
        [self.navigationController pushViewController:c animated:YES];
        return;
    }
    //取消用车
    NSString *refundMoney = [NSString stringWithFormat:@"退款金额:%.2f元",shuttleModel.canRefundAmount/100.0];
    UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"确定取消用车吗？" message:refundMoney delegate:self buttons:@[@"继续用车",@"取消用车"]];
    [alertView showInView:self.view];
}


#pragma mark 获取车位置
- (void)fetchBusLocation
{
//    if (!shuttleModel.driver.busId || shuttleModel.driver.busId.length == 0) {
//        [self showTipsView:@"专车位置获取失败"];
//        return;
//    }
//    [NetManagerInstance sendRequstWithType:EmRequestType_GetFerryBusLocation params:^(NetParams *params) {
//        params.data =@{@"busId":shuttleModel.driver.busId};
//    }];
}

- (void)starFetchBusLocation
{
    [locationTimer invalidate];
    locationTimer = nil;
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 block:^{
        [self fetchBusLocation];
    } repeats:YES];
    [locationTimer fire];
}

#pragma mark 请求结果
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = notification.object;
    if (resultData.type == EmRequestType_GetDedicatedOrder) {       //获取订单详情
        [self stopWait];
        shuttleModel = [ShuttleModel mj_objectWithKeyValues:resultData.data[@"order"]];
        [self configControllState];
        
        //移除遮罩
        [maskView removeFromSuperview];
    }else if (resultData.type == EmRequestType_DeleteDedicatedOrder){   //退款
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!cancelOrderNotification) {
                [self startWait];
                [NetManagerInstance sendRequstWithType:EmRequestType_GetOrderState params:^(NetParams *params) {
                    params.data = @{@"orderId":_orderID};
                }];
            }
        });
    }else if (resultData.type == EmRequestType_GetOrderState){  //查询订单状态

        [self stopWait];
        if ([resultData.data[@"paymentState"] integerValue] == EmShuttlePayStatus_Refunding) {    //退款成功
           [self pushToCancelledSeasonController];
        }
    }else if (resultData.type == EmRequestType_GetFerryBusLocation){ //专车位置
        
        busLocationDic = resultData.data;
        
        CLLocationDegrees latitude = [busLocationDic[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [busLocationDic[@"longitude"] doubleValue];
        
        if (!busLocationAnno) {
            busLocationAnno = [[MAPointAnnotation alloc] init];
            [_mapView addAnnotation:busLocationAnno];
            [allAnnotaions addObject:busLocationAnno];
        }
//        double lll = ((arc4random()%2 + 1)/100.0);
//        NSLog(@"%f",lll);
        busLocationAnno.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
    
        //计算距离
        [self calculatemMileage];
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

//获取请求成功--根据订单状态配置界面
- (void)configControllState
{
    //是否是及时呼车
    BOOL isReal = [shuttleModel.isReal boolValue];
    //订单状态
    NSInteger orderState = [shuttleModel.orderState integerValue];
    
    self.controllerType = (int)orderState;
    
    
    //如果是预约成功状态 需要区分是否是立即呼车
    [timer invalidate];
    timer = nil;
    switch (orderState) {
        case EmShuttleStatus_ReserveSuccess: //预约成功---分是否立即用车
        {
            if (isReal) {
                [self waitTime];
            }else{
                [self waitStartTrip];
            }
        }
            break;
        case EmShuttleStatus_Processing:    //行进中
        {
            //获取专车位置
            [self starFetchBusLocation];
            
            //地图打2个点 起点 终点
            if (!starAnnotation) {
                starAnnotation = [[MAPointAnnotation alloc] init];
                [_mapView addAnnotation:starAnnotation];
                [allAnnotaions addObject:starAnnotation];
            }
            if (!endAnnotation) {
                endAnnotation = [[MAPointAnnotation alloc] init];
                [_mapView addAnnotation:endAnnotation];
                [allAnnotaions addObject:endAnnotation];
            }
            starAnnotation.coordinate = CLLocationCoordinate2DMake(shuttleModel.sLatitude,shuttleModel.sLongitude);
            endAnnotation.coordinate = CLLocationCoordinate2DMake(shuttleModel.dLatitude,shuttleModel.dLongitude);

        }
            break;
        case EmShuttleStatus_WaitGetOn:     //等待上车
        {
            //获取专车位置
            [self starFetchBusLocation];
        }
            break;
            
        default:
            break;
    }
}



#pragma mark -通知
//接送机派单
- (void)beginSendCarNotification:(NSNotification *)notification
{
    if ([notification.object[@"success"] integerValue] == 1) {
        [self fetchOrderInfoRequest];
        //通知行程列表刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
    }
}

//行程开始
- (void)beginTheRoadNotification:(NSNotification *)notification
{
    if ([notification.object[@"success"] integerValue] == 1) {
        [self fetchOrderInfoRequest];
        //通知行程列表刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
    }
}

//行程结束
- (void)endCallCarNotification:(NSNotification *)notification
{
    if ([notification.object[@"success"] integerValue] == 1) {
        //通知行程列表刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
        [self fetchOrderInfoRequest];
    }
}

//退款
- (void)RefundSuccessNotification:(NSNotification *)notification
{
    [self stopWait];
    cancelOrderNotification = YES;
    if ([notification.object[@"success"] integerValue] == 1) {
        [self pushToCancelledSeasonController];
        //通知行程列表刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
    }else{
        [self showTipsView:@"取消用车失败，请重试！"];
    }
}

- (void)pushToCancelledSeasonController
{
    //由于done 是延迟0.3秒回调所以空白一小段时间
    [RefundTipsView showInfoView:self.view tips:@"您的用车已取消成功" done:^(){
        
//        ContainerViewController *container = (ContainerViewController *)[[UIApplication sharedApplication].keyWindow.rootViewController presentedViewController];
//        UINavigationController *nav = (UINavigationController *)container.contentViewController;
//        MainViewController *rootVC = [nav.viewControllers firstObject];
//        
//        CancelledSeasonViewController *controller = [CancelledSeasonViewController instanceWithStoryboardName:@"FeiniuOrder"];
//        controller.orderID = _orderID;
//        [nav setViewControllers:@[rootVC, controller] animated:YES];
//        
//        [self.navigationController popToRootViewControllerAnimated:NO];
        
        CancelledSeasonViewController *controller = [CancelledSeasonViewController instanceWithStoryboardName:@"FeiniuOrder"];
        controller.orderID = _orderID;
        
        NSMutableArray *array =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [array removeObjectAtIndex:array.count-1];
        [array addObject:controller];
        
        [self.navigationController setViewControllers:array animated:YES];
    }];
}

#pragma mark - Navigation
/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark mapDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if (starAnnotation == annotation) {
        static NSString *annotationID = @"starAnnotationreuse";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        }
        
        annotationView.image = [UIImage imageNamed:@"starLocation"];
        annotationView.canShowCallout = NO;
        annotationView.centerOffset = CGPointMake(0, -18);
        
        return annotationView;
    }
    if (endAnnotation == annotation) {
        static NSString *annotationID = @"endAnnotationreuse";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        }
        
        annotationView.image = [UIImage imageNamed:@"endLocation"];
        annotationView.canShowCallout = NO;
        annotationView.centerOffset = CGPointMake(0, -18);
        
        return annotationView;
    }
    
    //专车
    if (busLocationAnno == annotation) {
        
        static NSString *annotationID = @"annotationreuse";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        }
        
        annotationView.image = [UIImage imageNamed:@"callcar_icon"];
        annotationView.canShowCallout = NO;
        annotationView.centerOffset = CGPointMake(0, -18);
        
        return annotationView;
    }
    return nil;
}

//高德地图路径计算
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (!response.route.paths || response.route.paths.count == 0 || !response.route.paths[0]) {
        
        [self showTipsView:@"网络连接异常，请重试"];
        return;
    }
    
    AMapPath *path = response.route.paths[0];
    
    if ([shuttleModel.orderState integerValue] == EmShuttleStatus_WaitGetOn) {          //等待上车
        //飞牛巴士距离起点提示
        [self showWaitTakeBusWithDistance:path.distance duration:path.duration];
    }else if ([shuttleModel.orderState integerValue] == EmShuttleStatus_Processing){    //行进中
        //飞牛巴士距离终点
        [self showBeginProcessingWithDistance:path.distance duration:path.duration];
    }
}

//计算两点里程
- (void)calculatemMileage
{
    CLLocationCoordinate2D starLocation = CLLocationCoordinate2DMake([busLocationDic[@"latitude"] doubleValue], [busLocationDic[@"longitude"] doubleValue]);
    CLLocationCoordinate2D endLocation;
    if ([shuttleModel.orderState integerValue] == EmShuttleStatus_WaitGetOn) {          //等待上车
        //车距离起点的距离
        endLocation = CLLocationCoordinate2DMake(shuttleModel.sLatitude, shuttleModel.sLongitude);
        
    }else if ([shuttleModel.orderState integerValue] == EmShuttleStatus_Processing){    //行进中
        //车距离终点的距离
        endLocation = CLLocationCoordinate2DMake(shuttleModel.dLatitude, shuttleModel.dLongitude);
    }

    if ((starLocation.latitude !=0 && starLocation.longitude) && (endLocation.latitude !=0 && endLocation.longitude != 0)) {
        
        AMapGeoPoint *starPoint = [AMapGeoPoint locationWithLatitude:starLocation.latitude longitude:starLocation.longitude];
        AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:endLocation.latitude longitude:endLocation.longitude];
        
        //计算距离
        AMapDrivingRouteSearchRequest *routeRequest = [[AMapDrivingRouteSearchRequest alloc] init];
        routeRequest.origin = starPoint;
        routeRequest.destination = endPoint;
        routeRequest.strategy = 2;
        FNSearchManager *manager = [FNSearchManager sharedInstance];
        [manager searchForRequest:routeRequest completionBlock:^(AMapRouteSearchBaseRequest *request, AMapRouteSearchResponse *response, NSError *error) {
            
            if (error || !response.route.paths || response.route.paths.count == 0 || !response.route.paths[0]) {
                [self showTipsView:@"网络连接异常，请重试"];
                return;
            }
            AMapPath *path = response.route.paths[0];
            if ([shuttleModel.orderState integerValue] == EmShuttleStatus_WaitGetOn) {          //等待上车
                //飞牛巴士距离起点提示
                [self showWaitTakeBusWithDistance:path.distance duration:path.duration];
            }else if ([shuttleModel.orderState integerValue] == EmShuttleStatus_Processing){    //行进中
                //飞牛巴士距离终点
                [self showBeginProcessingWithDistance:path.distance duration:path.duration];
            }
            
        }];
    }
}


#pragma mark -help
-(void)dealloc
{
    //释放前改变mapView状态
    _mapView.scrollEnabled     = YES;
    _mapView.userTrackingMode = MAUserTrackingModeNone;
    _mapView.customizeUserLocationAccuracyCircleRepresentation = NO;
    
    [_topDriverView removeFromSuperview];
    [_topPlaceView removeFromSuperview];
    [_callCarInfoView removeFromSuperview];
    
    [[MapViewManager sharedInstance] clearMapView];
    [[MapViewManager sharedInstance] clearSearch];
    [[[MapViewManager sharedInstance] getMapView] removeAnnotations:allAnnotaions];
}

#pragma alertDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    if (btnIndex == 1) {
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_DeleteDedicatedOrder params:^(NetParams *params) {
            params.method = EMRequstMethod_DELETE;
            params.data = @{@"orderId":_orderID};
        }];
    }
}


#pragma mark - timer

-(void)startTripHandleTimer
{

}

//-(void)arriveTimehandleTimer
//{
//    timerInterval--;
//    if (timerInterval < 0) {    //到计时到0
//        
//        // do someThing
//        return;
//    }
//    [self showWaitAssginTime];
//}

//以等待 00:44 ++
-(void)waitTimeHandleTimer
{

}
    
#pragma  mark - test

//等待
-(void)waitStartTrip
{
    NSDate *now = [DateUtils stringToDate:[DateUtils now]];
    NSDate *userDate = [DateUtils stringToDate:shuttleModel.useDate];

    timerInterval = [userDate timeIntervalSinceDate:now];
    
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
        timerInterval--;
        if (timerInterval < 0) {    //到计时到0
            _callCarInfoView.hidden = YES;
            return;
        }
        [self showReserveSuccessTime];
    } repeats:YES];
    [timer fire];
}

//等待时间--递增
- (void)waitTime
{
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
        timerInterval++;
        [self showWaitTime];
    } repeats:YES];
    [timer fire];
}

////距离目的地时间倒计时
//- (void)waitArriveTime
//{
//    NSDate *now = [NSDate date];
//    NSDate *createTime = [DateUtils stringToDate:shuttleModel.createTime];
//
//    timerInterval = [now timeIntervalSinceDate:createTime];
//
//    if (!timer) {
//        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(arriveTimehandleTimer) userInfo:nil repeats:YES];
//    }
//    [timer fire];
//}

//预约成功计时
-(void)showReserveSuccessTime
{
    int hour = (int)(timerInterval/3600);
    int min = (int)(timerInterval - hour*3600)/60;
    int second = timerInterval - hour*3600 - min*60;
    
    MyRange *range = [[MyRange alloc] init];
    range.location = 9;
    range.length   = 2;
    
    MyRange *range1 = [[MyRange alloc] init];
    range1.location = 15;
    range1.length   = 2;
    
    MyRange *range2 = [[MyRange alloc] init];
    range2.location = 21;
    range2.length   = 2;
    
    _callCarInfoView.infoString = [NSString stringWithFormat:@"距离出发时间还剩 %02d 小时 %02d 分钟 %02d 秒", hour, min, second];
    _callCarInfoView.rangs = @[range,range1,range2];
}

//已等待 ++
- (void)showWaitTime
{
    int hour = (int)(timerInterval/3600);
    int min = (int)(timerInterval - hour*3600)/60;
    int second = timerInterval - hour*3600 - min*60;
    
    if (hour > 0) {
        MyRange *range = [[MyRange alloc] init];
        range.location = 4;
        range.length   = 8;
        
        _callCarInfoView.infoString = [NSString stringWithFormat:@"已等待 %02d:%02d:%02d", hour, min, second];
        _callCarInfoView.rangs = @[range];
    }
    else {
        MyRange *range = [[MyRange alloc] init];
        range.location = 4;
        range.length   = 5;
        
        _callCarInfoView.infoString = [NSString stringWithFormat:@"已等待 %02d:%02d", min, second];
        _callCarInfoView.rangs = @[range];
    }
}

//行程中
- (void)showBeginProcessingWithDistance:(NSInteger)distance duration:(NSInteger)duration
{
    NSString *mileage = [NSString stringWithFormat:@"%.2f",distance/1000.0];
    NSString *minutes = [NSString stringWithFormat:@"%ld",duration/60];
    
    MyRange *range = [[MyRange alloc] init];
    range.location = 8;
    range.length   = mileage.length;
    
    MyRange *range1 = [[MyRange alloc] init];
    range1.location = 14+mileage.length;
    range1.length   = minutes.length;
    
    _callCarInfoView.infoString = [NSString stringWithFormat:@"距离目的地还有 %@ 公里,约 %@ 分钟",mileage,minutes];
    _callCarInfoView.rangs = @[range,range1];
}

/**
 *  等待上车
 */
- (void)showWaitTakeBusWithDistance:(NSInteger)distance duration:(NSInteger)duration
{
    NSString *mileage = [NSString stringWithFormat:@"%.2f",distance/1000.0];
    NSString *minutes = [NSString stringWithFormat:@"%ld",duration/60];
    
    MyRange *range = [[MyRange alloc] init];
    range.location = 9;
    range.length   = mileage.length;
    
    MyRange *range1 = [[MyRange alloc] init];
    range1.location = 15+mileage.length;
    range1.length   = minutes.length;
    
    _callCarInfoView.infoString = [NSString stringWithFormat:@"飞牛巴士距您还有 %@ 公里，约 %@ 分钟",mileage,minutes];
    _callCarInfoView.rangs = @[range,range1];
}

- (NSAttributedString *)helpAttributeAllString:(NSString *)allSting intact:(NSString *)intact
{
    return [NSString hintStringWithIntactString:allSting hintString:intact intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
}

////正在派车计时
//-(void)showWaitAssginTime
//{
//    int hour = (int)(timerInterval/3600);
//    int min = (int)(timerInterval - hour*3600)/60;
//    int second = timerInterval - hour*3600 - min*60;
//    
//    if (hour > 0) {
//        MyRange *range = [[MyRange alloc] init];
//        range.location = 11;
//        range.length   = 8;
//        
//        _callCarInfoView.infoString = [NSString stringWithFormat:@"正在为您派车，已等待 %02d:%02d:%02d", hour, min, second];
//        _callCarInfoView.rangs = @[range];
//    }
//    else {
//        MyRange *range = [[MyRange alloc] init];
//        range.location = 11;
//        range.length   = 5;
//        
//        _callCarInfoView.infoString = [NSString stringWithFormat:@"正在为您派车，已等待 %02d:%02d", min, second];
//        _callCarInfoView.rangs = @[range];
//    }
//}
@end
