//
//  BaiDuCarWaitOwner.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/24.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "BaiDuCarWaitOwner.h"
#import "BaiDuCarRouting.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "MapCoordinaterModule.h"
#import "TFCarOrderDetailModel.h"
#import "UIColor+Hex.h"
#import "TravelViewController.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "BaiDuCarViewController.h"
#import "TianfuCarHomeVC.h"
#import "MainViewController.h"
#import "TravelHistoryViewController.h"
#import "CarpoolTravelingViewController.h"



#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"

#define MessageContent @"一次订单只能呼叫一次免费摆渡车,您确定取消呼叫免费摆渡车？"
#define CancelButtonName @"确定取消"
#define OKButtonName @"我再想想"
#define CancelOrder 334

@interface BaiDuCarWaitOwner ()<AMapSearchDelegate,MAMapViewDelegate>{
    
    
    
    NSTimer* timerForRequst;

    TFCarOrderDetailModel* orderDetailModel;
    
    MAPointAnnotation *myPointAnnotation;

    MAPointAnnotation* carPointAnnotation;

    
    BOOL hasPushCarRoutingVC;
    
    BOOL isFirstGetCarLoaction;
}

@property (strong, nonatomic) IBOutlet MAMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *avartorImageView;
@property (strong, nonatomic) IBOutlet UILabel *ownerScores;
@property (strong, nonatomic) IBOutlet UILabel *ownerOrderNumber;
@property (strong, nonatomic) IBOutlet UILabel *ownerStarsNumber;
@property (strong, nonatomic) IBOutlet UILabel *ownerName;
@property (strong, nonatomic) IBOutlet UILabel *ownerBusNumber;
@property (strong, nonatomic) NSString *ownerPhoneNumber;
@property (strong, nonatomic) UILabel * promptLabel;
@property (assign, nonatomic) CGFloat milesNum;//公里数
@property (assign, nonatomic) int     minutesNum;//分钟数
@property (assign, nonatomic) CGFloat userLatitude;
@property (assign, nonatomic) CGFloat userLongitude;
@property (assign, nonatomic) CGFloat driverLatitude;
@property (assign, nonatomic) CGFloat driverLongitude;

//@property (strong,nonatomic)AMapNavigationSearchRequest *searchRequest;
@property (strong,nonatomic)AMapSearchAPI *search;

@property (strong,nonatomic)NSMutableArray *arPolygons;

@end


@implementation BaiDuCarWaitOwner

- (void)dealloc{
    [_mapView removeAnnotation:myPointAnnotation];
    [_mapView removeAnnotation:carPointAnnotation];
    [_mapView removeOverlays:_arPolygons];
    self.mapView.delegate = nil;
    
    [timerForRequst invalidate];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _arPolygons = [[NSMutableArray alloc] init];

    [self initMapView];
    
    [self initPolygon];
    
    [self initProperty];
    
    [self initNavigationItems];
    
//    [self sendNavigationRequest];
    
    [self initRequstTimer];
    [self setOwerInformation];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    hasPushCarRoutingVC = NO;
    isFirstGetCarLoaction = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (_orderId) {
        
        [timerForRequst setFireDate:[NSDate distantPast]];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timerForRequst invalidate];    
}

- (void)initRequstTimer{
    timerForRequst = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(repeatRequest) userInfo:nil repeats:YES];
    [timerForRequst setFireDate:[NSDate distantFuture]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- init User Interface

- (void)initMapView{
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setShowsCompass:NO];
    [_mapView setShowsScale:NO];
    [_mapView setDelegate:self];
    [_mapView setZoomLevel:16];
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow];
    
    myPointAnnotation = [[MAPointAnnotation alloc] init];
    [self.mapView addAnnotation:myPointAnnotation];

    carPointAnnotation = [[MAPointAnnotation alloc] init];
    [_mapView addAnnotation:carPointAnnotation];
    
//    _search = [[AMapSearchAPI alloc] initWithSearchKey:KMapAppKey Delegate:self];
//    
//    _searchRequest = [[AMapNavigationSearchRequest alloc] init];
//    _searchRequest.searchType       = AMapSearchType_NaviDrive;
//    _searchRequest.strategy         = 5;//距离优先
//    _searchRequest.requireExtension = YES;
    

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

- (void)initProperty{
    
    _promptLabel = [[UILabel alloc] init];
    [_promptLabel setCenter:CGPointMake(self.view.center.x, self.view.center.y - 80)];
    [_promptLabel setBounds:CGRectMake(0, 0, 200, 30)];
    [_promptLabel.layer setCornerRadius:10];
    [_promptLabel setClipsToBounds:YES];
    [_promptLabel setTextAlignment:NSTextAlignmentCenter];
    [_promptLabel setBackgroundColor:[UIColor whiteColor]];
    [_promptLabel setFont:[UIFont systemFontOfSize:11]];
    _promptLabel.text = @"正在获取专车位置信息...";
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
    
    self.navigationItem.title = @"等待接驾";
}

