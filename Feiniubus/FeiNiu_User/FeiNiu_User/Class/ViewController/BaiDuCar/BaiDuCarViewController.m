//
//  BaiDuCarViewController.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "BaiDuCarViewController.h"
#import "BaiDuCarWaitOrder.h"
#import "BaiDuCarWaitOwner.h"
#import "CustomAnnotationView.h"
#import "CalloutView.h"
#import "PushNotificationAdapter.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MapViewManager.h"
#import "FNSearchViewController.h"
#import "FNLocation.h"
#import "MapCoordinaterModule.h"
#import "UIColor+Hex.h"
#import "TiFuCarOrderItem.h"
#import "LoginViewController.h"
#import <FNNetInterface/PushConfiguration.h>
#import "ContainsMutable.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
//#import <FNMap/FNSearchViewController.h>

#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"
#define CheckOrderGetRequest [NSString stringWithFormat:@"%@FerryOrderCheck",KServerAddr]

//#define CheckOrderExistType 1999



@interface BaiDuCarViewController ()<MAMapViewDelegate,AMapSearchDelegate,CalloutViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>{
    
    UIButton* annotationBtn;
    
    BOOL isFirstLocation;
    BOOL onlyOnceFree;
    BOOL isMoveMapView;
    
    CLLocationCoordinate2D currentLocationCoord;
    CLLocationCoordinate2D userLocationCood;
    BOOL isContainsMutable;
    
    
}

@property (strong,nonatomic) AMapSearchAPI *searchAPI;
@property (weak,nonatomic) MAMapView *mapView;


@property (strong,nonatomic)NSMutableArray *arPolygons;
@property (strong,nonatomic)NSMutableArray *arCarAnnotations;


@property (strong, nonatomic)UIGestureRecognizer* gestureRecognizer;
@end

@implementation BaiDuCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arCarAnnotations = [[NSMutableArray alloc] init];
    _arPolygons = [[NSMutableArray alloc] init];
    
    [self initMapview];
    
    [self initNavigationItems];
    
    [self initPolygon];
}

-(void)dealloc
{
    //_searchAPI.delegate = nil;
    //_mapView.delegate   = nil;
    _gestureRecognizer.delegate = nil;
    _gestureRecognizer = nil;
    
    [[[MapViewManager sharedInstance] getMapView] removeOverlays: _arPolygons];
    [[[MapViewManager sharedInstance] getMapView] removeAnnotations:_arCarAnnotations];
    [[MapViewManager sharedInstance] clearMapView];
    [[MapViewManager sharedInstance] clearSearch];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
}


#pragma mark -- init interface property

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

- (void)initMapview{
    
//    _searchAPI = ((AppDelegate*)[UIApplication sharedApplication].delegate).search;
    _searchAPI = [[MapViewManager sharedInstance] getSearch];
    _searchAPI.delegate = self;
    
//    _mapView = ((AppDelegate*)[UIApplication sharedApplication].delegate).mapView;
    _mapView = [[MapViewManager sharedInstance] getMapView];
    _mapView.frame = CGRectMake(0, 51, ScreenW, self.view.frame.size.height - 51 - 70);
    _mapView.userTrackingMode  = 1;
    _mapView.showsUserLocation = YES;
    _mapView.delegate          = self;
    _mapView.showsCompass      = NO;
    _mapView.showsScale        = YES;
    _mapView.rotateEnabled     = NO;
    [_mapView setZoomLevel:16];
    [self.view addSubview:_mapView];
    
    
    UIButton* locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(ScreenW - 40, 50, 30, 30);
    [locationBtn setImage:[UIImage imageNamed:@"location_unselected"] forState:0];
    [locationBtn addTarget:self action:@selector(onClickLocationBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    
    
    _gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerMapView)];
    _gestureRecognizer.delegate = self;
    [_mapView addGestureRecognizer:_gestureRecognizer];
    
    UIImage* img = [UIImage imageNamed:@"coord_1"];
    annotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    annotationBtn.frame = CGRectMake(0, 0, img.size.width + 10, img.size.height + 10);
    [annotationBtn setImage:img forState:0];
    [self.view addSubview:annotationBtn];
    annotationBtn.center = CGPointMake(_mapView.center.x, _mapView.center.y - annotationBtn.frame.size.height - 10);
    
    _calloutView = [[CalloutView alloc] initWithFrame:CGRectMake(0, 0, 214, 100)];
    _calloutView.delegate = self;
    _calloutView.center = CGPointMake(annotationBtn.center.x, annotationBtn.frame.origin.y - _calloutView.frame.size.height/2 - 5);
    [self.view addSubview:_calloutView];
    _calloutView.addressLabel.text = @"正在获取位置...";
    isFirstLocation = YES;
    
}


