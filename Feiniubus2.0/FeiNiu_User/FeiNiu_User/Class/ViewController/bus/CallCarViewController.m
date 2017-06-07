//
//  CallCarViewController.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/10.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CallCarViewController.h"
#import "MapViewManager.h"
#import "FNSearchViewController.h"
#import <FNCommon/NSString+CalculateSize.h>
#import "FNLocation.h"

#import "MapCoordinaterModule.h"
#import "ContainsMutable.h"

#import "FNSearchMapViewController.h"
#import "ShuttleStationViewCotroller.h"
#import "LocationObj.h"
#import <MAMapKit/MAGeometry.h>
#import "FNSearchManager.h"
#import "AuthorizeCache.h"

#import "ComTempCache.h"
#import "PushConfiguration.h"

#import <FNNetInterface/FNNetInterface.h>

@interface CallCarViewController ()<MAMapViewDelegate,CalloutViewDelegate,AMapSearchDelegate,UIGestureRecognizerDelegate,FNSearchViewControllerDelegate>
{
    UIButton* annotationBtn;
    
    BOOL isFirstLocation;
    BOOL onlyOnceFree;
    BOOL isMoveMapView;
    
    CLLocationCoordinate2D currentLocationCoord;    //当前用户移动到的位置
    CLLocationCoordinate2D userLocationCood;        //用户定位位置
    
    LocationObj *locationObj;    //当前位置obj- nextController use
    
    BOOL  isAppear;
}
@property (weak, nonatomic) IBOutlet UIView *navView;

@property (strong,nonatomic) AMapSearchAPI *searchAPI;
@property (weak,nonatomic) MAMapView *mapView;

@property (strong,nonatomic)NSMutableArray *arPolygons;
@property (strong,nonatomic)NSMutableArray *arCarAnnotations;

@property (strong, nonatomic)UIGestureRecognizer* gestureRecognizer;

@property(nonatomic,assign)ShuttleStationType shuttleStation;

@end

@implementation CallCarViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isAppear) {
        isAppear = YES;
        
        //在这里加载地图不闪
        _mapView.delegate          = self;
        [_mapView setZoomLevel:16];
        _mapView.frame = CGRectMake(0, 62, ScreenW, self.view.frame.size.height - 62- 44);
        [self.view addSubview:_mapView];
        [self.view sendSubviewToBack:_mapView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    isAppear = NO;
    //获取围栏
    MapCoordinaterModule *mound = [MapCoordinaterModule sharedInstance];
    if (mound.fenceArray && mound.fenceArray.count != 0) {
        [self initPolygon];
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:0.3];
    }
    else {
       [NetManagerInstance sendRequstWithType:EmRequestType_GetFence params:^(NetParams *params) {}];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[[MapViewManager sharedInstance] getMapView] removeOverlays: _arPolygons];
    [[[MapViewManager sharedInstance] getMapView] removeAnnotations:_arCarAnnotations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAppear = YES;
    _arCarAnnotations = [[NSMutableArray alloc] init];
    _arPolygons = [[NSMutableArray alloc] init];
    
    [self initMapview];
  
#ifdef DEBUG
    //{{测试版本自定义功能
    //[self addTestFeature];
    //}}
#endif
}

- (void)initMapview{
    
    _searchAPI = [[MapViewManager sharedInstance] getSearch];
    _searchAPI.delegate = self;
    
    _mapView = [[MapViewManager sharedInstance] getMapView];
    _mapView.frame = CGRectMake(0, 62, ScreenW, self.view.frame.size.height - 62- 44);
    _mapView.userTrackingMode  = 1;
    _mapView.showsUserLocation = YES;
    _mapView.delegate          = self;
    _mapView.showsCompass      = NO;
    _mapView.showsScale        = YES;
    _mapView.rotateEnabled     = NO;
    [_mapView setZoomLevel:16];
    [self.view addSubview:_mapView];
    [self.view sendSubviewToBack:_mapView];
    
    _gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerMapView)];
    _gestureRecognizer.delegate = self;
    [_mapView addGestureRecognizer:_gestureRecognizer];
    
    UIImage* img = [UIImage imageNamed:@"mylocation"];
    annotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    annotationBtn.frame = CGRectMake(0, 0, img.size.width + 10, img.size.height + 10);
    [annotationBtn setImage:img forState:0];
    [self.view addSubview:annotationBtn];
    annotationBtn.center = CGPointMake(_mapView.center.x, _mapView.center.y - annotationBtn.frame.size.height/2);
    
    _calloutView = [[CalloutView alloc] initWithFrame:CGRectMake(0, 0, 185, 58)];
    _calloutView.delegate = self;
    _calloutView.center = CGPointMake(annotationBtn.center.x, annotationBtn.frame.origin.y - _calloutView.frame.size.height/2 + 5);
    [self.view addSubview:_calloutView];
    _calloutView.desStr = @"正在获取位置...";
    isFirstLocation = YES;
}


