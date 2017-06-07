//
//  DriverTaskDetailViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/9/15.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverPackTaskDetailViewController.h"
#import "DriverScanPassengerViewController.h"
#import "ProtocolDriver.h"
#import "DriverLocationUploadModel.h"
#import "AppDelegate.h"

@interface DriverPackTaskDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MAMapViewDelegate>
{
     
}

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;


@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *submitView;


@end

@implementation DriverPackTaskDetailViewController

- (void)viewDidLoad {
     [super viewDidLoad];
     // Do any additional setup after loading the view.
     //数据相关初始化
     [self initInterface];
}

- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
     // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
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
//开始任务或者刚进入的时候启动坐标上传
-(void)startLocationUpload
{
     //发送任务开始通知
     DriverLocationUploadModel *tempDriverLocationUploadModel = [[DriverLocationUploadModel alloc] init];
     tempDriverLocationUploadModel.uploadState = 1;
     tempDriverLocationUploadModel.taskType = @"包车";
     tempDriverLocationUploadModel.orderId = _taskModel.subOrderId;
     tempDriverLocationUploadModel.licensePlate = _taskModel.licensePlate;
     
     [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DriverStartTask object:tempDriverLocationUploadModel];
}
//结束任务上传
-(void)endLocationUpload
{
     [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DriverEndTask object:nil];
}
//重写基类返回按钮
-(void)btnBackClick:(id)sender
{
     //正在进行的任务，推出的时候要提示
     if (_taskModel.orderState == 4)
     {
          UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你确定返回任务列表？返回后将不记录行程轨迹，若要记录行程轨迹请重新进入该界面" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
          tipAlertView.tag = 1003;
          [tipAlertView show];
     }
     else
     {
          //否则的话之间退出
          [super btnBackClick:sender];
     }
     
}

-(void)initInterface
{
     self.mainTableView.delegate = self;
     self.mainTableView.dataSource = self;
     //设置名称
     self.navigationItem.title = @"任务详情";
     //设置圆角
     _submitButton.layer.cornerRadius = 3.0f;
     //地图对象初始化
     //     _mapView = ((AppDelegate*)[[UIApplication sharedApplication]delegate]).mapView;
     _mapView.delegate = self;
     [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.6574893, 104.0657562) animated:YES];
     [_mapView setZoomLevel:10 animated:YES];
     //根据订单状态显示底部按钮
     if (_taskModel.orderState ==5)
     {
          [_submitButton setBackgroundColor:UIColorFromRGB(0xB4B4B4)];
          [_submitButton setTitle:@"任务完成" forState:UIControlStateNormal];
     }
     else if (_taskModel.orderState == 4)
     {
          //设置按钮背景色
          [_submitButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
          [_submitButton setTitle:@"结束任务" forState:UIControlStateNormal];
          //开始上传坐标
          [self startLocationUpload];
     }
     else if (_taskModel.orderState == 3)
     {
          //设置按钮背景色
          [_submitButton setBackgroundColor:UIColorFromRGB(0x80CC5A)];
          [_submitButton setTitle:@"开始任务" forState:UIControlStateNormal];
     }
     
}

//任务按钮点击
- (IBAction)submitButtonClick:(id)sender {
     //     //测试发送任务开始通知
     //     DriverLocationUploadModel *tempDriverLocationUploadModel = [[DriverLocationUploadModel alloc] init];
     //     tempDriverLocationUploadModel.uploadState = 1;
     //     tempDriverLocationUploadModel.taskType = @"包车";
     //     tempDriverLocationUploadModel.orderId = _taskModel.subOrderId;
     //     tempDriverLocationUploadModel.licensePlate = _taskModel.licensePlate;
     //
     //     [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DriverStartTask object:tempDriverLocationUploadModel];
     //     return;
     //点击结束任务任务
     if (_taskModel.orderState == 4)
     {
          UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你确定结束任务？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
          tipAlertView.tag = 1002;
          [tipAlertView show];
     }
     else if (_taskModel.orderState == 3)
     {
          //首先判断是否真正执行任务
          DriverLocationUploadModel *driverLocationUploadModel = ((AppDelegate*)[[UIApplication sharedApplication]delegate]).locationUploadModel;
          if (driverLocationUploadModel && driverLocationUploadModel.uploadState == 1) {
               NSString *tipMessage = [[NSString alloc] initWithFormat:@"你正在执行 %@ %@ 任务\n无法开始新的任务",driverLocationUploadModel.licensePlate ,driverLocationUploadModel.taskType];
               //正在执行其他任务
               UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:tipMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
               [tipAlertView show];
          }
          //再执行开始任务
          UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你确定开始任务？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
          tipAlertView.tag = 1001;
          [tipAlertView show];
     }
     
}