- (void)initNavigationItems{
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLeft setFrame:CGRectMake(0, 0, 20, 15)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    self.navigationItem.title = @"免费接送车";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    isMoveMapView = YES;
    
    return YES;
}

- (void)swipeGestureRecognizerMapView{
    isMoveMapView = YES;
    
    NSLog(@"swipe");
    
}

#pragma mark - -Function Methods
- (NSString *)getGUID{
    
    return [[NSUUID UUID] UUIDString] ;
}


- (void)showTip:(NSString*)tip{
    
    UILabel* myTipLB = (UILabel*)[self.view viewWithTag:1021];
    
    if (myTipLB == nil) {
        myTipLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, ScreenW, 25)];
        myTipLB.font = Font(13);
        myTipLB.hidden = YES;
        myTipLB.tag = 1021;
        myTipLB.textAlignment = NSTextAlignmentCenter;
        myTipLB.textColor = [UIColor whiteColor];
        myTipLB.backgroundColor = [UIColor colorWithRed:1 green:113/255.f blue:75/255.f alpha:1];
        [self.view addSubview:myTipLB];
    }
    
    myTipLB.hidden = NO;
    myTipLB.text = tip;
}

- (void)hiddenTip{
    UILabel* myTipLB = (UILabel*)[self.view viewWithTag:1021];
    if (myTipLB) {
        myTipLB.hidden = YES;
        myTipLB.text = @"";
    }
}



#pragma mark - -button event
- (void)backButtonClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)callBaiduCarButton:(id)sender {
    
    if (!isContainsMutable) {
        [MBProgressHUD showTip:@"请选择红色范围内的地点作为上车点!" WithType:FNTipTypeWarning];
        return;
    }
    
    if (onlyOnceFree == YES) {
        [self sendSubmitOrderRequest];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"亲,您只有一次免费呼叫摆渡车的机会哟~" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


- (void)onClickLocationBtn{
    currentLocationCoord = userLocationCood;
    [_mapView setCenterCoordinate:currentLocationCoord animated:YES];
    [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.4];
}

#pragma mark - -http request--

- (void)sendSubmitOrderRequest{
    
    NSDictionary *paramDic = @{@"action":@(1),
                             @"boarding":_calloutView.addressLabel.text,
                             @"boardingLatitude":@(currentLocationCoord.latitude),
                             @"boardingLongitude":@(currentLocationCoord.longitude),
                             @"type":@(3),
                             @"carpoolOrderId":_orderDetail.orderId,
                             @"amount":@(_orderDetail.tickets.count),
                             @"virtualId":[self getGUID]};
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = paramDic;
    }];
}

//获取车辆位置
-(void)requstFerryLocation{
    
    if (currentLocationCoord.latitude < 0.1 || currentLocationCoord.longitude < 0.1) {
        [self stopWait];
        return;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryLocationGet params:^(NetParams *params) {
        params.data = @{@"boardingLatitude":@(currentLocationCoord.latitude),
                        @"boardingLongitude":@(currentLocationCoord.longitude)};
    }];
}

- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    if (type == KRequestType_FerryOrder) {
        
        if (resultData.resultCode == 0) {
            BaiDuCarWaitOrder *waitOrderVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitorder"];
            waitOrderVC.userLatitude  = currentLocationCoord.latitude;
            waitOrderVC.userLongitude = currentLocationCoord.longitude;
            waitOrderVC.orderId       = [NSString stringWithFormat:@"%@",resultData.data[@"orderId"]];
            waitOrderVC.typeId        = 3;
            waitOrderVC.carpoolOrderId = _orderDetail.orderId;
            [self.navigationController pushViewController:waitOrderVC animated:YES];
            
        }else{
            
            if (resultData.resultCode == 100002) {
                
                //鉴权失效重置token
                [[UserPreferences sharedInstance] setToken:nil];
                [[UserPreferences sharedInstance] setUserId:nil];
                
                // 进入登录界面
                [LoginViewController presentAtViewController:self completion:^{
                    [MBProgressHUD showTip:@"请登录！" WithType:FNTipTypeFailure];
                }callBalck:^(BOOL isSuccess, BOOL needToHome) {
                    
                    if (!isSuccess) {
                        
                    }else if(isSuccess){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
                    }
                }];
                //重置别名
                [[PushConfiguration sharedInstance] resetAlias];
                
            }else {
                
                [self showTip:resultData.message WithType:FNTipTypeFailure];
                
            }
        }
    }else if (type == KRequestType_FerryLocationGet){
        NSArray* listArr = nil;
        
        if ([[resultData.data allKeys] containsObject:@"list"]) {
            listArr = resultData.data[@"list"];
        }
        
        if (_arCarAnnotations.count > 0) {
            [_mapView removeAnnotations:_arCarAnnotations];
        }
        
        
        CLLocation *orig = [[CLLocation alloc] initWithLatitude:currentLocationCoord.latitude  longitude:currentLocationCoord.longitude];
        
        CLLocationCoordinate2D minCoor;
        float minDistance = 0;
        for (int i = 0; i < listArr.count; i++) {
            NSDictionary*dic = listArr[i];
            
            MAPointAnnotation* carAnno = [[MAPointAnnotation alloc] init];
            carAnno.coordinate = CLLocationCoordinate2DMake([dic[@"latitude"] floatValue], [dic[@"longitude"] floatValue]);
            [_mapView addAnnotation:carAnno];
            [_arCarAnnotations addObject:carAnno];
            
            
            CLLocation* dist = [[CLLocation alloc] initWithLatitude:[dic[@"latitude"] floatValue]  longitude:[dic[@"longitude"] floatValue]];
            
            CLLocationDistance kilometers = [orig distanceFromLocation:dist]/1000;
            
            if (i == 0 || kilometers < minDistance) {
                minCoor = carAnno.coordinate;
                minDistance = kilometers;
                //                NSLog(@"minDistance=%f",minDistance);
            }
            
        }
        
        //        CLLocationCoordinate2D temp = _mapView.centerCoordinate;
        //        [_mapView showAnnotations:carAnnotationArray edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:NO];
        //        [_mapView setCenterCoordinate:temp];
        
        
        [self routeSearchCLLocationCoordinate:minCoor];
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [self stopWait];
}


-(void)routeSearchCLLocationCoordinate:(CLLocationCoordinate2D)_coord{
    
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    if ((_coord.latitude != 0) && (_coord.longitude != 0)) {
        
        //        [self startWait];
        
        //        AMapNavigationSearchRequest *request = [[AMapNavigationSearchRequest alloc] init];
        //        request.origin = [AMapGeoPoint locationWithLatitude:currentLocationCoord.latitude longitude:currentLocationCoord.longitude];
        //        request.destination = [AMapGeoPoint locationWithLatitude:_coord.latitude longitude:_coord.longitude];
        //        request.searchType = AMapSearchType_NaviDrive;
        //        request.strategy = 2;//距离优先
        //        request.requireExtension = YES;
        //
        //        //发起路径搜索
        //        [_searchAPI AMapNavigationSearch:request];
    }else{
        [_calloutView setMinuteWithString:[NSString stringWithFormat:@"20分钟"]];
        
        [self stopWait];
    }
}



- (void)refrshCalloutView{
    
    [self hiddenTip];
    
    CLLocationCoordinate2D centerCoordinate = _mapView.region.center;
    currentLocationCoord = centerCoordinate;
    
    if (currentLocationCoord.latitude < 0.1 || currentLocationCoord.longitude < 0.1) {
        return;
    }
    
    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
    
    //    int ringCount   = (int)coordinateModule.ringCoordinateArr.count;
    //
    //    //构造多边形数据对象
    //    CLLocationCoordinate2D ringCoordinates[ringCount];
    //
    //    //三环坐标数组
    //    for (int i = 0; i < ringCount; i++) {
    //        ringCoordinates[i].latitude = [(coordinateModule.ringCoordinateArr[i])[@"latitude"] floatValue];
    //        ringCoordinates[i].longitude = [(coordinateModule.ringCoordinateArr[i])[@"longitude"] floatValue];
    //    }
    
    //默认设置不在围栏里面
    isContainsMutable = NO;
    //再查看是否中围栏里面
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
        //判断是否中中部
        if([ContainsMutable isContainsMutableBoundCoords:ringCoordinates count:ringCount coordinate:centerCoordinate])
        {
            isContainsMutable = YES;
        }
    }
    
    if (isContainsMutable) {
        _calloutView.hidden = NO;
        //[self startWait];
        [self requstFerryLocation];
        
        AMapReGeocodeSearchRequest *_regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];;
        _regeoRequest.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        _regeoRequest.requireExtension = YES;
        
        _searchAPI.delegate = self;
        [_searchAPI AMapReGoecodeSearch:_regeoRequest];
        
    }else{
        [self showTip:@"请选择红色范围内的地点作为上车点!"];
    }
}