-(void)dealloc
{
    _searchAPI.delegate = nil;
    _mapView.delegate   = nil;
    _gestureRecognizer.delegate = nil;
    _gestureRecognizer = nil;
    
    [[[MapViewManager sharedInstance] getMapView] removeOverlays: _arPolygons];
    [[[MapViewManager sharedInstance] getMapView] removeAnnotations:_arCarAnnotations];
    [[MapViewManager sharedInstance] clearMapView];
    [[MapViewManager sharedInstance] clearSearch];
}

#pragma mark -- init interface property

//画围栏
- (void)initPolygon{

    MapCoordinaterModule *mound = [MapCoordinaterModule sharedInstance];

    NSArray *coordinateArr = mound.fenceArray;
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

- (IBAction)btnMenuClick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KShowMenuNotification object:nil];
}

- (IBAction)onClickButtons:(UIButton *)sender{
    
    if (![[AuthorizeCache sharedInstance] getAccessToken] || [[[AuthorizeCache sharedInstance] getAccessToken] isEqualToString:@""]) {
        [super toLoginViewController];
        return;
    }
    
    //修改token测试代码
//    NSString *token  = [[AuthorizeCache sharedInstance] getAccessToken];
//    [NetManagerInstance setAuthorization:[[NSString alloc] initWithFormat:@"1Bearer %@",token]];
//    return;

    NSInteger tag = sender.tag -10;
    switch (tag) {
        //汽车站
        case 0:
        {
            //            [self authValidation];
            _shuttleStation = ShuttleStationTypeBus;
            [self performSegueWithIdentifier:@"ShuttleStationViewController" sender:@(_shuttleStation)];
            //记录当前选择的位置
            MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
            coordinateModule.lastLocation = currentLocationCoord;
        }
            break;
        //机场接送
        case 1:
        {
            //            [self authValidation];
            _shuttleStation = ShuttleStationTypeAirport;
            [self performSegueWithIdentifier:@"ShuttleStationViewController" sender:@(_shuttleStation)];
            //记录当前选择的位置
            MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
            coordinateModule.lastLocation = currentLocationCoord;
        }
            break;
        //火车站接送
        case 2:
        {
            //            [self authValidation];
            _shuttleStation = ShuttleStationTypeTrain;
            [self performSegueWithIdentifier:@"ShuttleStationViewController" sender:@(_shuttleStation)];
            //记录当前选择的位置
            MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
            coordinateModule.lastLocation = currentLocationCoord;
        }
            break;
        //定位当前
        case 3:
        {
            if (currentLocationCoord.latitude < 0.1 || currentLocationCoord.longitude < 0.1) {
                return;
            }
            currentLocationCoord = userLocationCood;
            [_mapView setCenterCoordinate:currentLocationCoord animated:YES];
            [_mapView setZoomLevel:16];
            [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.4];
        }
            break;
            
        default:
            break;
    }
}
//点击三个按钮鉴权
-(void)authValidation
{
//    [self startWait];
//    self.isNotAuthBack = YES;
//    [NetManagerInstance sendRequstWithType:EmRequestType_CheckToken params:^(NetParams *params) {
//        params.method = EMRequstMethod_GET;
//    }];
    [self performSegueWithIdentifier:@"ShuttleStationViewController" sender:@(_shuttleStation)];
    //记录当前选择的位置
    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
    coordinateModule.lastLocation = currentLocationCoord;
}