//-(void)requstFerryOrderCheck{
//    if (!_orderId || ![_orderId isKindOfClass:[NSString class]]) {
//        return;
//    }
//    
//    NSString *url = [NSString stringWithFormat:@"%@FerryOrderCheck",KServerAddr];
//    [[NetInterface sharedInstance] httpGetRequest:url body:[JsonUtils dictToJson:@{@"orderId":_orderId}] suceeseBlock:^(NSString *msg) {
//        NSDictionary* dic = [JsonUtils jsonToDcit:msg];
//
//    } failedBlock:^(NSError *msg) {
//        
//    }];
//}


- (void)setOwerInformation{

    _ownerName.text = @"";
    _ownerBusNumber.text = @"";
    _ownerOrderNumber.text = @"";
    _ownerScores.text = @"0.0分";
    _ownerOrderNumber.text = [NSString stringWithFormat:@"接单数量:0单"];

    [_avartorImageView setImage:[UIImage imageNamed:@"my_center_head_1"]];

    if (!orderDetailModel) {
        return;
    }

    if (orderDetailModel.driverName && [orderDetailModel.driverName isKindOfClass:[NSString class]]) {
        _ownerName.text = orderDetailModel.driverName;
    }else{
        _ownerName.text = @"未知";
    }
    
    if (orderDetailModel.driverOrderNum) {
        _ownerOrderNumber.text = [NSString stringWithFormat:@"接单数量:%d单",orderDetailModel.driverOrderNum];
    }
    
    if (orderDetailModel.driverScore) {
        _ownerScores.text = [NSString stringWithFormat:@"%.1f分",orderDetailModel.driverScore];
    }
    
    if (orderDetailModel.license && [orderDetailModel.license isKindOfClass:[NSString class]]) {
        _ownerBusNumber.text = orderDetailModel.license;
    }else{
        _ownerBusNumber.text = @"未知";
    }
    
    if (orderDetailModel.driverAvatar && [orderDetailModel.driverAvatar isKindOfClass:[NSString class]]) {
        [_avartorImageView setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,orderDetailModel.driverAvatar]] placeholderImage:[UIImage imageNamed:@"my_center_head_1"]];
    }else{
        [_avartorImageView setImage:[UIImage imageNamed:@"my_center_head_1"]];
    }
    
    if (orderDetailModel.driverPhone && [orderDetailModel.driverPhone isKindOfClass:[NSString class]]) {
        
        _ownerPhoneNumber = orderDetailModel.driverPhone;
    }else{
        
        _ownerPhoneNumber = @"13999999999";
    }
    
    _driverLatitude = orderDetailModel.destinationLatitude;
    _driverLongitude = orderDetailModel.destinationLongitude;
    
    _userLatitude = orderDetailModel.boardingLatitude;
    _userLongitude = orderDetailModel.boardingLongitude;

    
    myPointAnnotation.coordinate = CLLocationCoordinate2DMake(_userLatitude, _userLongitude);
    [self.mapView selectAnnotation:myPointAnnotation animated:YES];
    
    myPointAnnotation.title = _promptLabel.text;
    
    
    [self requstFerryLocation];
}



#pragma mark -- function methods

- (void)repeatRequest{
    [self requstFerryOrderCheckState];
    
    if (orderDetailModel) {
        [self performSelector:@selector(requstFerryLocation) withObject:nil afterDelay:.3];
    }
}

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
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryLocationGet params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{@"rows": @(1),
                        @"busId":@(orderDetailModel.busId)};
    }];
}


#pragma mark -- Button Event

- (void)backButtonClick{
    
    if (_waitTypeId == 3) {
        
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


- (IBAction)onClickPhoneBtn:(id)sender {
    if (orderDetailModel && orderDetailModel.driverPhone && [orderDetailModel.driverPhone isKindOfClass:[NSString class]]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",orderDetailModel.driverPhone]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",orderDetailModel.driverPhone]]];
        }else{
            [MBProgressHUD showTip:@"号码错误!" WithType:FNTipTypeWarning];
        }
    }else{
        [MBProgressHUD showTip:@"号码为空!" WithType:FNTipTypeWarning];
    }
}


//取消叫车
- (void)cancelCallCarButtonClick{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:MessageContent delegate:self cancelButtonTitle:CancelButtonName otherButtonTitles:OKButtonName, nil];
//    [alertView show];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定不叫车了？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark -- alerview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            
            break;
            
        case 1:
        {
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

#pragma mark -- MapView Delegate

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

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
//    _userLatitude  = userLocation.coordinate.latitude;
//    _userLongitude = userLocation.coordinate.longitude;
    
//    _mAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
//    
//    [self.mapView selectAnnotation:_mAnnotation animated:YES];
//    
//    _mAnnotation.title = _promptLabel.text;
    
//    [self sendNavigationRequest];
    
//    self.mapView.showsUserLocation = NO;
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *annotationID = @"annotationreuse";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        
        if (annotationView == nil) {
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        }
        
        if (annotation == myPointAnnotation) {
            annotationView.image = [UIImage imageNamed:@"coordinator_big"];
            annotationView.canShowCallout = YES;
        }else{
            annotationView.image = [UIImage imageNamed:@"inter_car_icon"];
            annotationView.canShowCallout = NO;
        }

        
        annotationView.centerOffset = CGPointMake(0, -18);
        
        return annotationView;
    }
    
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
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