#pragma mark - -MAMapViewDelegate-

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
    
    userLocationCood = userLocation.coordinate;
    
    if (isFirstLocation) {
        currentLocationCoord = userLocation.coordinate;
        [_mapView setCenterCoordinate:userLocationCood];
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.1];
    }
    isFirstLocation = NO;
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *annotationID = @"annotationreuse";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        
        if (annotationView == nil) {
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        }
        
        annotationView.image = [UIImage imageNamed:@"inter_car_icon"];
        annotationView.canShowCallout = NO;
        
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



- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    //
    //    FNSearchViewController *vc = [[FNSearchViewController alloc]init];
    //    vc.fnSearchDelegate = self;
    //
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    if (isMoveMapView) {
        _calloutView.hidden = YES;
        _calloutView.addressLabel.text = @"正在获取位置...";
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (isMoveMapView) {
        
        [annotationBtn.layer addAnimation:[self moveAnimation] forKey:nil];
        
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.3];
        
        isMoveMapView = NO;
    }
}



#pragma mark - AMapSearchDelegate

//- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
//    [self stopWait];
//    _milesNum = ((AMapPath *)(response.route.paths[0])).distance/1000;

//    int _minutesNum = (int)(((AMapPath *)(response.route.paths[0])).duration/60);
//
//    _promptLabel.text = [NSString stringWithFormat:@"距您%.1f公里,还剩%d分钟到达",_milesNum, _minutesNum];
//
//    myPointAnnotation.title = _promptLabel.text;
//
//    carPointAnnotation.title = @"司机";

//    [_calloutView setMinuteWithString:[NSString stringWithFormat:@"%d分钟",_minutesNum + 5]];

//}

/**
 *  搜索错误回调
 *
 *  @param request
 *  @param error
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    DBG_MSG(@"AMapSearchRequest:error-->:%@",error);
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    if(response.regeocode != nil){
        
        if (![response.regeocode.addressComponent.neighborhood isEqualToString:@""] || ![response.regeocode.addressComponent.building isEqualToString:@""])
        {
            _calloutView.addressLabel.text = [NSString stringWithFormat:@"%@%@",
                                              response.regeocode.addressComponent.neighborhood?: @"",
                                              response.regeocode.addressComponent.building?: @""];
            
        }
        else if(response.regeocode.formattedAddress.length > 0)
        {
            _calloutView.addressLabel.text = response.regeocode.formattedAddress;
        }
        else
        {
            _calloutView.addressLabel.text = @"获取位置信息失败!";
        }
        
    }
    [self stopWait];
    
}

#pragma mark -- calloutview delegate

- (void)jumpAction{

    FNSearchViewController *vc = [[FNSearchViewController alloc]init];
    vc.fnSearchDelegate = self;
    

    [self.navigationController pushViewController:vc animated:YES];
    
}


- (CABasicAnimation *)moveAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y" ];
    animation.fromValue = [NSNumber numberWithFloat:- 10];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = .3;
    animation.removedOnCompletion = YES ; //yes 的话，又返回原位置了。
    animation.repeatCount = 1 ;//MAXFLOAT
    animation.fillMode = kCAFillModeForwards ;
    return animation;
}


#pragma mark -- alerview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    onlyOnceFree = YES;
    
}


#pragma mark -
#pragma mark - FNSearchViewControllerDelegate -
- (void)searchViewController:(FNSearchViewController *)searchViewController didSelectLocation:(FNLocation *)location{
    isMoveMapView = NO;

    [_mapView setCenterCoordinate:location.coordinate animated:YES];
    
    _calloutView.hidden = YES;
    _calloutView.addressLabel.text = @"正在获取位置...";
    
    [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:1];
}




#pragma mark -- receive apns

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
    
}

@end
