//
//  FNSearchMapViewController.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/23.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "FNSearchMapViewController.h"

#import "FNLocation.h"
#import "CalloutSearchView.h"
#import "FNSearchViewController.h"
#import "MapCoordinaterModule.h"
#import "MapViewManager.h"
#import "ContainsMutable.h"

//#import "CityObj.h"
#import "CityInfoCache.h"
#import "FeiNiu_User-Swift.h"

#import "FeiNiu_User-Swift.h"
@interface FNSearchMapViewController()<UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate,MAMapViewDelegate,AMapLocationManagerDelegate,UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIView *mapSuperView;
    __weak IBOutlet UITableView *myTableView;
    __weak IBOutlet UILabel *navTitleLab;
    __weak IBOutlet UIView *tableBackView;

    __weak IBOutlet UIView *outCenterView;
    //选择城市按钮
    __weak IBOutlet UIButton *selectCityButton;
    __weak IBOutlet UIButton *inputButton;
    

    CalloutSearchView *calloutView;
    UIButton *annotationBtn;
    
    
    BOOL isMoveMapView;
    
    BOOL isNeedPop;         //是否需要回弹
    
    BOOL isChangeCity;
}

@property (strong,nonatomic) AMapSearchAPI *searchAPI;
@property (strong,nonatomic) MAMapView *mapView;
@property (strong,nonatomic) AMapLocationManager *locationManager;
@property (nonatomic, copy)  AMapLocatingCompletionBlock completionBlock;
@property (strong,nonatomic) UIGestureRecognizer* gestureRecognizer;

@property (copy, nonatomic) FNLocation *curLocation;
@property (strong, nonatomic) NSMutableArray *locations;
@end

@implementation FNSearchMapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    myTableView.tableFooterView = [UIView new];
    [self refreshUI];
    
    [self initMapView];
    [self initAnnotationView];
    [self initCompleteBlock];

    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citySelectedChange:) name:KChangeCityNotification object:nil];
    
    //初始定位位置
    FNLocation *location = [CityInfoCache sharedInstance].curLocation;
    if (self.isShuttleBus) {
        if (location) {
            if ([[location.adCode substringToIndex:4] isEqualToString:[self.adcode substringToIndex:4]]) {
                //相同城市定位
                [self refreshFences];
                [self location];
            }
            else {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    //地图第一次指定城市需要定位一次才能显示, 不清楚原因
                    [self refreshFences];
                    [self location];
                });
                //直接显示指定城市位置
                [self setCityWithAdcode:self.adcode];
                [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.4];
            }
        }
        else {
            [self refreshFences];
            [self location];
        }
    }
    else {
        [self location];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isChangeCity) {
        isChangeCity = NO;
        if (_isShuttleBus) {
            [self setCityWithAdcode:[CityInfoCache sharedInstance].shuttleCurCity.adcode];
        }
        else {
            [self setCityWithAdcode:[CityInfoCache sharedInstance].commuteCurCity.adcode];
        }
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isNeedPop = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!isNeedPop && _fnMapSearchDelegate && [_fnMapSearchDelegate respondsToSelector:@selector(searchMapViewController:didSelectLocation:)])
    {
        [_fnMapSearchDelegate searchMapViewController:self didSelectLocation:self.curLocation];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)dealloc{
    _gestureRecognizer.delegate = nil;
    _gestureRecognizer = nil;
    
    [[MapViewManager sharedInstance] clearMapView];
    [[MapViewManager sharedInstance] clearSearch];
    //停止定位
    [self.locationManager stopUpdatingLocation];
    [self.locationManager setDelegate:nil];
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KChangeCityNotification object:nil];
}

