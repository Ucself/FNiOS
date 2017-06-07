//
//  BaiDuCarWaitOrder.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/23.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "BaiDuCarWaitOrder.h"
#import "CarpoolTravelingViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "PushNotificationAdapter.h"
#import "BaiDuCarWaitOwner.h"
#import "TiFuCarOrderItem.h"
#import "TianFuCarPayVC.h"
#import "MapCoordinaterModule.h"
#import "TianfuCarHomeVC.h"
#import "UIColor+Hex.h"
#import "TravelViewController.h"
#import "MainViewController.h"
#import "TravelHistoryViewController.h"

#define MessageContent @"一次订单只能呼叫一次免费摆渡车,您确定取消呼叫免费摆渡车？"
#define CancelButtonName @"确定取消"
#define OKButtonName @"我再想想"

enum{
    
    WaitOrder_SubmitOrder = 150,
    WaitOrder_CheckOrder,
    WaitOrder_DriverInfo
};

@interface BaiDuCarWaitOrder ()<UIAlertViewDelegate,MAMapViewDelegate>{
    
    NSTimer *_timer;
    
    int secondRight;
    int secondLeft;
    int minuteRight;
    int minuteLeft;
    NSTimer* timerForRequst;
    MAPointAnnotation *myAnnotation;
    
    TiFuCarOrderItem *orderItem;
    
//    MapCoordinaterModule *coordinateModule;
    
//    MAPolygon *ringPolygon;
//    MAPolygon *tianfuPolygon;
    
    
    //NSMutableArray* carAnnotationArray;
    
    BOOL isFirstGetCarLoaction;
}

@property (strong, nonatomic) IBOutlet MAMapView *mapView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) NSString *countTimer;

@property (strong,nonatomic)NSMutableArray *arPolygons;
@property (strong,nonatomic)NSMutableArray *arCarAnnotations;

@end

@implementation BaiDuCarWaitOrder