//获取车辆位置
-(void)requstFerryLocation{
    
    if (currentLocationCoord.latitude < 0.1 || currentLocationCoord.longitude < 0.1) {
        [self stopWait];
        return;
    }
    [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedLocation params:^(NetParams *params) {
         params.data = @{@"boardingLatitude":@(currentLocationCoord.latitude),
                        @"boardingLongitude":@(currentLocationCoord.longitude)};
    }];
}


- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    EMRequestType type = resultData.type;
    //车坐标
    if (type == EmRequestType_GetDedicatedLocation) {
        
        NSArray* listArr = resultData.data[@"items"];
        if (_arCarAnnotations.count > 0) {
            [_mapView removeAnnotations:_arCarAnnotations];
        }

        MAMapPoint starPoint = MAMapPointForCoordinate(currentLocationCoord);
        CLLocationDistance minDistance = 0;
        CLLocationCoordinate2D minCoor;
        
        for (int i = 0; i < listArr.count; i++) {
            NSDictionary*dic = listArr[i];

            MAPointAnnotation* carAnno = [[MAPointAnnotation alloc] init];
            carAnno.coordinate = CLLocationCoordinate2DMake([dic[@"latitude"] floatValue], [dic[@"longitude"] floatValue]);
            [_mapView addAnnotation:carAnno];
            [_arCarAnnotations addObject:carAnno];


            MAMapPoint endPoint = MAMapPointForCoordinate(carAnno.coordinate);
            CLLocationDistance distance = MAMetersBetweenMapPoints(starPoint,endPoint);
            if (i == 0 || distance < minDistance) {
                minCoor = carAnno.coordinate;
                minDistance = distance;
            }
        }
        [self routeSearchCLLocationCoordinate:minCoor];
        
    }else if (type == EmRequestType_GetFence){      //获取围栏
    
        MapCoordinaterModule *mound = [MapCoordinaterModule sharedInstance];
        mound.fenceArray = resultData.data[0][@"fences"];
        [self initPolygon];
        
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:0.3];
    }
    else if (type == EmRequestType_CheckToken){
        //跳转页面
        [self performSegueWithIdentifier:@"ShuttleStationViewController" sender:@(_shuttleStation)];
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

//计算最近car 时间
-(void)routeSearchCLLocationCoordinate:(CLLocationCoordinate2D)_coord{
    
    if ((_coord.latitude != 0) && (_coord.longitude != 0)) {
        
        CLLocationCoordinate2D starLocation = currentLocationCoord;
        CLLocationCoordinate2D endLocation = _coord;
        
        if ((starLocation.latitude !=0 && starLocation.longitude) && (endLocation.latitude !=0 && endLocation.longitude != 0)) {
            
            AMapGeoPoint *starPoint = [AMapGeoPoint locationWithLatitude:starLocation.latitude longitude:starLocation.longitude];
            AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:endLocation.latitude longitude:endLocation.longitude];
            
            //高德计算距离
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
                
                NSString *durationStr;
                if (path.duration < 60) {
                    durationStr = @"1";
                }else if (path.duration > 5940) {
                    durationStr = @"99";
                }else{
                    durationStr = [NSString stringWithFormat:@"%ld",path.duration/60];
                }
                self.calloutView.timeStr = durationStr;
            }];
        }
        
    }else{
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
    BOOL isContainsMutable = [coordinateModule isContainsInFenceWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
 
    {//请求地理逆编码
        _calloutView.hidden = NO;
        [self requstFerryLocation];
        AMapReGeocodeSearchRequest *_regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
        _regeoRequest.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        _regeoRequest.requireExtension = YES;
        
        _searchAPI.delegate = self;
        [_searchAPI AMapReGoecodeSearch:_regeoRequest];
    }
    if (!isContainsMutable) {
        [self showTip:@"请选择红色范围内的地点作为上车点!"];
    }
}



#pragma mark - -MAMapViewDelegate-

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    userLocationCood = userLocation.coordinate;
    
    if (isFirstLocation) {
        currentLocationCoord = userLocation.coordinate;
        //        [_mapView setCenterCoordinate:userLocationCood];
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.1];
    }
    isFirstLocation = NO;
}

//- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
//    
//    if ([overlay isKindOfClass:[MAPolygon class]])
//    {
//        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
//        
//        polygonView.lineWidth = .5;
//        polygonView.strokeColor = [UIColor redColor];
//        polygonView.fillColor = [UIColor clearColor];
//        polygonView.lineJoin = kCGLineJoinMiter;//连接类型
//        
//        polygonView.frame = CGRectMake(0, 0, 100, 100);
//        polygonView.backgroundColor = [UIColor redColor];
//        return polygonView;
//    }
//    return nil;
//}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
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
        annotationView.image = [UIImage imageNamed:@"airporttransfer"];
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    if (isMoveMapView) {
        _calloutView.hidden = YES;
        _calloutView.desStr = @"正在获取位置...";
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (isMoveMapView) {
        
        [annotationBtn.layer addAnimation:[self moveAnimation] forKey:nil];
        
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:0.3];
        
        isMoveMapView = NO;
    }
}

#pragma mark - AMapSearchDelegate
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
    
    if(!response.regeocode){
        return ;
    }
    
    //半段是否在围栏中
    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
    BOOL isContainsMutable = [coordinateModule isContainsInFenceWithLatitude:request.location.latitude longitude:request.location.longitude];
    if (isContainsMutable) {
        //记录当前定位位置信息
        locationObj = [LocationObj new];
        locationObj.latitude = @(request.location.latitude);
        locationObj.longitude = @(request.location.longitude);
    }else{
        locationObj = nil;
    }
    
    if(response.regeocode.formattedAddress.length > 0)
    {
        //省市县街道
        NSString *allString = [NSString stringWithFormat:@"%@%@%@%@",response.regeocode.addressComponent.province,
                               response.regeocode.addressComponent.city,
                               response.regeocode.addressComponent.district,
                               response.regeocode.addressComponent.township];
        //去掉省市县街道  得到小区
        NSString *community = [response.regeocode.formattedAddress stringByReplacingOccurrencesOfString:allString withString:@""];
        NSString * appendCommunity = [NSString stringWithFormat:@"我在%@\n",community];
        
        //街道、门牌号
        NSString *streetStr = [NSString stringWithFormat:@"%@%@",response.regeocode.addressComponent.streetNumber.street,response.regeocode.addressComponent.streetNumber.number];
        
        //如果小区  和 地名相同
        NSString *intactString;
        if ([community isEqualToString:streetStr]) {
            intactString = appendCommunity;
        }else{
            intactString = [appendCommunity stringByAppendingString:streetStr];
        }
        
        _calloutView.attributdesStr = [NSString hintStringWithIntactString:intactString hintString:community intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
        
        locationObj.name = community;
        
    }else if (![response.regeocode.addressComponent.neighborhood isEqualToString:@""] || !response.regeocode.formattedAddress)
    {
        NSString *streetStr = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.neighborhood?: @""];
        NSString *addressStr = [NSString stringWithFormat:@"我在%@\n%@%@",streetStr,
                                response.regeocode.addressComponent.streetNumber.street,
                                response.regeocode.addressComponent.streetNumber.number];
        
        _calloutView.attributdesStr = [NSString hintStringWithIntactString:addressStr hintString:streetStr intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
        
        locationObj.name = streetStr;
    }
    else
    {
        _calloutView.desStr = @"获取位置信息失败!";
    }
}

#pragma mark -- calloutview delegate

- (void)jumpAction
{
//    [self performSegueWithIdentifier:@"FNSearchMapViewController" sender:nil];
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
    _calloutView.desStr = @"正在获取位置...";
    
    [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:1];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *identifierStr = segue.identifier;
    ShuttleStationViewCotroller *controller = [segue destinationViewController];

    if ([identifierStr isEqualToString:@"ShuttleStationViewController"]) {

        MapCoordinaterModule *mound = [MapCoordinaterModule sharedInstance];
        if (mound.fenceArray.count == 0) {
            locationObj = nil;
        }
        
        controller.shuttleStation = [sender integerValue];
        controller.defaultLocation = locationObj;
        
    }else if ([identifierStr isEqualToString:@"FNSearchMapViewController"]){
        
        FNSearchMapViewController *searchController = [segue destinationViewController];
        searchController.fnMapSearchDelegate = self;
    }
}