#pragma mark - map&location
- (void)refreshUI{
    
    self.view.backgroundColor  = UIColor_Background;
    //navTitleLab.text = _navTitle;
    
    if (self.type == 1 || self.type == 3 || self.type == 5) {
        navTitleLab.text = @"选择下车地点";
        [inputButton setTitle:@"去哪儿?" forState:UIControlStateNormal];
    }
    else {
        navTitleLab.text = @"选择上车地点";
        [inputButton setTitle:@"在哪上车?" forState:UIControlStateNormal];
    }
    
    //设置城市名称]
    NSString *cityName;
    if (_isShuttleBus) {
        cityName = [CityInfoCache sharedInstance].shuttleCurCity.city_name;
    }
    else {
        cityName = [CityInfoCache sharedInstance].commuteCurCity.city_name;
    }
    [selectCityButton setTitle:cityName forState:UIControlStateNormal];
}
- (void)initMapView
{

    //地图
    _mapView = [[MapViewManager sharedInstance] getMapView];
    _mapView.frame = CGRectMake(0, 0, mapSuperView.frame.size.width,mapSuperView.frame.size.height);
    _mapView.delegate  = self;
    _mapView.rotateEnabled = NO;
    _mapView.rotateCameraEnabled = NO;
    [mapSuperView addSubview:_mapView];
    
    //搜索
    _searchAPI = [[MapViewManager sharedInstance] getSearch];
    _searchAPI.delegate = self;
    
    //地图上的滑动手势
    _gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerMapView)];
    _gestureRecognizer.delegate = self;
    [_mapView addGestureRecognizer:_gestureRecognizer];
    
//    CityObj *city = [CityInfoCache sharedInstance].currentCity;
//    [self.mapView setZoomLevel:12.1 animated:NO];
//    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(city.central_latitude, city.central_longitude) animated:NO];

}

-(void)mapLocationValidate
{
    if (self.locationManager == nil) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = self;
        //设置期望定位精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //设置不允许系统暂停定位
        [_locationManager setPausesLocationUpdatesAutomatically:NO];
        //设置定位超时时间
        [_locationManager setLocationTimeout:6];
        //设置逆地理超时时间
        [_locationManager setReGeocodeTimeout:4];
    }
}

-(void)location
{
    [self mapLocationValidate];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

-(void)initAnnotationView
{
    [mapSuperView layoutIfNeeded];
    UIImage* img = [UIImage imageNamed:@"icon_PLB_myself"];
    annotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:annotationBtn];
    
    annotationBtn.bounds = CGRectMake(0, 0, img.size.width + 10, img.size.height + 10);
    annotationBtn.center = CGPointMake(_mapView.center.x, _mapView.center.y + 45);
    [annotationBtn setImage:img forState:0];
    
    calloutView = [[CalloutSearchView alloc] initWithFrame:CGRectMake(0, 0, 185, 58)];
    calloutView.center = CGPointMake(annotationBtn.center.x, annotationBtn.frame.origin.y - calloutView.frame.size.height/2 + 5);
    [self.view addSubview:calloutView];
    calloutView.desStr = @"正在获取位置...";
}

- (void)initCompleteBlock
{
    __weak FNSearchMapViewController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error){
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            //如果为定位失败的error，则不进行annotation的添加
            if (error.code == AMapLocationErrorLocateFailed){
                return;
            }
        }
        
        
        __strong FNSearchMapViewController *strongSelf = weakSelf;
        //如果定位与所选城市相同, 则显示定位位置, 否则显示所选城市位置
        if ([[strongSelf.adcode substringToIndex:4] isEqualToString:[regeocode.adcode substringToIndex:4]]) {
            if (location){
                
                [strongSelf.mapView setZoomLevel:15.1 animated:NO];
                [strongSelf.mapView setCenterCoordinate:location.coordinate animated:YES];
                [strongSelf performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.4];
            }
        }
        else {
            [strongSelf.mapView setZoomLevel:12.1 animated:NO];
            [strongSelf.mapView setCenterCoordinate:strongSelf.coordinate animated:YES];
            [strongSelf performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.4];
        }

    };
}

- (void)refrshCalloutView
{
    calloutView.hidden = NO;

    CLLocationCoordinate2D centerCoordinate = _mapView.region.center;
    BOOL isContainsMutable = [self isInBoundFences:centerCoordinate];
    myTableView.hidden = !isContainsMutable;
    outCenterView.hidden = isContainsMutable;
    
    if (isContainsMutable) {
        AMapReGeocodeSearchRequest *_regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];;
        _regeoRequest.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        _regeoRequest.requireExtension = YES;
        _searchAPI.delegate = self;
        [_searchAPI AMapReGoecodeSearch:_regeoRequest];
        [self.locations removeAllObjects];
        [myTableView reloadData];
    }
    else {
        DBG_MSG(@"不在围栏内!!");
        self.curLocation = nil;
        calloutView.desStr = @"请选择红色范围内的地点作为上车点!";
    }
}