//跳转到乘客明细
-(void)jumpPassengerDetail:(id)sender
{
     [self performSegueWithIdentifier:@"toPassengerList" sender:self];
}

-(void)jumpScanPassenger:(id)sender
{
     DriverScanPassengerViewController *scanPassengerViewController = [[DriverScanPassengerViewController alloc] init];
     [self.navigationController pushViewController:scanPassengerViewController animated:YES];
}

-(void)callContactPeople:(id)sender
{
     
     if (!_taskModel.contacterPhone) {
          return;
     }
     
     NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_taskModel.contacterPhone];
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
     
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

#pragma mark --- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     //点击弹出框的按钮
     switch (alertView.tag) {
          case 1001:
          {
               //点击了确定按钮
               if (buttonIndex == 1) {
                    //点击结束任务
                    [self startWait];
                    [[ProtocolDriver sharedInstance] putInforWithNSDictionary:[NSDictionary new] urlSuffix:[[NSString alloc] initWithFormat:@"%@?subOrderId=%@&status=%d",Kurl_charterOrderDriverTask,_taskModel.subOrderId,1] requestType:KRequestType_driverStartTask];
               }
               
          }
               break;
          case 1002:
          {
               //点击了确定按钮
               if (buttonIndex == 1) {
                    [self startWait];
                    //点击结束任务
                    [[ProtocolDriver sharedInstance] putInforWithNSDictionary:[NSDictionary new] urlSuffix:[[NSString alloc] initWithFormat:@"%@?subOrderId=%@&status=%d",Kurl_charterOrderDriverTask,_taskModel.subOrderId,2] requestType:KRequestType_driverEndTask];
               }
               
          }
               break;
          case 1003:
          {
               //点击了确定按钮
               if (buttonIndex == 1) {
                    //停止发送坐标位置
                    [self endLocationUpload];
                    //然后退到第一个页面
                    [super btnBackClick:nil];
               }
               
          }
               break;
          default:
               break;
     }
}

#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     switch (indexPath.section) {
          case 0:
          {
               return 270.f;
          }
               break;
          case 1:
          {
               return 280.f;
          }
               break;
          default:
               break;
     }
     return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
     return 15.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
     return 0.1;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
     view.tintColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
     view.tintColor = [UIColor clearColor];
}