- (void)dealloc{
    [timerForRequst invalidate];
    [_timer invalidate];
    
    
    [_mapView removeAnnotations:_arCarAnnotations];
    [_mapView removeOverlays:_arPolygons];
    self.mapView.delegate = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _arCarAnnotations = [[NSMutableArray alloc] init];
    _arPolygons = [[NSMutableArray alloc] init];
    isFirstGetCarLoaction = YES;
    
    [self initMapView];
    [self initPolygon];
    [self initNavigationItems];
    [self initProperty];
    

    [self initRequstTimer];

    [self performSelector:@selector(startTimer) withObject:nil afterDelay:.3];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    myAnnotation.title = @"正在为您派单...";
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

    if (_orderId) {
        
        myAnnotation.coordinate = CLLocationCoordinate2DMake(_userLatitude, _userLongitude);
        [self.mapView selectAnnotation:myAnnotation animated:YES];
        
//        NSDictionary* params = @{@"boardingLatitude":@(_userLatitude),
//                                 @"boardingLongitude":@(_userLongitude),
//                                 @"orderId":_orderId,
//                                 @"type":@(_typeId),};
        
        if (_carpoolOrderId) {
            [[NSUserDefaults standardUserDefaults] setObject:_orderId forKey:[NSString stringWithFormat:@"CurrentOrderIdUserDefault_%@",_carpoolOrderId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }        
        
        id defaultValue = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"CarWaitTimeInterval_%@",_orderId]];
        
        if (defaultValue && [defaultValue isKindOfClass:[NSDate class]]) {
            
            NSDate* oldDate = (NSDate*)defaultValue;
            
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:oldDate];
            
            int min = timeInterval/60;
            minuteLeft = min/10;
            minuteRight = min%10;
            
            int second = (int)timeInterval%60;
            secondLeft = second/10;
            secondRight = second%10;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"CarWaitTimeInterval_%@",_orderId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [timerForRequst setFireDate:[NSDate distantPast]];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if (timerForRequst) {
        [timerForRequst invalidate];
    }
    if (_timer) {
        [_timer invalidate];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- init user interface

- (void)initMapView{
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setShowsCompass:NO];
    [_mapView setShowsScale:NO];
    [_mapView setDelegate:self];
    [_mapView setZoomLevel:16];
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow];
    
    myAnnotation = [[MAPointAnnotation alloc] init];
    [self.mapView addAnnotation:myAnnotation];
}

- (void)initPolygon{
    
    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
    
    for (NSDictionary *fenceDic in coordinateModule.fenceArray) {
        
        NSArray *coordinateArr = [fenceDic objectForKey:@"fences"];
        int ringCount   = (int)coordinateArr.count;
        //构造多边形数据对象
        CLLocationCoordinate2D ringCoordinates[ringCount];
        //三环坐标数组
        for (int i = 0; i < ringCount; i++) {
            
            ringCoordinates[i].latitude = [(coordinateArr[i])[@"latitude"] floatValue];
            ringCoordinates[i].longitude = [(coordinateArr[i])[@"longitude"] floatValue];
        }
        
        MAPolygon *ringPolygon = [MAPolygon polygonWithCoordinates:ringCoordinates count:ringCount];
        
        //在地图上添加折线对象
        [_mapView addOverlay: ringPolygon];
        [_arPolygons addObject:ringPolygon];
    }
}

- (void)initNavigationItems{
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLeft setFrame:CGRectMake(0, 0, 20, 15)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnRight setFrame:CGRectMake(0, 0, 60, 15)];
    [btnRight setTitle:@"取消订单" forState:UIControlStateNormal];
    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(cancelCallCarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
    self.navigationItem.title = @"派单中";
}

- (void)initProperty{
    
    _countTimer = [NSString stringWithFormat:@"%d%d:%d%d", minuteLeft, minuteRight, secondLeft,secondRight];
    
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setCenter:CGPointMake(self.view.center.x, self.view.center.y - 80)];
    [_timeLabel setBounds:CGRectMake(0, 0, 200, 30)];
    [_timeLabel.layer setCornerRadius:10];
    [_timeLabel setClipsToBounds:YES];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    [_timeLabel setFont:[UIFont systemFontOfSize:11]];
    [_timeLabel setText:[NSString stringWithFormat:@"正在为您派单，等待%@", _countTimer]];
}


//轮循请求
- (void)initRequstTimer{
    
    timerForRequst = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(repeatRequest) userInfo:nil repeats:YES];
    [timerForRequst setFireDate:[NSDate distantFuture]];
}

//计时
- (void)startTimer{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimeAction) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantPast]];
}


#pragma mark -- Function Method

- (void)jumpToTravilManager{
    
    [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    while (1) {
        
        if (array.count > 2) {
            
            [array removeObjectAtIndex:1];
            
        }else{
            
            break;
        }
    }
    
    self.navigationController.viewControllers = array;
}



#pragma mark - ---http requst---
- (void)repeatRequest{
    [self requstFerryOrderCheckState];
    
    [self performSelector:@selector(requstFerryLocation) withObject:nil afterDelay:.3];


}

//检查订单状态
-(void)requstFerryOrderCheckState{
    
    if (!_orderId || _orderId.length <= 1) {
        return;
    }

    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
        params.data = @{@"orderId":_orderId};
    }];
}


//获取车辆位置
-(void)requstFerryLocation{
    
    if (_userLongitude < 0.1 || _userLongitude < 0.1) {
        return;
    }
        
    [NetManagerInstance sendRequstWithType:KRequestType_FerryLocationGet params:^(NetParams *params) {
        params.data = @{@"boardingLatitude":@(_userLatitude),
                        @"boardingLongitude":@(_userLongitude)};
    }];
}


- (void)requestDeleteOrder{

    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrder_DelectedOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_DELETE;
        params.data = @{@"orderId":_orderId};
    }];
}