-(BOOL)isInBoundFences:(CLLocationCoordinate2D)coordinate
{
    BOOL ret = NO;
    if (!self.isShuttleBus) {
        //通勤车没有围栏
        return YES;
    }
    
    NSArray *arFences = [CityInfoCache sharedInstance].arFences;
//    if (!arFences || arFences.count == 0) {
//        //没有围栏数据直接返回
//        return YES;
//    }
    
    for (FenceObj *fenceObj in arFences) {
        
        NSArray *coordinateArr = fenceObj.coordinates;
        int ringCount   = (int)coordinateArr.count;
        //构造多边形数据对象
        CLLocationCoordinate2D ringCoordinates[ringCount];
        for (int i = 0; i < ringCount; i++) {
            CoordinateObj *fence = coordinateArr[i];
            ringCoordinates[i].latitude = fence.latitude;
            ringCoordinates[i].longitude = fence.longitude;
        }
        
        if ([ContainsMutable isContainsMutableBoundCoords:ringCoordinates count:ringCount coordinate:coordinate]) {
            ret = YES;
            break;
        }
    }
    
    return ret;
}


#pragma mark- actions
//选择城市
- (IBAction)clickSeletedCItyAction:(UIButton *)sender
{
    //是用不了基类方法
//    ShuttleBusSelectCityViewController *selectCityViewController = ShuttleBusSelectCityViewController.instanceWithStoryboardName(@"ShuttleBus");
    //跳转城市列表
    isNeedPop = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShuttleBus" bundle:nil];
    ShuttleBusSelectCityViewController *selectCityViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShuttleBusSelectCityViewController"];
    selectCityViewController.isShuttleBus = self.isShuttleBus;
    [self.navigationController pushViewController:selectCityViewController animated:YES];
}

//搜索关键字
- (IBAction)clickSearchListAction:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"FNSearchViewController" sender:nil];
}

- (IBAction)clickBackAction:(UIButton *)sender
{
    [self popViewController];
}

- (IBAction)clickCurrentLocationAction:(UIButton *)sender
{
    //初始化时候地图移动了
    isMoveMapView = YES;
    calloutView.desStr = @"正在获取位置...";
    
    [self location];
}

#pragma mark- Notification


-(void)citySelectedChange:(NSNotification* )sender{
    
    if (_isShuttleBus) {
        if (self.adcode == [CityInfoCache sharedInstance].shuttleCurCity.adcode) {
            return;
        }
    }
    else {
        if (self.adcode == [CityInfoCache sharedInstance].commuteCurCity.adcode) {
            return;
        }
    }
    
    
    if (self == self.navigationController.viewControllers.lastObject) {
        if (_isShuttleBus) {
            [self setCityWithAdcode:[CityInfoCache sharedInstance].shuttleCurCity.adcode];
        }
        else {
            [self setCityWithAdcode:[CityInfoCache sharedInstance].commuteCurCity.adcode];
        }
    }
    else {
        NSLog(@"不在最顶层, viewWillAppear中设置");
        isChangeCity = YES;
    }
    
}

-(void)setCityWithAdcode:(NSString*)adcode
{
    //刷新界面
    [self refreshUI];
    //围栏
    [self refreshFences];
    //
    self.adcode = adcode;
    //设置地图中心点
    if (_isShuttleBus) {
        self.coordinate =CLLocationCoordinate2DMake([CityInfoCache sharedInstance].shuttleCurCity.central_latitude, [CityInfoCache sharedInstance].shuttleCurCity.central_longitude);
    }
    else {
        self.coordinate =CLLocationCoordinate2DMake([CityInfoCache sharedInstance].commuteCurCity.central_latitude, [CityInfoCache sharedInstance].commuteCurCity.central_longitude);
    }
    
    
    [self.mapView setZoomLevel:12.1 animated:NO];
    [self.mapView setCenterCoordinate:self.coordinate animated:YES];
    
    calloutView.desStr = @"正在获取位置...";

}

#pragma mark- tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *cellIdentifier = @"cellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        cell.backgroundColor = UIColor_Background;

        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            //加线
            UIView *lineView  = [[UIView alloc] init];
            [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
            
            [cell addSubview:lineView];
            [lineView makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(cell);
                make.left.equalTo(cell).offset(14);
                make.right.equalTo(cell);
                make.height.equalTo(0.5);
            }];
        }
    
        if (self.locations.count >= 1) {
            
            FNLocation *location = self.locations[indexPath.row];
            cell.textLabel.text = location.name;
            cell.textLabel.textColor = UITextColor_Black;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            
            cell.detailTextLabel.text = location.address;
            cell.detailTextLabel.textColor = UITextColor_DarkGray;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        }
    
    
    
    
        return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.curLocation = self.locations[indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    isMoveMapView = YES;
    
    return YES;
}

