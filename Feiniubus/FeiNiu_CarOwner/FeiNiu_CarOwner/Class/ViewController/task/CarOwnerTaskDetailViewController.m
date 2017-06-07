//
//  CarOwnerTaskDetailViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerTaskDetailViewController.h"
#import "ProtocolCarOwner.h"

@interface CarOwnerTaskDetailViewController ()<UITableViewDelegate,UITableViewDataSource,MAMapViewDelegate>
{
}
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation CarOwnerTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //此处再请求历史任务坐标集合
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_taskModel.subOrderId forKey:@"orderId"];
    switch (_taskModel.orderState) {
        case 4:
        {
            NSTimer *timerControl = [NSTimer scheduledTimerWithTimeInterval:30.f target:self selector:@selector(timeRequestCharterLocation) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timerControl forMode:NSRunLoopCommonModes];
        }
            break;
        case 5:
        {
            //历史任务
            [[ProtocolCarOwner sharedInstance] getLocationWithNSDictionary:requestDic urlSuffix:Kurl_CharterLocation requestType:KRequestType_getCharterLocation];
        }
            break;
        default:
            break;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark ---
//加载界面
-(void)initInterface
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    //地图对象初始化
    //    _mapView = ((AppDelegate*)[[UIApplication sharedApplication]delegate]).mapView;
    _mapView.delegate = self;
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.6574893, 104.0657562) animated:YES];
    [_mapView setZoomLevel:10 animated:YES];
}
//定时执行的位置请求
-(void)timeRequestCharterLocation
{
    //当前任务
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_taskModel.subOrderId forKey:@"orderId"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:1] forKey:@"rows"];
    [[ProtocolCarOwner sharedInstance] getLocationWithNSDictionary:requestDic urlSuffix:Kurl_CharterLocation requestType:KRequestType_getCharterLocation];
}

#pragma mark -- Make a phone call

-(void)callDriver:(id)sender
{
    
    if (!_taskModel.driverPhone) {
        return;
    }
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_taskModel.driverPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}
-(void)callContactPeople:(id)sender
{
    
    if (!_taskModel.contacterPhone) {
        return;
    }
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_taskModel.contacterPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 310.f;
            break;
        case 1:
            return 283.f;
            break;
        default:
            break;
    }
    return 0;
}

#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell = nil;
    
    switch (indexPath.section) {
        case 0:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"inforCellIdent"];
            UILabel *timeLabel = (UILabel*)[tempCell viewWithTag:101];
            UILabel *endTimeLabel = (UILabel*)[tempCell viewWithTag:111];
            UILabel *vehicleInforLabel = (UILabel*)[tempCell viewWithTag:102];
            UILabel *mileageLabel = (UILabel*)[tempCell viewWithTag:103];
            UILabel *licensePlateLabel = (UILabel*)[tempCell viewWithTag:104];
            UILabel *driverInforLabel = (UILabel*)[tempCell viewWithTag:105];
            UILabel *startNameLabel = (UILabel*)[tempCell viewWithTag:106];
            UILabel *destinationNameLabel = (UILabel*)[tempCell viewWithTag:107];
            UILabel *contacterInforLabel = (UILabel*)[tempCell viewWithTag:108];
            UIButton *orderStateLabel = (UIButton*)[tempCell viewWithTag:109];
            //数据源
            if (!_taskModel) {
                timeLabel.text = @"";
                endTimeLabel.text = @"";
                vehicleInforLabel.text = @"";
                mileageLabel.text = @"";
                licensePlateLabel.text = @"";
                driverInforLabel.text = @"";
                startNameLabel.text = @"";
                destinationNameLabel.text = @"";
                contacterInforLabel.text = @"";
                [orderStateLabel setTitle:@"" forState:UIControlStateNormal];
            }
            else
            {
                NSDate *startDate = [DateUtils stringToDate:_taskModel.startTime];
                NSDate *endDate = [DateUtils stringToDate:_taskModel.endTime];
                timeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"]];
                endTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
                vehicleInforLabel.text = [[NSString alloc] initWithFormat:@"%@%@ 准乘坐%d人 1辆",_taskModel.vehicleTypeName,_taskModel.vehicleLevelName,_taskModel.seats];
                mileageLabel.text = [[NSString alloc] initWithFormat:@"%.2fkm",_taskModel.mileage];
                licensePlateLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.licensePlate];
                driverInforLabel.text = [[NSString alloc] initWithFormat:@"%@ %@",_taskModel.driverName,_taskModel.driverPhone];
                startNameLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.startName];
                destinationNameLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.destinationName];
                contacterInforLabel.text = [[NSString alloc] initWithFormat:@"%@  %@",_taskModel.contacterName,_taskModel.contacterPhone];
                [orderStateLabel setTitle:@"未知状态" forState:UIControlStateNormal];
                
                //打电话设置
                UITapGestureRecognizer *driverTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callDriver:)];
                [driverInforLabel addGestureRecognizer:driverTapGestureRecognizer];
                [driverInforLabel setUserInteractionEnabled:YES];
                
                UITapGestureRecognizer *contacterTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callContactPeople:)];
                [contacterInforLabel addGestureRecognizer:contacterTapGestureRecognizer];
                [contacterInforLabel setUserInteractionEnabled:YES];
                
                //根据任务状态显示不同
                if (_taskModel.orderState == 2)
                {
                    [orderStateLabel setTitle:@"等待付款" forState:UIControlStateNormal];
                    [orderStateLabel setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
                }
                else if (_taskModel.orderState == 3)
                {
                    [orderStateLabel setTitle:@"等待开始" forState:UIControlStateNormal];
                    [orderStateLabel setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
                }
                else if (_taskModel.orderState == 4)
                {
                    [orderStateLabel setTitle:@"当前任务" forState:UIControlStateNormal];
                    [orderStateLabel setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
                }
                else if (_taskModel.orderState == 5)
                {
                    [orderStateLabel setTitle:@"历史任务" forState:UIControlStateNormal];
                    [orderStateLabel setTitleColor:UIColorFromRGB(0xB4B4B4) forState:UIControlStateNormal];
                }
                else if (_taskModel.orderState == 6)
                {
                    [orderStateLabel setTitle:@"任务终止" forState:UIControlStateNormal];
                    [orderStateLabel setTitleColor:UIColorFromRGB(0xB4B4B4) forState:UIControlStateNormal];
                }
                else if (_taskModel.orderState == 7)
                {
                    [orderStateLabel setTitle:@"任务取消" forState:UIControlStateNormal];
                    [orderStateLabel setTitleColor:UIColorFromRGB(0xB4B4B4) forState:UIControlStateNormal];
                }
            }
            
            
        }
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"mapCellIdent"];
            UIView *bgView = [tempCell viewWithTag:101];
            
            [bgView addSubview:_mapView];
            _mapView.frame = bgView.bounds;
            //测试加载地图
            //            FNMapView *mapView = [[FNMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 10, 263)];
            //            [bgView addSubview:mapView];
        }
            break;
        default:
            break;
    }
    
    return tempCell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