#pragma mark - --Button Event--
- (void)startTimeAction{
    
    secondRight ++;
    
    if (minuteRight == 10) {
        
        minuteRight = 0;
        secondLeft  = 0;
        secondRight = 0;
        minuteLeft++;
    }
    
    if (secondLeft == 6) {
        
        secondLeft  = 0;
        secondRight = 0;
        minuteRight ++;
    }
    
    if(secondRight == 10){
        
        secondRight = 0;
        secondLeft ++;
    }
    
    _countTimer = [NSString stringWithFormat:@"%d%d:%d%d", minuteLeft, minuteRight, secondLeft,secondRight];
    
    _timeLabel.text = [NSString stringWithFormat:@"正在为您派单，等待%@", _countTimer];

    myAnnotation.title = _timeLabel.text;
}


- (void)backButtonClick{

    if (_typeId == 3) {

        CarpoolTravelingViewController *travelVC = nil;
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            
            if ([vc isKindOfClass:[CarpoolTravelingViewController class]]) {
                
                travelVC = (CarpoolTravelingViewController *)vc;
            }
        }
        if (travelVC) {
            [self.navigationController popToViewController:travelVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
    }
}

//取消叫车
- (void)cancelCallCarButtonClick{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定不叫车了？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}



#pragma mark -- alerview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:{

        }
            break;
            
        case 1:{

            [self startWait];
            
            [NetManagerInstance sendRequstWithType:KRequestType_FerryOrder_DelectedOrder params:^(NetParams *params) {
                params.method = EMRequstMethod_DELETE;
                params.data = @{@"orderId":_orderId};
            }];
        }

            break;
            
        default:
            break;
    }
}

#pragma mark -- MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    

    if (_userLatitude < 0.1) {
        _userLatitude = userLocation.coordinate.latitude;
        _userLongitude = userLocation.coordinate.longitude;
        
        myAnnotation.coordinate = CLLocationCoordinate2DMake(_userLatitude, _userLongitude);
        [self.mapView selectAnnotation:myAnnotation animated:YES];
        
        [_mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    }
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
        
        polygonView.lineWidth = .5;
        polygonView.strokeColor = [UIColor redColor];
        polygonView.fillColor = [UIColor colorWithHex:0xfe8a5d alpha:.3];
        polygonView.lineJoin = kCGLineJoinMiter;//连接类型
        
        return polygonView;
    }
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *annotationID = @"annotationreuse";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        
        if (annotationView == nil) {
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        }
        
        if (annotation == myAnnotation) {
            annotationView.image = [UIImage imageNamed:@"coordinator_big"];
            annotationView.canShowCallout = YES;
        }else{
            annotationView.image = [UIImage imageNamed:@"inter_car_icon"];
            annotationView.canShowCallout = NO;
        }
        
        annotationView.centerOffset = CGPointMake(0, -18);
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[MAUserLocation class]]){
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"position_coordinator"];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    

}


#pragma mark -- response