#pragma mark ---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     UITableViewCell *tempCell;
     
     switch (indexPath.section) {
          case 0:
          {
               tempCell = [tableView dequeueReusableCellWithIdentifier:@"tableInforCellIdent"];
               //任务时间
               UILabel *timeLabel = (UILabel*)[tempCell viewWithTag:111];
               UILabel *endTimeLabel = (UILabel*)[tempCell viewWithTag:1111];
               NSDate *startDate = [DateUtils stringToDate:_taskModel.startTime];
               NSDate *endDate = [DateUtils stringToDate:_taskModel.endTime];
               timeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"]];
               endTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
               //车辆信息
               UILabel *vehicleInforLabel = (UILabel*)[tempCell viewWithTag:112];
               vehicleInforLabel.text = [[NSString alloc] initWithFormat:@"%@%@  准乘坐%d人 1辆",_taskModel.vehicleTypeName,_taskModel.vehicleLevelName,_taskModel.seats];
               //订单类型
               UILabel *orderTypeLabel = (UILabel*)[tempCell viewWithTag:113];
               orderTypeLabel.text = @"包车";
               //车辆牌照
               UILabel *licensePlateLabel = (UILabel*)[tempCell viewWithTag:114];
               licensePlateLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.licensePlate];
               //乘坐人数
               UILabel *seatsLabel = (UILabel*)[tempCell viewWithTag:115];
               seatsLabel.text = [[NSString alloc] initWithFormat:@"%d",_taskModel.seats];
               //起始地
               UILabel *startNameLabel = (UILabel*)[tempCell viewWithTag:116];
               startNameLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.startName];
               //目的地
               UILabel *destinationNameLabel = (UILabel*)[tempCell viewWithTag:117];
               destinationNameLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.destinationName];
               //联系人
               UILabel *contacterInfor = (UILabel*)[tempCell viewWithTag:118];
               contacterInfor.text = [[NSString alloc] initWithFormat:@"%@  %@",_taskModel.contacterName,_taskModel.contacterPhone];
               UITapGestureRecognizer *contacterTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callContactPeople:)];
               [contacterInfor addGestureRecognizer:contacterTapGestureRecognizer];
               [contacterInfor setUserInteractionEnabled:YES];
               
          }
               break;
          case 1:
          {
               tempCell = [tableView dequeueReusableCellWithIdentifier:@"tableMapCellIdent"];
               UIView *tempView = [tempCell viewWithTag:101];
               
               if (_taskModel.orderState == 5)
               {
                    //完成的任务，展示运行的轨迹
                    [tempView addSubview:_mapView];
                    _mapView.frame = tempView.bounds;
                    //此处再请求历史任务坐标集合
                    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
                    [requestDic setObject:_taskModel.subOrderId forKey:@"orderId"];
                    [[ProtocolDriver sharedInstance] getLocationWithNSDictionary:requestDic urlSuffix:Kurl_CharterLocation requestType:KRequestType_getCharterLocation];
                    
               }
               else
               {
                    //未完成的任务展示位置
                    [tempView addSubview:_mapView];
                    _mapView.frame = tempView.bounds;
                    _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
                    _mapView.userTrackingMode = MAUserTrackingModeFollow;
               }
          }
               break;
          default:
               break;
     }
     
     return tempCell;
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
     ResultDataModel *resultParse = (ResultDataModel *)notification.object;

     switch (resultParse.requestType) {
          case KRequestType_driverStartTask:
          {
               if (resultParse.resultCode == 0)
               {
                    _taskModel.orderState = 4;
                    //动画改变样式
                    [UIView animateWithDuration:0.4 animations:^{
                         //设置按钮背景色
                         [_submitButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
                         [_submitButton setTitle:@"结束任务" forState:UIControlStateNormal];
                    }];
                    //开始坐标位置上传
                    [self startLocationUpload];
               }
               else
               {
                    //开始行程失败
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"开始任务失败，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    
                    [alertView show];
               }
          }
               break;
          case KRequestType_driverEndTask:
          {
               if (resultParse.resultCode == 0)
               {
                    _taskModel.orderState = 5;
                    //动画改变样式
                    [UIView animateWithDuration:0.4 animations:^{
                         [_submitButton setBackgroundColor:UIColorFromRGB(0xB4B4B4)];
                         [_submitButton setTitle:@"任务完成" forState:UIControlStateNormal];
                    }];
                    //结束任务路径上传
                    [self endLocationUpload];
                    //此处再请求历史任务坐标集合
                    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
                    [requestDic setObject:_taskModel.subOrderId forKey:@"orderId"];
                    [[ProtocolDriver sharedInstance] getLocationWithNSDictionary:requestDic urlSuffix:Kurl_CharterLocation requestType:KRequestType_getCharterLocation];
               }
               else
               {
                    //开始行程失败
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"结束任务失败，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
               }
          }
               break;
          case KRequestType_getCharterLocation:
          {
               if (resultParse.resultCode == 0) {
                    //根据返回的路径绘制路径
                    NSMutableArray *locationList = [resultParse.data objectForKey:@"list"];
                    //如果是空对象，活着数组为空
                    if ([locationList isKindOfClass:[NSNull class]] || locationList.count <= 1) {
                         //不做任何处理
                    }
                    //画路径
                    else if (locationList.count >= 1) {
                         //清除位置信息
                         _mapView.showsUserLocation = NO;
                         [_mapView removeAnnotations:_mapView.annotations];
                         [_mapView removeOverlays:_mapView.overlays];
                         //绘制行程轨迹
                         [self drawingPathPolyline:locationList];
                    }
               }
               else
               {
                    [self showTipsView:@"与服务器交互失败"];
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
     [super httpRequestFailed:notification];
}

@end