- (void)swipeGestureRecognizerMapView
{
    isMoveMapView = YES;
}

#pragma mark-  map

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    if (isMoveMapView) {
        calloutView.hidden = YES;
        calloutView.desStr = @"正在获取位置...";
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (isMoveMapView) {
    
        [annotationBtn.layer addAnimation:[self moveAnimation] forKey:nil];
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.3];
        isMoveMapView = NO;
    }
    //[self.mapView setZoomLevel:16.0 animated:NO];
}

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
    
    if(response.regeocode == nil){
        DBG_MSG(@"逆地理编码失败");
        [self stopWait];
        return;
    }
    
    self.locations = [NSMutableArray new];
    [response.regeocode.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FNLocation *location = [[FNLocation alloc] init];
        location.name = obj.name;
        location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        location.address = obj.address;
        location.cityCode = obj.citycode;
        location.adCode = obj.adcode;
        location.latitude = obj.location.latitude;
        location.longitude = obj.location.longitude;
        [self.locations addObject:location];
    }];
    
    
    [myTableView reloadData];
    
    if (self.locations.count != 0) {
        FNLocation *item = self.locations[0];
        
        NSString *allAdress = [NSString stringWithFormat:@"我在%@\n%@", item.name, item.address];
        calloutView.attributdesStr = [NSString hintStringWithIntactString:allAdress hintString:item.name intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
    }
    
    
//    if (response.regeocode.aois && response.regeocode.aois.count != 0) {
//        AMapAOI *aoi = response.regeocode.aois[0];
//        NSString *name = aoi.name;
//        NSString *adress = [NSString stringWithFormat:@"%@%@", response.regeocode.addressComponent.streetNumber.street, response.regeocode.addressComponent.streetNumber.number];
//        
////        self.curLocation = [[FNLocation alloc] init];
////        self.curLocation.name = name;
////        self.curLocation.address = adress;
////        self.curLocation.longitude = aoi.location.longitude;
////        self.curLocation.latitude  = aoi.location.latitude;
//        
//        NSString *allAdress = [NSString stringWithFormat:@"我在%@\n%@", name, adress];
//        calloutView.attributdesStr = [NSString hintStringWithIntactString:allAdress hintString:name intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
//    }
//    else {
//        if (![response.regeocode.addressComponent.neighborhood isEqualToString:@""] || !response.regeocode.formattedAddress)
//        {
//            NSString *streetStr = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.neighborhood?: @""];
//            NSString *addressStr = [NSString stringWithFormat:@"我在%@\n%@%@",streetStr,
//                                    response.regeocode.addressComponent.streetNumber.street,
//                                    response.regeocode.addressComponent.streetNumber.number];
//            
//            calloutView.attributdesStr = [NSString hintStringWithIntactString:addressStr hintString:streetStr intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
//            
////            self.curLocation = [[FNLocation alloc] init];
////            self.curLocation.name = streetStr;
////            self.curLocation.address = [NSString stringWithFormat:@"%@%@", response.regeocode.addressComponent.streetNumber.street, response.regeocode.addressComponent.streetNumber.number];
////            self.curLocation.longitude = response.regeocode.addressComponent.streetNumber.location.longitude;
////            self.curLocation.latitude  = response.regeocode.addressComponent.streetNumber.location.latitude;
//            
//        }
//        else if(response.regeocode.formattedAddress.length > 0)
//        {
//            //省市县街道
//            NSString *allString = [NSString stringWithFormat:@"%@%@%@%@",response.regeocode.addressComponent.province,
//                                   response.regeocode.addressComponent.city,
//                                   response.regeocode.addressComponent.district,
//                                   response.regeocode.addressComponent.township];
//            //去掉省市县街道  得到小区
//            NSString *community = [response.regeocode.formattedAddress stringByReplacingOccurrencesOfString:allString withString:@""];
//            NSString * appendCommunity = [NSString stringWithFormat:@"我在%@\n",community];
//            
//            //街道、门牌号
//            NSString *streetStr = [NSString stringWithFormat:@"%@%@",response.regeocode.addressComponent.streetNumber.street,response.regeocode.addressComponent.streetNumber.number];
//            
//            calloutView.attributdesStr = [NSString hintStringWithIntactString:[appendCommunity stringByAppendingString:streetStr] hintString:community intactColor:[UIColor colorWithWhite:0.510 alpha:1.000] hintColor:[UIColor colorWithRed:1.000 green:0.400 blue:0.161 alpha:1.000]];
//            
////            self.curLocation = [[FNLocation alloc] init];
////            self.curLocation.name = streetStr;
////            self.curLocation.address = [NSString stringWithFormat:@"%@%@", response.regeocode.addressComponent.streetNumber.street, response.regeocode.addressComponent.streetNumber.number];
////            self.curLocation.longitude = response.regeocode.addressComponent.streetNumber.location.longitude;
////            self.curLocation.latitude  = response.regeocode.addressComponent.streetNumber.location.latitude;
//        }
//        else
//        {
//            calloutView.desStr = @"获取位置信息失败!";
//        }
//    }

    [self stopWait];
    
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *polylineRenderer = [[MAPolygonRenderer alloc] initWithPolygon:(MAPolygon*)overlay];
        polylineRenderer.lineWidth    = 1.0f;
        polylineRenderer.strokeColor  = [UIColor clearColor];
        polylineRenderer.fillColor    = [UIColor colorWithHex:0xFE8A5D alpha:.2];
        polylineRenderer.lineJoinType = kMALineJoinMiter;
        
        return polylineRenderer;
    }
    return nil;
}