- (void)httpRequestFinished:(NSNotification *)notification{
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    int type = resultData.requestType;
    
    [self stopWait];

    //取消订单状态
    if (type == KRequestType_FerryOrder_DelectedOrder) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"CarWaitTimeInterval_%@",_orderId]];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentOrderParamsDefault"];

        [self.navigationController popViewControllerAnimated:YES];

        if (_typeId != 3) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TianfuTravelMangerRefreshNotification" object:nil];
        }
        return;
    }else if (type == KRequestType_FerryOrderCheck){
    
        if ([resultData.data[@"resultState"] intValue] == 1) { //订单是否提交成功 resultState=1成功 0 不成功
            
            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]); //|| [dic[@"order"][@"license"] isKindOfClass:[NSString class]]
            if ([resultData.data[@"order"][@"state"] intValue] == 2){
                [self pushWitingOwerViewControllerOrderID:_orderId];
            }
        }else{
            NSLog(@"--订单是否提交成功 resultState=1成功 0 不成功 当前dic=%@",resultData.data);
        }
    }else if (type == KRequestType_FerryLocationGet){
    
        NSArray* listArr = nil;
        if ([[resultData.data allKeys] containsObject:@"list"]) {
            listArr = resultData.data[@"list"];
        }
        
        if (!listArr || listArr.count == 0) {
            
            [MBProgressHUD showTip:@"所有车都在运营中，请稍后重新下单!" WithType:FNTipTypeWarning withDelay:3.5f];
            
            [self performSelector:@selector(requestDeleteOrder) withObject:nil afterDelay:3.0f];
            
            return ;
        }
        
        if (_arCarAnnotations.count > 0) {
            [_mapView removeAnnotations:_arCarAnnotations];
        }
        
        for (NSDictionary*dic in listArr) {
            MAPointAnnotation* carAnno = [[MAPointAnnotation alloc] init];
            carAnno.coordinate = CLLocationCoordinate2DMake([dic[@"latitude"] floatValue], [dic[@"longitude"] floatValue]);
            [_mapView addAnnotation:carAnno];
            [_arCarAnnotations addObject:carAnno];
        }
        
        if (isFirstGetCarLoaction && _arCarAnnotations > 0) {
            [_mapView showAnnotations:_arCarAnnotations edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
            isFirstGetCarLoaction = NO;
        }
        
    }
    
    switch (type) {
        //提交订单状态
        case WaitOrder_SubmitOrder:
            
            if (resultData.resultCode == 0) {
                [self requstFerryOrderCheckState];
            }else{
//                [MBProgressHUD showTip:notification.object[@"data"][@"message"] WithType:FNTipTypeFailure withDelay:3];
            }
            
            break;
        //检查订单状态
        case WaitOrder_CheckOrder:
            
            break;
            
        default:
            break;
    }
}

- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
    
//    int type = [notification.object[@"type"] intValue];
//    if (type == DeleteRequest) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

#pragma mark -- receive APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
    if ([userInfo[@"processType"] intValue] != 25) {
        return;
    }
    
    DBG_MSG(@"开始push到等待接驾界面");
    
    if ([userInfo[@"state"] intValue] == 1) {

        [self pushWitingOwerViewControllerOrderID:userInfo[@"mainOrderId"]];
        
    }else if ([userInfo[@"state"] intValue] == 2){
        
//        [MBProgressHUD showTip:((NSDictionary*)userInfo[@"aps"])[@"alert"] WithType:FNTipTypeWarning];
        
        [self showTipsView:@"所有的车都在运营中，请稍后重新下单"];

        [self requestDeleteOrder];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (void)pushWitingOwerViewControllerOrderID:(NSString*)_orderID{
    
    if (timerForRequst) {
        [timerForRequst invalidate];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"CarWaitTimeInterval_%@",_orderId]];
    
    BaiDuCarWaitOwner *ownerVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitowner"];
    ownerVC.orderId = _orderID;
    ownerVC.waitTypeId = _typeId;
    [self.navigationController pushViewController:ownerVC animated:YES];
}



- (void)popToOrderListViewController{
    
//    [self.navigationController popViewControllerAnimated:YES];
    
//    TravelHistoryViewController *travelVC = nil;
//    
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        
//        if ([vc isKindOfClass:[TravelHistoryViewController class]]) {
//            
//            travelVC = (TravelHistoryViewController *)vc;
//        }
//    }
//    
//    if (travelVC) {
//        
//        [self.navigationController popToViewController:travelVC animated:YES];
//    }else{
//        
//        TravelHistoryViewController *travelVC = [[UIStoryboard storyboardWithName:@"Travel" bundle:nil] instantiateViewControllerWithIdentifier:@"TravelHistoryViewController"];
//        
//        [self.navigationController pushViewController:travelVC animated:YES];
//    }

    
    [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];


}

@end
