//
//  BaiDuCarRouting.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/25.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "BaiDuCarRouting.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TianFuCarPayVC.h"
#import "CarpoolPayViewController.h"
#import "MapCoordinaterModule.h"
#import "UIColor+Hex.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "MainViewController.h"
#import "TravelViewController.h"
#import "CarpoolTravelStateViewController.h"
#import "TFCarEvaluationVC.h"
#import "TravelHistoryViewController.h"
#import "FeedbackViewController.h"
#import "CarpoolTravelingViewController.h"


@interface BaiDuCarRouting ()<MAMapViewDelegate>
{
    NSTimer* timerForRequst;

}
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
//@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *dirverAvatar;
@property (strong, nonatomic) IBOutlet UILabel *driverName;
@property (strong, nonatomic) IBOutlet UILabel *carNumber;
@property (strong, nonatomic) IBOutlet UILabel *starsNumber;
@property (strong, nonatomic) IBOutlet UILabel *driverScores;
@property (strong, nonatomic) IBOutlet UILabel *driverOrderNumber;
@property (strong, nonatomic) IBOutlet UIButton *callDriverButton;
@property (strong, nonatomic) NSString *driverPhoneNumber;

@end

@implementation BaiDuCarRouting

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initMapView];
    
    [self initNavigationItems];
    
    [self initRequstTimer];
    
    if (_orderDetailModel) {
        [self setOwerInformation];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
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



- (void)setOwerInformation{
    
    if (!_orderDetailModel) {
        return;
    }
    
    if (_orderDetailModel.driverName && [_orderDetailModel.driverName isKindOfClass:[NSString class]]) {
        _driverName.text = _orderDetailModel.driverName;
    }else{
        _driverName.text = @"未知";
    }
    
    
    _driverOrderNumber.text = [NSString stringWithFormat:@"接单数量:%d单",_orderDetailModel.driverOrderNum];

    _driverScores.text = [NSString stringWithFormat:@"%.1f分",_orderDetailModel.driverScore];
    
    
    if (_orderDetailModel.license && [_orderDetailModel.license isKindOfClass:[NSString class]]) {
        _carNumber.text = _orderDetailModel.license;
    }else{
        _carNumber.text = @"未知";
    }
    
    if (_orderDetailModel.driverAvatar && [_orderDetailModel.driverAvatar isKindOfClass:[NSString class]]) {
        [_dirverAvatar setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,_orderDetailModel.driverAvatar]] placeholderImage:[UIImage imageNamed:@"my_center_head_1"]];
    }else{
        [_dirverAvatar setImage:[UIImage imageNamed:@"my_center_head_1"]];
    }
    
    if (_orderDetailModel.driverPhone && [_orderDetailModel.driverPhone isKindOfClass:[NSString class]]) {
        _driverPhoneNumber = _orderDetailModel.driverPhone;
    }else{
        _driverPhoneNumber = @"13999999999";
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- init Property
- (void)initRequstTimer{
    timerForRequst = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requstFerryOrderCheckState) userInfo:nil repeats:YES];
    [timerForRequst setFireDate:[NSDate distantFuture]];
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

- (void)initMapView{
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setDelegate:self];
    [_mapView setUserTrackingMode:1];
    [_mapView setZoomLevel:16];
    [_mapView setShowsScale:NO];
    [_mapView setShowsCompass:NO];
}

- (void)initNavigationItems{
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLeft setFrame:CGRectMake(0, 0, 20, 15)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnRight setFrame:CGRectMake(0, 0, 30, 15)];
    [btnRight setTitle:@"投诉" forState:UIControlStateNormal];
    [btnRight.titleLabel setTextAlignment:NSTextAlignmentRight];
    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(complaintsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投诉" style:UIBarButtonItemStylePlain target:self action:@selector(complaintsButtonClick)];
    
    self.navigationItem.title = @"行程中";
}



-(void)requstFerryOrderCheckState{
    
    if (!_orderId || _orderId.length <= 1) {
        return;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
        params.data = @{@"orderId":_orderId};
    }];
}


#pragma mark -- function methods
- (void)backButtonClick{
    //摆渡车返回
    if (_orderDetailModel.type == 3 || _routingTypeId == 3){
        

        
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
        
        TravelHistoryViewController *travelVC = nil;
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            
            if ([vc isKindOfClass:[TravelHistoryViewController class]]) {
                
                travelVC = (TravelHistoryViewController *)vc;
            }
        }
        
        if (travelVC) {
            
            [self.navigationController popToViewController:travelVC animated:YES];
        }else{
            [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
        }
    }

}

//投诉
- (void)complaintsButtonClick{
    
    FeedbackViewController *feedBaceVC = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"feedbackvc"];
    
    [self.navigationController pushViewController:feedBaceVC animated:YES];
    
}

#pragma mark -- button event

- (IBAction)callDriverButtonClick:(id)sender {
    
    if (_orderDetailModel.driverPhone && [_orderDetailModel.driverPhone isKindOfClass:[NSString class]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_orderDetailModel.driverPhone]]];
    }else{
        [MBProgressHUD showTip:@"号码为空!" WithType:FNTipTypeWarning];
    }
}

#pragma mark -- mapview delegate

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
    
    
}


#pragma mark -- Recevie APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
    if ([userInfo[@"processType"] intValue] != 28) {
        return;
    }
    
    //天府专车
    if ([userInfo[@"state"] intValue] == 1) {
        
        [self pushCarPayViewController];
        
    }else{
        
        [MBProgressHUD showTip:((NSDictionary*)userInfo[@"aps"])[@"alert"] WithType:FNTipTypeWarning];
    }

}

- (void)pushCarPayViewController{
    
    //进入摆渡车
    if (_orderDetailModel.type == 3) {
        
        TFCarEvaluationVC *evaluationVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
        evaluationVC.orderDetailModel = _orderDetailModel;
        evaluationVC.evaluationTypeId = _orderDetailModel.type;
        
        [self.navigationController pushViewController:evaluationVC animated:YES];
        
        return;
    }
    
    TianFuCarPayVC *tfcVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"tianfucarpay"];
    tfcVC.orderDetailModel = _orderDetailModel;
    [self.navigationController pushViewController:tfcVC animated:YES];
}

-(void)httpRequestFinished:(NSNotification *)notification
{
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == KRequestType_FerryOrderCheck) {
        
        if (resultData.resultCode == 0) {
            if (!_orderDetailModel) {
                self.orderDetailModel = [[TFCarOrderDetailModel alloc] initWithDictionary:resultData.data[@"order"]];
                [self setOwerInformation];
            }
            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]);
            
            if ([resultData.data[@"order"][@"state"] intValue] == 4){
                [self pushCarPayViewController];
            }

        }
        
//        if (resultData.resultCode == 1) { //订单是否提交成功 resultState=1成功 0 不成功
//            
//            if (!_orderDetailModel) {
//                self.orderDetailModel = [[TFCarOrderDetailModel alloc] initWithDictionary:resultData.data[@"order"]];
//                [self setOwerInformation];
//            }
//            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]);
//            if ([resultData.data[@"state"] intValue] == 4){
//                [self pushCarPayViewController];
//            }
//        }
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification
{

}

@end