#pragma mark -arguments


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FNSearchViewController"]) {
        FNSearchViewController *searchController = [segue destinationViewController];
        searchController.fnSearchDelegate = self;
        searchController.navTitle = navTitleLab.text;
        searchController.searchMapViewDelegate = self.fnMapSearchDelegate;
        searchController.isShuttleBus = self.isShuttleBus;
        isNeedPop = YES;
    }
}


#pragma mark - 围栏
-(void)refreshFences
{
    [self httpGetFences];
//    NSArray *arFences = [CityInfoCache sharedInstance].arFences;
//    if (!arFences || arFences.count == 0) {
//        [self httpGetFences];
//    }
//    else {
//        //判断当前围栏是否是当前城市的, 如果不是重新获取
//        NSArray *arFences = [CityInfoCache sharedInstance].arFences;
//        FenceObj *fence = arFences[0];
//        CityObj *city = [CityInfoCache sharedInstance].shuttleCurCity;
//        if (![city.adcode isEqualToString:fence.adcode]) {
//            [self httpGetFences];
//        }
//        else {
//            [self refreshFencesPolygon];
//        }
//    }
}

-(void)httpGetFences
{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_GetFence params:^(NetParams *params) {
        CityObj *city = [CityInfoCache sharedInstance].shuttleCurCity;
        if (city) {
            params.data = @{@"adcode":city.adcode};
        }
    }];
}

-(void)refreshFencesPolygon
{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    NSArray *arFences = [CityInfoCache sharedInstance].arFences;
    for (FenceObj *fenceObj in arFences) {

        NSArray *coordinateArr = fenceObj.coordinates;
        int ringCount   = (int)coordinateArr.count;
        //构造多边形数据对象
        CLLocationCoordinate2D ringCoordinates[ringCount];
        //坐标数组
        for (int i = 0; i < ringCount; i++) {
            CoordinateObj *fence = coordinateArr[i];
            ringCoordinates[i].latitude = fence.latitude;
            ringCoordinates[i].longitude = fence.longitude;
        }
        
        MAPolygon *ringPolygon = [MAPolygon polygonWithCoordinates:ringCoordinates count:ringCount];
        //在地图上添加折线对象
        [_mapView addOverlay: ringPolygon];
    }
    
    
}

-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
    ResultDataModel *reslut = notification.object;
    if (reslut.type == EmRequestType_GetFence) {

        NSArray *fences = [FenceObj mj_objectArrayWithKeyValuesArray:reslut.data];
        [[CityInfoCache sharedInstance] setArFences:fences];
        
        [self refreshFencesPolygon];
        
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.5];
    }
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed: notification];
    DBG_MSG(@"围栏数据获取失败");
    
}

@end