#pragma mark -- receive apns

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
    
}


#pragma mark- 测试版本功能
/**
///////////////////////////////////////////////////////////////////////////
-(void)addTestFeature
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Server" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [btn setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
    btn.frame = CGRectMake(deviceWidth-70, 25, 60, 30);
    [self.navView addSubview:btn];

    [btn addTarget:self action:@selector(testBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)testBtnClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置Server地址" message:@"1.鉴权地址 2.服务地址 3.坐标地址" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        
        UITextField *textFieldAuth = alert.textFields[0];
        UITextField *textFieldSer = alert.textFields[1];
        UITextField *textFieldLoc = alert.textFields[2];

        //重置地址
        [self resetUrlMaps:textFieldSer.text authorize:textFieldAuth.text locationAddr:textFieldLoc.text];
        [UserPreferInstance setTestAuthorizeAddr:textFieldAuth.text];
        [UserPreferInstance setTestServerAddr:textFieldSer.text];
        [UserPreferInstance setTestLocationAddr:textFieldLoc.text];
        
        //清除登录信息
        [[AuthorizeCache sharedInstance] clean];
        [UserPreferInstance setUserInfo:nil];
        [[PushConfiguration sharedInstance] resetAlias];
        [ComTempCache removeObjectWithKey:KeyContactList];
        [NetManagerInstance setAuthorization:@""];
        [self showTipsView:@"请重新登录"];
    }];
    
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        NSString *addr = [UserPreferInstance getTextAuthorizeAddr];
        if (addr && addr.length != 0) {
            textField.text = addr;
        }
        else {
            textField.text = KAuthorizeAddr;
        }
        
        textField.keyboardType = UIKeyboardTypeURL;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        NSString *addr = [UserPreferInstance getTextServerAddr];
        if (addr && addr.length != 0) {
            textField.text = addr;
        }
        else {
            textField.text = KServerAddr;
        }
        
        textField.keyboardType = UIKeyboardTypeURL;
    }];
    
    
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        NSString *addr = [UserPreferInstance getTextLocationAddr];
        if (addr && addr.length != 0) {
            textField.text = addr;
        }
        else {
            textField.text = KServerLocationAddr;
        }
        
        textField.keyboardType = UIKeyboardTypeURL;
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)resetUrlMaps:(NSString*)serverAddr authorize:(NSString*)authorizeAddr locationAddr:(NSString*)locationAddr
{
    [UrlMapsInstance resetUrlMaps:@{
                                    //地图相关
                                    @(EmRequestType_GetFerryBusLocation):    REQUESTURL2(locationAddr, UNI_GetFerryBusLocation),
                                    @(EmRequestType_GetDedicatedLocation):   REQUESTURL2(locationAddr, UNI_GetDedicatedLocation),
                                    @(EmRequestType_GetFence):               REQUESTURL2(locationAddr, UNI_GetFence),
                                    
                                    //基础
                                    @(EmRequestType_Login):                  REQUESTURL2(serverAddr, UNI_Login),
                                    @(EmRequestType_GetVerifyCode):          REQUESTURL2(serverAddr, UNI_VerifyCode),
                                    @(EmRequestType_GetUserInfo):            REQUESTURL2(serverAddr, UNI_UserInfo),
                                    @(EmRequestType_SetUserInfo):            REQUESTURL2(serverAddr, UNI_UserInfo),
                                    @(EmRequestType_GetCoupons):             REQUESTURL2(serverAddr, UNI_GetCounpos),
                                    @(EmRequestType_CarouselIndex):          REQUESTURL2(serverAddr, UNI_CarouselIndex),
                                    @(EmRequestType_ShareContent):           REQUESTURL2(serverAddr, UNI_ShareContent),
                                    @(EmRequestType_CheckToken):             REQUESTURL2(serverAddr, UNI_CheckToken),
                                    
                                    //接送车
                                    @(EmRequestType_GetCommonAddress):       REQUESTURL2(serverAddr, UNI_GetCommonAddress),
                                    @(EmRequestType_GetDateRange):           REQUESTURL2(serverAddr, UNI_GetDateRange),
                                    @(EmRequestType_GetPrice):               REQUESTURL2(serverAddr, UNI_GetPrice),
                                    @(EmRequestType_Feedback):               REQUESTURL2(serverAddr, UNI_Feedback),
                                    
                                    @(EmRequestType_PostDedicatedOrder):     REQUESTURL2(serverAddr, UNI_DedicatedOrder),
                                    @(EmRequestType_GetDedicatedOrder):      REQUESTURL2(serverAddr, UNI_DedicatedOrder),
                                    @(EmRequestType_GetDedicatedList):       REQUESTURL2(serverAddr, UNI_DedicatedOrder),
                                    @(EmRequestType_GetDedicatedAppraise):   REQUESTURL2(serverAddr, UNI_DedicatedAppraise),
                                    @(EmRequestType_PostDedicatedAppraise):  REQUESTURL2(serverAddr, UNI_DedicatedAppraise),
                                    @(EmRequestType_DeleteDedicatedOrder):   REQUESTURL2(serverAddr, UNI_DedicatedOrder),
                                    @(EmRequestType_PostCancelReason):       REQUESTURL2(serverAddr, UNI_DedicatedCancelReason),
                                    @(EmRequestType_GetDedicateRefundPace):  REQUESTURL2(serverAddr, UNI_DedicatedRefundPace),
                                    @(EmRequestType_GetOrderState):          REQUESTURL2(serverAddr, UNI_DedicatedOrderState),
                                    
                                    
                                    //订车票块
                                    @(EmRequestType_StartCity):              REQUESTURL2(serverAddr, UNI_StartCity),
                                    @(EmRequestType_DestinationCity):        REQUESTURL2(serverAddr, UNI_DestinationCity),
                                    @(EmRequestType_DateRange):              REQUESTURL2(serverAddr, UNI_DateRange),
                                    @(EmRequestType_BookingTickets):         REQUESTURL2(serverAddr, UNI_BookingTickets),
                                    @(EmRequestType_PassengerHistory):       REQUESTURL2(serverAddr, UNI_PassengerHistory),
                                    @(EmRequestType_AddPassengerHistory):    REQUESTURL2(serverAddr, UNI_PassengerHistory),
                                    @(EmRequestType_DeletePassengerHistory): REQUESTURL2(serverAddr, UNI_PassengerHistory),
                                    @(EmRequestType_TicketOrderCreate):      REQUESTURL2(serverAddr, UNI_Order),
                                    @(EmRequestType_TicketOrderList):        REQUESTURL2(serverAddr, UNI_Order),
                                    @(EmRequestType_TicketOrderDetail):      REQUESTURL2(serverAddr, UNI_Order),
                                    @(EmRequestType_TicketRefund):           REQUESTURL2(serverAddr, UNI_TicketCancel),
                                    @(EmRequestType_TicketCancel):           REQUESTURL2(serverAddr, UNI_TicketCancel),
                                    @(EmRequestType_TicketOrderTickets):     REQUESTURL2(serverAddr, UNI_TicketInOrder),
                                    @(EmRequestType_TicketRefundRule):       REQUESTURL2(serverAddr, UNI_TicketRefundRule),
                                    @(EmRequestType_TicketRefundPace):       REQUESTURL2(serverAddr, UNI_TicketRefundPace),
                                    
                                    @(EmRequestType_DedicateOrderRemove):    REQUESTURL2(serverAddr, UNI_OrderDelete),
                                    @(EmRequestType_TicketOrderRemove):      REQUESTURL2(serverAddr, UNI_OrderDelete),
                                    
                                    //支付模块
                                    @(EmRequestType_PaymentCreate):          REQUESTURL2(serverAddr, UNI_PaymentCreate),
                                    @(EmRequestType_PaymentCharge):          REQUESTURL2(serverAddr, UNI_PaymentCharge),
                                    @(EmRequestType_PaymentResult):          REQUESTURL2(serverAddr, UNI_PaymentResult),
                                    
                                    
                                    }];
}
 
**/
@end