#pragma mark --- MAMapViewDelegate
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    /* 自定义定位精度对应的MACircleView. */
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        MACircleView *accuracyCircleView = [[MACircleView alloc] initWithCircle:overlay];
        
        accuracyCircleView.lineWidth    = 2.f;
        accuracyCircleView.strokeColor  = [UIColor lightGrayColor];
        accuracyCircleView.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        
        return accuracyCircleView;
    }
    //折线
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 3.f;
        polylineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
        polylineView.lineJoinType = kMALineJoinRound;//连接类型
        polylineView.lineCapType = kMALineCapRound;//端点类型
        
        return polylineView;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"passengerIcon"];
        
        self.userLocationAnnotationView = annotationView;
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = YES;
        annotationView.draggable                    = YES;
        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        annotationView.pinColor                     = [self.annotations indexOfObject:annotation];
//        annotationView.portraitImageView.image =
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - _mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
}

/**
 *  根据折线来画行驶路径
 *
 *  @param annotations 自定义坐标
 *  @param isClearMap  是否清除地图上的东西
 */
-(void)drawingPathPolyline:(NSArray*)annotations
{
    //传入的点不够,要大于等于两个点才行
    if (!annotations || annotations.count < 2) {
        return;
    }
    //构造折线数据对象
    CLLocationCoordinate2D commonPolylineCoords[annotations.count];
    
    for (int i=0; i<annotations.count;i++) {
        //坐标添加到数组
        commonPolylineCoords[i].latitude  = [[annotations[i] objectForKey:@"latitude"] doubleValue];
        commonPolylineCoords[i].longitude = [[annotations[i] objectForKey:@"longitude"] doubleValue];
    }
    //构造折线对象
    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:annotations.count];
    //在地图上添加折线对象
    [_mapView addOverlay: commonPolyline];
    //设置中心点
    [self zoomToMapPoints:_mapView annotations:annotations];
}
//设置定位方式
- (void)zoomToMapPoints:(MAMapView*)mapView annotations:(NSArray*)annotations
{
    double minLat = 360.0f, maxLat = -360.0f;
    double minLon = 360.0f, maxLon = -360.0f;
    for (NSDictionary *annotation in annotations) {
        double latitudeDouble = [[annotation objectForKey:@"latitude"] doubleValue];
        double longitudeDouble = [[annotation objectForKey:@"longitude"] doubleValue];
        
        if ( latitudeDouble  < minLat ) minLat = latitudeDouble;
        if ( latitudeDouble  > maxLat ) maxLat = latitudeDouble;
        if ( longitudeDouble < minLon ) minLon = longitudeDouble;
        if ( longitudeDouble > maxLon ) maxLon = longitudeDouble;
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat + maxLat) / 2.0, (minLon + maxLon) / 2.0);
    MACoordinateSpan span = MACoordinateSpanMake(maxLat - minLat, maxLon - minLon);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [mapView setRegion:region animated:YES];
}
#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;

    switch (resultParse.requestType) {
        case KRequestType_getCharterLocation:
        {
            if (resultParse.resultCode == 0) {
                //根据返回的路径绘制路径
                NSMutableArray *locationList = [resultParse.data objectForKey:@"list"];
                //如果是空对象，活着数组为空
                if (![locationList isKindOfClass:[NSNull class]] && locationList.count == 1) {
                    //清除位置信息
                    _mapView.showsUserLocation = NO;
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView removeOverlays:_mapView.overlays];
                    //只有一个点的话说明是获取车主当前位置
                    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
                    annotation.coordinate = CLLocationCoordinate2DMake([[locationList[0] objectForKey:@"latitude"] doubleValue], [[locationList[0] objectForKey:@"longitude"] doubleValue]);
                    [_mapView addAnnotation:annotation];
                }
                //画路径
                else if (locationList.count >= 1) {
                    //清除位置信息
                    _mapView.showsUserLocation = NO;
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView removeOverlays:_mapView.overlays];
                    
                    [self drawingPathPolyline:locationList];
                }
            }
            else
            {
                [self showTipsView:@"与服务器交互失败"];
            }
            break;
            
        default:
            break;
        }
    }
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}
@end