#pragma mark -- searchRequest
- (void)sendNavigationRequest{

    carPointAnnotation.coordinate = CLLocationCoordinate2DMake(_driverLatitude, _driverLongitude);
    
//    _searchRequest.origin = [AMapGeoPoint locationWithLatitude:_driverLatitude longitude:_driverLongitude];
//    _searchRequest.destination = [AMapGeoPoint locationWithLatitude:_userLatitude longitude:_userLongitude];
//    
//    [_search AMapNavigationSearch:_searchRequest];
}


#pragma mark -- searchResponse

//- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
//    
//    _milesNum = ((AMapPath *)(response.route.paths[0])).distance/1000;
//    
//    _minutesNum = (float)(((AMapPath *)(response.route.paths[0])).duration/60);
//    
//    
//    if (_milesNum > 0 || _minutesNum > 0) {
//        _promptLabel.text = [NSString stringWithFormat:@"距您%.1f公里,还剩%d分钟到达",_milesNum, _minutesNum];
//    }else{
//        _promptLabel.text = @"正在获取专车位置信息...";
//    }
//    
//    myPointAnnotation.title = _promptLabel.text;
//    
//    carPointAnnotation.title = @"司机";
//}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error{
    
    
}


#pragma mark -- networking response

- (void)httpRequestFinished:(NSNotification *)notification{
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    int type = resultData.requestType;

    
    [self stopWait];

    //取消订单状态
    if (type == KRequestType_FerryOrder_DelectedOrder) {
        
        if (resultData.resultCode == 0) {
            
            NSLog(@"Delete order = %@", notification.object);
            
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentOrderParamsDefault"];
            
            if (_waitTypeId == 3) {
                
                CarpoolTravelingViewController *travelVC = nil;
                
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    
                    if ([vc isKindOfClass:[CarpoolTravelingViewController class]]) {
                        
                        travelVC = (CarpoolTravelingViewController *)vc;
                    }
                }
                if (travelVC) {
                    [self.navigationController popToViewController:travelVC animated:YES];
                }else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            }else{
                [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
            }
        }else{
            
            //取消失败
            [self showTip:resultData.message WithType:FNTipTypeFailure];
        }
        return;
    }else if (type == KRequestType_FerryOrderCheck){
        
        if ([resultData.data[@"resultState"] intValue] == 1) { //订单是否提交成功 resultState=1成功 0 不成功
            
            if (!orderDetailModel) {
                orderDetailModel = [[TFCarOrderDetailModel alloc] initWithDictionary:resultData.data[@"order"]];
                [self setOwerInformation];
            }
            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]);
            if ([resultData.data[@"order"][@"state"] intValue] == 3){
                [self pushCarRoutingViewContoller];
                //                [self performSelector:@selector(requstFerryOrderCheckState) withObject:nil afterDelay:.3];
            }
        }
        
    }else if (type == KRequestType_FerryLocationGet){
    
        NSArray* listArr = nil;
        if ([[resultData.data allKeys] containsObject:@"list"]) {
            listArr = resultData.data[@"list"];
        }
        if (listArr.count > 0) {
            _driverLatitude = [listArr[0][@"latitude"] doubleValue];
            _driverLongitude = [listArr[0][@"longitude"] doubleValue];
            
            
            
            if (isFirstGetCarLoaction) {
                
                if (myPointAnnotation) {
                    [_mapView removeAnnotation:myPointAnnotation];
                }
                
                MAPointAnnotation* carAnno = [[MAPointAnnotation alloc] init];
                carAnno.coordinate = CLLocationCoordinate2DMake(_driverLatitude, _driverLongitude);
                
                NSArray* carAnnotationArray = [NSArray arrayWithObjects:carAnno, nil];
                
                [_mapView showAnnotations:carAnnotationArray edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
                isFirstGetCarLoaction = NO;
            }
            
            [self sendNavigationRequest];
        }

    }
}

- (void)httpRequestFailed:(NSNotification *)notification{
    
    [super httpRequestFailed:notification];
}


#pragma mark -- Receive APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{

    if ([userInfo[@"processType"] intValue] != 27) {
        return;
    }
    
    if ([userInfo[@"state"] intValue] == 1) {
        [self pushCarRoutingViewContoller];
    }else{
        [MBProgressHUD showTip:((NSDictionary*)userInfo[@"aps"])[@"alert"] WithType:FNTipTypeWarning];
    }
}

- (void)pushCarRoutingViewContoller{
   
    if (hasPushCarRoutingVC) {
        return;
    }
    
    hasPushCarRoutingVC = YES;
    
    BaiDuCarRouting *carRouting = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"carrouting"];
    carRouting.orderId = _orderId;
    carRouting.orderDetailModel = orderDetailModel;
    [self.navigationController pushViewController:carRouting animated:YES];
}

@end
