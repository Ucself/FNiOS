//
//  AddressSearchVC.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/26.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "AddressSearchVC.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
//#import <FNMap/FNSearchViewController.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <MapKit/MapKit.h>
#import "MapCoordinaterModule.h"
#import "UIColor+Hex.h"
#import "ContainsMutable.h"

//#import "MapViewManager.h"

@interface AddressSearchVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MAMapViewDelegate,AMapSearchDelegate,UIGestureRecognizerDelegate>
{
    UIButton* annotationBtn;
        
    BOOL isFirstLocation; // 是否是第一次定位

    BOOL isCurrentLocation; //是否是当前界面定位

    BOOL isMapRegionChanged; //是否移动地图
    CLLocationCoordinate2D currentLocationCoord;

    
}

@property (strong, nonatomic)MAMapView *mapView;

//@property (strong,nonatomic)AMapPlaceSearchRequest *placeSearchPoint;
//@property (strong,nonatomic)AMapPlaceSearchRequest *placeSearchkey;

@property (strong,nonatomic) AMapSearchAPI* sarchAPI;
@end

#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"


@implementation AddressSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地址信息";
    self.cityID = @"028";
    
    isFirstLocation = YES;
    isCurrentLocation = YES;
    
    _locations = [NSMutableArray array];
    
    [self initView];
    
    [self initPolygon];

}

- (void)initView{

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder = @"请输入地点,如成都天府广场";
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundImage = [UIImage new];
    [self.view addSubview:_searchBar];
    

    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), ScreenW, 264)];
    _mapView.userTrackingMode  = 1;
    _mapView.showsUserLocation = YES;
    _mapView.delegate          = self;
    _mapView.showsCompass      = NO;
    _mapView.showsScale        = NO;
    [_mapView setZoomLevel:16];
    [self.view addSubview:_mapView];
    
    
    UIButton* locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(ScreenW - 40, 50, 30, 30);
    [locationBtn setImage:[UIImage imageNamed:@"location_unselected"] forState:0];
    [locationBtn addTarget:self action:@selector(onClickLocationBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    
    
    UIGestureRecognizer* gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerMapView)];
    gestureRecognizer.delegate = self;
    [_mapView addGestureRecognizer:gestureRecognizer];
    
    UIImage* img = [UIImage imageNamed:@"coord_1"];
    annotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    annotationBtn.frame = CGRectMake(0, 0, img.size.width + 10, img.size.height + 10);
    [annotationBtn setImage:img forState:0];
    annotationBtn.center = CGPointMake(_mapView.center.x, _mapView.frame.size.height/2 - annotationBtn.frame.size.height - 10);
    [_mapView addSubview:annotationBtn];

    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame) - 64, CGRectGetWidth(self.view.bounds), ScreenH - CGRectGetMaxY(_mapView.frame))];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    
//    _placeSearchkey = [[AMapPlaceSearchRequest alloc] init];
//    _placeSearchkey.requireExtension = YES;
//    _placeSearchkey.city = @[];
//    _placeSearchkey.radius = 1000;
//    _placeSearchkey.searchType = AMapSearchType_PlaceKeyword;
//
//    _placeSearchPoint = [[AMapPlaceSearchRequest alloc] init];
//    _placeSearchPoint.requireExtension = YES;
//    _placeSearchPoint.city = @[];
//    _placeSearchPoint.radius = 1000;
//    _placeSearchPoint.searchType = AMapSearchType_PlaceAround;
//    
//    _sarchAPI = [[AMapSearchAPI alloc] initWithSearchKey:KMapAppKey Delegate:self];

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
    }
    
}



- (void)dealloc{
    // assign的代理需要清空 ！！！！
    _sarchAPI.delegate = nil;
    _mapView.delegate = nil;
}

- (void)onClickLocationBtn{
    
    [_mapView setCenterCoordinate:currentLocationCoord animated:YES];
    [self searchPlaceWithLatitude:currentLocationCoord.latitude longitude:currentLocationCoord.longitude];
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    isMapRegionChanged = YES;

    return YES;
}

- (void)swipeGestureRecognizerMapView{
    isMapRegionChanged = YES;
}


#pragma mark -
-( CABasicAnimation *)moveAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y" ];
    animation.fromValue = [NSNumber numberWithFloat:- 10];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = .3;
    animation.removedOnCompletion = YES ; //yes 的话，又返回原位置了。
    animation.repeatCount = 1 ;//MAXFLOAT
    animation.fillMode = kCAFillModeForwards ;
    return animation;
}




- (void)showTip:(NSString*)tip{
    
    UILabel* myTipLB = (UILabel*)[self.view viewWithTag:1021];
    
    if (myTipLB == nil) {
        myTipLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, ScreenW, 25)];
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



#pragma mark- function
- (void)searchPlaceWithLatitude:(CGFloat)_latitude longitude:(CGFloat)_longitude{
    
//    NSLog(@"_latitude=%f _longitude=%f",_latitude,_longitude);    
    
    [self hiddenTip];
    
    CLLocationCoordinate2D centerCoordinate = _mapView.region.center;
    
    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
    
    //默认设置不在围栏里面
    BOOL isContains = NO;
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
            isContains = YES;
        }
    }
    
    if (isContains) {
//        [self startWait];
//        
//        _placeSearchPoint.location = [AMapGeoPoint locationWithLatitude:_latitude longitude:_longitude];
//        
//        [_sarchAPI AMapPlaceSearch:_placeSearchPoint];
    }else{
        [self showTip:@"请选择红色范围内的地点!"];
    }
}






-(void)searchTipsWithKey:(NSString*)key
{
//    [self startWait];
//    
//    _placeSearchkey.keywords = key;
//    [_sarchAPI AMapPlaceSearch:_placeSearchkey];
    
}



//- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
//{
//    [self.locations removeAllObjects];
//    [self stopWait];
//    
//    AMapPlaceSearchResponse *aResponse = (AMapPlaceSearchResponse *)response;
//    [aResponse.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop){
//         FNLocation *location = [[FNLocation alloc] init];
//         location.name = obj.name;
//         location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
//         location.address = obj.address;
//         location.cityCode = obj.citycode;
//         location.adCode = obj.adcode;
//         [self.locations addObject:location];
//     }];
//    
//    self.tableView.hidden = NO;
//    [_tableView reloadData];
//}


- (void)searchRequest:(id)request didFailWithError:(NSError *)error{
    [self stopWait];
    [MBProgressHUD showTip:@"网络异常" WithType:FNTipTypeWarning];
}


#pragma mark -- MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{

    if (isFirstLocation) {
        [self searchPlaceWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    }
    
    currentLocationCoord = userLocation.coordinate;
    isMapRegionChanged = NO;
    isFirstLocation = NO;
}



- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (isFirstLocation || !isMapRegionChanged) {
        return;
    }

    
    [annotationBtn.layer addAnimation:[self moveAnimation] forKey:nil];
    
    [self searchPlaceWithLatitude:_mapView.region.center.latitude longitude:_mapView.region.center.longitude];

}




- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 3;
        polylineView.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.4];
        polylineView.lineJoin = kCGLineJoinMiter;//连接类型
        //        polylineView.lineCapType = kMALineCapRound;//端点类型
        //
        return polylineView;
    }
    else if ([overlay isKindOfClass:[MAPolygon class]])
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




#pragma mark - UISearchBarDelegate
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
//    FNSearchViewController *vc = [[FNSearchViewController alloc]init];
//    vc.fnSearchDelegate = self;
//    [self.navigationController pushViewController:vc animated:NO];
//    return NO;
//}



#pragma mark -
#pragma mark - FNSearchViewControllerDelegate -
//- (void)searchViewController:(FNSearchViewController *)searchViewController didSelectLocation:(FNLocation *)location{
//    [_mapView setCenterCoordinate:location.coordinate animated:YES];
//    
//    isCurrentLocation = NO;
//    
//    isMapRegionChanged = NO;
//    
//    [self searchTipsWithKey:location.name];
//}



#pragma mark- uitableviewdelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
//    FNLocation *location = self.locations[indexPath.row];
    
    if (indexPath.row == 0 && isCurrentLocation) {
//        cell.textLabel.text = [NSString stringWithFormat:@"[位置]%@",location.name];
    }else{
//        cell.textLabel.text = location.name;
    }
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    
//    cell.detailTextLabel.text = location.address;
    cell.detailTextLabel.textColor = UIColorFromRGB(0xb4b4b4);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchBar resignFirstResponder];
    
    
//    FNLocation *location = self.locations[indexPath.row];
//    if (_myDelegate && [_myDelegate respondsToSelector:@selector(searchLocation:)]) {
//        [_myDelegate searchLocation:location];
//    }
    [self.navigationController popViewControllerAnimated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
