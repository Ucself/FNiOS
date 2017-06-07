//
//  TianfuCarHomeVC.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/23.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TianfuCarHomeVC.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
//#import <FNMap/FNSearchViewController.h>
//#import <FNMap/FNLocation.h>
#import "UserCustomAlertView.h"
#import "AddressSearchVC.h"
#import "RuleViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "BaiDuCarWaitOrder.h"
#import "CustomAnnotationView.h"
#import "TravelHistoryViewController.h"
#import "LoginViewController.h"
#import "TianFuCarPayVC.h"
#import "MapCoordinaterModule.h"
#import "UIColor+Hex.h"
#import <FNNetInterface/PushConfiguration.h>
#import "TFCarEvaluationVC.h"
#import "ContainsMutable.h"

@interface TianfuCarHomeVC ()<MAMapViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UserCustomAlertViewDelegate,AddressSearchDelegate,AMapSearchDelegate,UIGestureRecognizerDelegate>
{
    UIButton* pincheBtn;
    UIButton* dingzhiBtn;
    UIView* guideView;
    UIView* selectPeopleNumberView;
    
    UITextField* startTextField;
    UITextField* endTextField;
    UITextField* numberTextField;
    UIPickerView* picker;
    UILabel* peopleNumberLB;
    
    UITextField* currentTextField;
    UIView* addressView;
    UIView* moenyView;
    UILabel* moenyLB;
    UILabel* discountLB;

    UIButton* annotationBtn;
    
//    FNLocation* startLocation;
//    FNLocation* endLocation;

    NSString* orderID;
    NSString* price;
    NSString* discount;
    
    
    NSDictionary* ferryOrderDic;
    BOOL isFirstLocation;
    
    BOOL isMapRegionChanged;
    NSTimer *timer;
    double distance;
    NSArray *routeArr;
    CLLocationCoordinate2D currentLocationCoord;
    NSString* notFinishOrderId;
    
    CLLocationCoordinate2D* thirdroadCoordinates;
    CLLocationCoordinate2D* tianfuAreaCoordinates;

    int myAction;
}

@property (nonatomic,strong) MAMapView *mapView;
@property (strong,nonatomic) AMapReGeocodeSearchRequest *regeoRequest;
@property (strong,nonatomic) AMapSearchAPI *searchAPI;


@end


#define KMapAppKey   @"865e5c2f1b534c9673eeaab91144185b"


@implementation TianfuCarHomeVC

#pragma mark -- life cycle

- (void)dealloc{
    
    _mapView.showsUserLocation = NO;
    _mapView.delegate = nil;
    
    [timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:249/255.f alpha:1];
    self.title = @"天府专车";
    isFirstLocation = YES;
    orderID = @"";
    price = @"999";
    discount = @"0";
    isMapRegionChanged = NO;
    notFinishOrderId = nil;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0, 0, 20, 15)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 60, 40)];
    rightBtn.titleLabel.font = Font(14);
    [rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [rightBtn setTitle:@"用车说明" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, - 137, ScreenW, ScreenH + 137)];
    _mapView.userTrackingMode  = 1;
    _mapView.showsScale = NO;
    _mapView.showsCompass = NO;
    _mapView.delegate = self;
    [_mapView setZoomLevel:16];
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    UIButton* locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(ScreenW - 40, 75, 30, 30);
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
    
    
    

    
    
//    _searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:KMapAppKey Delegate:self];
    _searchAPI.delegate = self;
    
    _regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//    _regeoRequest.searchType = AMapSearchType_ReGeocode;
    _regeoRequest.requireExtension   = YES;
    
    [self initSwitchView];
    [self initAddressView];
    [self initMoneyView];
    [self initSelectPeopleNumberView];
//    [self requstFerryOrderCheckExists];
    
    [self initPolygon];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self initTimer];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
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


//
////在范围内返回1，不在返回0
//-(BOOL)isContainsMutableBoundCoords:(CLLocationCoordinate2D*)coords count:(int)count coordinate:(CLLocationCoordinate2D)coordinate{
//    
//    if (count == 0) {
//        return YES;
//    }
//    
//    CLLocationCoordinate2D *arrSome = coords;
//    
//    float vertx[count];
//    float verty[count];
//    
//    for (int i = 0; i < count; i++) {
//        vertx[i] = arrSome[i].latitude;
//        verty[i] = arrSome[i].longitude;  
//    }
//
//    BOOL flag = pnpoly(count, vertx, verty, coordinate.latitude, coordinate.longitude);
//    
//    return flag;
//}
//
//
//BOOL pnpoly (int nvert, float *vertx, float *verty, float testx, float testy) {
//    int i, j;
//    BOOL c = NO;
//    for (i = 0, j = nvert-1; i < nvert; j = i++) {
//        if (((verty[i]>testy) != (verty[j]>testy)) && (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
//            c = !c;
//    }
//    return c;
//}





-(void)routeSearch{
    
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
//    if ((startLocation.coordinate.latitude != 0) && (endLocation.coordinate.longitude != 0)) {
    
//        [self startWait];
        
//        AMapNavigationSearchRequest *request = [[AMapNavigationSearchRequest alloc] init];
//        request.origin = [AMapGeoPoint locationWithLatitude:startLocation.coordinate.latitude longitude:startLocation.coordinate.longitude];
//        request.destination = [AMapGeoPoint locationWithLatitude:endLocation.coordinate.latitude longitude:endLocation.coordinate.longitude];
//        request.searchType = AMapSearchType_NaviDrive;
//        request.strategy = 2;//距离优先
//        request.requireExtension = YES;
//        request.waypoints = cityArray;
        
        //发起路径搜索
//        [_searchAPI AMapNavigationSearch:request];
    }
//}



//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    _mapView.showsUserLocation = YES;
//    _mapView.delegate = self;
//}
//
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//
//    _mapView.showsUserLocation = NO;
//    _mapView.delegate = nil;
//}

#pragma mark -- init user interface

- (void)initSwitchView{
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 54)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    pincheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pincheBtn setTitle:@"城区拼车" forState:0];
    [pincheBtn setTitleColor:UIColorFromRGB(0xff666666) forState:0];
    [pincheBtn setTitleColor:UIColorFromRGB(0xffff7043) forState:UIControlStateSelected];
    pincheBtn.titleLabel.font = Font(16);
    [pincheBtn setImage:[UIImage imageNamed:@"inter_city_icon"] forState:UIControlStateSelected];
    [self.view addSubview:pincheBtn];
    [pincheBtn addTarget:self action:@selector(onClickTypeBtn:) forControlEvents:UIControlEventTouchDown];
    pincheBtn.frame = CGRectMake(0, 10, 130, 34);
    pincheBtn.center = CGPointMake(ScreenW/4, pincheBtn.center.y);
    
    dingzhiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dingzhiBtn setTitle:@"定制专车" forState:0];
    [dingzhiBtn setTitleColor:UIColorFromRGB(0xff666666) forState:0];
    [dingzhiBtn setTitleColor:UIColorFromRGB(0xffff7043) forState:UIControlStateSelected];
    dingzhiBtn.titleLabel.font = Font(16);
    [dingzhiBtn setImage:[UIImage imageNamed:@"customcar_icon"] forState:UIControlStateSelected];
    [self.view addSubview:dingzhiBtn];
    [dingzhiBtn addTarget:self action:@selector(onClickTypeBtn:) forControlEvents:UIControlEventTouchDown];
    dingzhiBtn.frame = CGRectMake(0, 10, 130, 34);
    dingzhiBtn.center = CGPointMake(ScreenW*3/4, dingzhiBtn.center.y);
    
    [self onClickTypeBtn:pincheBtn];
}


- (void)initAddressView{
    
    addressView = [[UIView alloc] initWithFrame:CGRectMake(15, ScreenH - 64 - 137 - 20, ScreenW - 30, 137)];
    addressView.backgroundColor    = [UIColor whiteColor];
    addressView.layer.cornerRadius = 4;
    addressView.layer.borderColor  = [UIColor colorWithWhite:224/255.f alpha:.5].CGColor;
    addressView.layer.borderWidth  = .5f;

    [self.view addSubview:addressView];
    addressView.clipsToBounds = YES;
    

    NSArray* placeholderArr = @[@"您在哪里上车",@"您要去哪里",@"请选择出行人数"];
    NSArray* imgArr = @[@"place_green",@"place_red",@"people_icon"];
    for (int i = 0; i < 3; i++) {
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10 + 45*i, 20, 20)];
        [icon setImage:[UIImage imageNamed:imgArr[i]]];
        [addressView addSubview:icon];
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 45*i, addressView.frame.size.width - CGRectGetMaxX(icon.frame) - 20, 44)];
        textField.placeholder = placeholderArr[i];
        textField.font = Font(15);
        textField.delegate = self;
        [addressView addSubview:textField];
        
        if (i > 0) {
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake(50, 44*i, addressView.frame.size.width - 50, 0.5f)];
            line.backgroundColor = [UIColor colorWithWhite:224/255.f alpha:.6];
            [addressView addSubview:line];
        }
        
        if (i == 0) {
            startTextField = textField;
        }else if(i == 1){
            endTextField = textField;
        }else{
            numberTextField = textField;
        }
    }
}


- (void)initSelectPeopleNumberView{
    
    selectPeopleNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenH - 64, ScreenW, 240)];
    selectPeopleNumberView.backgroundColor = [UIColor colorWithWhite:243/255.f alpha:1];
    [self.view addSubview:selectPeopleNumberView];
    
    UIButton* cancelBtn = [UIButton buttonWithType:0];
    cancelBtn.frame = CGRectMake(0, 0, 80, 44);
    [cancelBtn setTitle:@"取消" forState:0];
    cancelBtn.titleLabel.font = Font(15);
    [cancelBtn addTarget:self action:@selector(onClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor colorWithWhite:180/255.f alpha:1] forState:0];
    [selectPeopleNumberView addSubview:cancelBtn];
    
    UIButton* sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(ScreenW - 80, 0, 80, 44);
    [sureBtn setTitle:@"确定" forState:0];
    sureBtn.titleLabel.font = Font(15);
    [sureBtn addTarget:self action:@selector(onClickSureBtn) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitleColor:[UIColor colorWithRed:1 green:112/255.f blue:67/255.f alpha:1] forState:0];
    [selectPeopleNumberView addSubview:sureBtn];
    
    
    peopleNumberLB = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, selectPeopleNumberView.frame.size.width - 160, 44)];
    peopleNumberLB.textAlignment = NSTextAlignmentCenter;
    peopleNumberLB.font = Font(15);
    peopleNumberLB.text = @"选择人数(1)";
    peopleNumberLB.textColor = [UIColor colorWithRed:1 green:112/255.f blue:67/255.f alpha:1];
    [selectPeopleNumberView addSubview:peopleNumberLB];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, ScreenW, 195)];
    picker.delegate = self;
    picker.dataSource = self;
    picker.backgroundColor = [UIColor whiteColor];
    [selectPeopleNumberView addSubview:picker];
}


- (void)initMoneyView{
    
    moenyView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenH - 64, ScreenW, 137)];
    moenyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:moenyView];
    
    moenyLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, moenyView.frame.size.width, 40)];
    moenyLB.textColor = UIColor_DefOrange;
    moenyLB.text = @"￥200";
    moenyLB.font = Font(30);
    moenyLB.textAlignment = NSTextAlignmentCenter;
    [moenyView addSubview:moenyLB];
    
    discountLB = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(moenyLB.frame), moenyView.frame.size.width, 20)];
    
    discountLB.textColor = UIColor_DefOrange;
    discountLB.text = @"券已抵扣0元";
    discountLB.font = Font(12);
    discountLB.textAlignment = NSTextAlignmentCenter;
//    [moenyView addSubview:discountLB];
    
    UIButton* calloutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    calloutBtn.frame = CGRectMake(15, moenyView.frame.size.height - 44 - 15, moenyView.frame.size.width - 30, 44);
    calloutBtn.backgroundColor = UIColorFromRGB(GloabalTintColor);
    [calloutBtn addTarget:self action:@selector(onClickCalloutBtn) forControlEvents:UIControlEventTouchUpInside];
    [calloutBtn setTitleColor:[UIColor whiteColor] forState:0];
    [calloutBtn setTitle:@"立即呼叫天府专车" forState:0];
    calloutBtn.layer.cornerRadius = 6;
    calloutBtn.layer.masksToBounds = YES;
    calloutBtn.titleLabel.font = Font(17);
    [moenyView addSubview:calloutBtn];
}

- (void)initTimer{
    
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(repeatRequest) userInfo:nil repeats:YES];
        [timer setFireDate:[NSDate distantFuture]];
    }
    routeArr = @[];
}

#pragma mark - http requst - 
////获取车辆位置
//-(void)requstFerryOrderCheckExists{
//    [self startWait];
//    
//    NSString *url = [NSString stringWithFormat:@"%@FerryOrderCheck",KServerAddr];
//    
//    [[NetInterface sharedInstance] httpGetRequest:url body:nil suceeseBlock:^(NSString *msg) {
//        [self stopWait];
//
//        NSDictionary* dic = [JsonUtils jsonToDcit:msg];
//        if ([[dic allKeys] containsObject:@"isExists"]) {
//            if ([dic[@"isExists"] boolValue]) {  //存在
//                UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"温馨提示" message:@"您存在未完成订单" delegate:self];
//                [alertView showInView:self.view];
//                alertView.tag = 2;
//                hasNotfinishOrder = YES;
//                
//                notFinishOrderId = dic[@"order"][@"orderId"];
//            }
//        }
//    } failedBlock:^(NSError *msg) {
//        [self stopWait];
//    }];
//}



-(void)requstFerryOrderCheckState{
    
    if (![orderID isKindOfClass:[NSString class]] || !orderID || orderID.length <= 1) {
        return;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data   = @{@"orderId":orderID};
    }];
}


//取消订单
-(void)requstDeleteFerryOrder{
    if (notFinishOrderId.length < 2) {
        return;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrder_DelectedOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_DELETE;
        params.data = @{@"orderId": notFinishOrderId};
    }];
}


//获取车辆位置
-(void)requstFerryLocationWithCoordinate:(CLLocationCoordinate2D)coordinate{
    [NetManagerInstance sendRequstWithType:KRequestType_FerryLocationPost params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"boardingLatitude":  @(coordinate.latitude),
                        @"boardingLongitude": @(coordinate.longitude)};
    }];
}


//价格计算
- (void)requstFerryOrderWithmileage:(double)_mileage route:(NSArray*)_route actionId:(int)_action{
    NSString *url = [NSString stringWithFormat:@"%@FerryOrder",KServerAddr];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSNumber numberWithInt:_action] forKey:@"action"];
//    [dic setValue:startLocation.name forKey:@"boarding"];
//    [dic setValue:[NSNumber numberWithDouble:startLocation.coordinate.latitude] forKey:@"boardingLatitude"];
//    [dic setValue:[NSNumber numberWithDouble:startLocation.coordinate.longitude] forKey:@"boardingLongitude"];
//    
//    [dic setValue:endLocation.name forKey:@"destination"];
//    [dic setValue:[NSNumber numberWithDouble:endLocation.coordinate.latitude] forKey:@"destinationLatitude"];
//    [dic setValue:[NSNumber numberWithDouble:endLocation.coordinate.longitude] forKey:@"destinationLongitude"];
    
    if (pincheBtn.selected) {
        [dic setValue:[NSNumber numberWithInt:1] forKey:@"type"];
    }else{
        [dic setValue:[NSNumber numberWithInt:2] forKey:@"type"];
    }
    [dic setValue:[NSNumber numberWithLong:0] forKey:@"carpoolOrderId"];
    
    if (pincheBtn.selected) {
        int amount = (int)[picker selectedRowInComponent:0] + 1;
        [dic setValue:@(amount) forKey:@"amount"];
    }
    
    [dic setValue:[NSNumber numberWithDouble:_mileage/1000.f] forKey:@"mileage"];
    
    [dic setValue:_route forKey:@"route"];
    
    [dic setValue:[[NSUUID UUID] UUIDString] forKey:@"virtualId"];
    
    ferryOrderDic = dic;


    [self startWait];
    
    myAction = _action;
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = dic;
    }];
}

- (void)repeatRequest{
    [self requstFerryOrderCheckState];
}


#pragma mark - 点击事件
- (void)backButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClick{
    
    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    
    ruleVC.vcTitle = @"用车说明";
    
    if (pincheBtn.selected) {
        ruleVC.urlString = [NSString stringWithFormat:@"%@rule4.html",KAboutServerAddr];
    }else{
        ruleVC.urlString = [NSString stringWithFormat:@"%@rule5.html",KAboutServerAddr];
    }

    [self.navigationController pushViewController:ruleVC animated:YES];
}

- (void)onClickTypeBtn:(UIButton*)_btn{
    
    [self hiddenMoenyView];

    if (_btn == pincheBtn) {
        [self setSelect:YES button:pincheBtn];
        [self setSelect:NO button:dingzhiBtn];
        
//        addressView.frame = CGRectMake(15, ScreenH - 64 - 137 - 15, ScreenW - 30, 137);
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"IntercityCarpoolingGuideHasLoaded"]) {
            [self setGuideViewWithImageName:@"intercity_carpooling_guide"];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"IntercityCarpoolingGuideHasLoaded"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else{
        [self setSelect:YES button:dingzhiBtn];
        [self setSelect:NO button:pincheBtn];
        
//        addressView.frame = CGRectMake(15, ScreenH - 64 - 92 - 15, ScreenW - 30, 90);
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"CustomcarGuideHasLoaded"]) {
            [self setGuideViewWithImageName:@"customcar_guide"];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"CustomcarGuideHasLoaded"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
        }
    }
    
    [self reloadAddressMoneyView:NO];
    [self performSelector:@selector(routeSearchDecide) withObject:nil afterDelay:.1];
}

- (void)onClickLocationBtn{
    
    [_mapView setCenterCoordinate:currentLocationCoord animated:YES];
    [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.4];
}


- (void)onClickCancelBtn{
    [self hiddenSelectPeopleView];
}

- (void)onClickSureBtn{
    numberTextField.text = [NSString stringWithFormat:@"%d人",(int)[picker selectedRowInComponent:0] + 1];
    [self hiddenSelectPeopleView];
    [self routeSearchDecide];
}

- (void)onClickCalloutBtn{
        
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requstFerryOrderWithmileage:distance route:routeArr actionId:1];
}


#pragma mark - 内部方法
//显示选择人数界面
- (void)showSelectPeopleView{
    moenyView.hidden = YES;
    addressView.hidden = YES;
    [UIView animateWithDuration:0.30f animations:^{
        selectPeopleNumberView.frame = CGRectMake(0, ScreenH - 64 - 240, ScreenW, 240);
    }];
}


- (void)hiddenSelectPeopleView{
    moenyView.hidden = NO;
    addressView.hidden = NO;
    [UIView animateWithDuration:0.30f animations:^{
        selectPeopleNumberView.frame = CGRectMake(0, ScreenH, ScreenW, 240);
    }];
}


//判断是否请求订单
- (void)routeSearchDecide{
//
//    if (pincheBtn.selected) {
//        if (startLocation && endLocation && numberTextField.text.length > 0) {
//            [self routeSearch];
//        }
//    }else{
//        if (startLocation && endLocation) {
//            [self routeSearch];
//        }
//    }
}


//显示支付界面
- (void)showMoneyAddressView{
    [UIView animateWithDuration:0.30f animations:^{
        
        [self reloadAddressMoneyView:YES];

        moenyLB.text = [NSString stringWithFormat:@"￥%.2f",[price floatValue]/100.f];
        discountLB.text = [NSString stringWithFormat:@"券已抵扣%@元",discount];
    }];
}



- (void)hiddenMoenyView{
    [UIView animateWithDuration:0.30f animations:^{
        [self reloadAddressMoneyView:NO];
    }];
}


- (void)reloadAddressMoneyView:(BOOL)_showMoneyView{
    if (pincheBtn.selected) {
        if (_showMoneyView) {
            addressView.frame = CGRectMake(15, ScreenH - 64 - 137 - 145 - 20, ScreenW - 30, 137);
            moenyView.frame = CGRectMake(0, ScreenH - 64 - 145, ScreenW, 145);
        }else{
            addressView.frame = CGRectMake(15, ScreenH - 64 - 137 - 20, ScreenW - 30, 137);
            moenyView.frame = CGRectMake(0, ScreenH - 64, ScreenW, 145);
        }
    }else{
        if (_showMoneyView) {
            addressView.frame = CGRectMake(15, ScreenH - 64 - 90 - 145 - 20, ScreenW - 30, 90);
            moenyView.frame = CGRectMake(0, ScreenH - 64 - 145, ScreenW, 145);
        }else{
            addressView.frame = CGRectMake(15, ScreenH - 64 - 90 - 20, ScreenW - 30, 90);
            moenyView.frame = CGRectMake(0, ScreenH - 64, ScreenW, 145);
        }
    }
}



- (void)setSelect:(BOOL)_isSelect button:(UIButton*)_btn{
    _btn.selected = _isSelect;
    
    if (_isSelect) {
        _btn.backgroundColor = [UIColor whiteColor];
        _btn.layer.cornerRadius = 16;
        _btn.layer.masksToBounds = YES;
        _btn.layer.borderWidth = .5f;
        _btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    }else{
        _btn.backgroundColor = [UIColor clearColor];
        _btn.layer.cornerRadius = 0;
        _btn.layer.masksToBounds = NO;
        _btn.layer.borderWidth = 0;
        [_btn setImageEdgeInsets:UIEdgeInsetsZero];
    }
}


//设置引导页
- (void)setGuideViewWithImageName:(NSString*)_str{
    guideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
    guideView.backgroundColor = [UIColor colorWithWhite:0 alpha:.7f];
    [[UIApplication sharedApplication].keyWindow addSubview:guideView];
    
    UIImage* img = [UIImage imageNamed:_str];
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    [imgView setImage:img];
    [imgView setCenter:CGPointMake(ScreenW/2 - 4, ScreenH/2 - 16)];
    [guideView addSubview:imgView];
    
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(singleGuide:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight)];
    [guideView addGestureRecognizer:recognizer];
    
    
    UITapGestureRecognizer* guideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGuide:)];
    [guideView addGestureRecognizer:guideTap];
    
}

- (void)singleGuide:(UITapGestureRecognizer *)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:.4];
    [UIView setAnimationDidStopSelector:@selector(animateStop)];
    guideView.alpha = 0;
    [UIView commitAnimations];
}

- (void)animateStop{
    [guideView removeFromSuperview];
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


- (void)refrshCalloutView{
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
        _regeoRequest.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        [_searchAPI AMapReGoecodeSearch:_regeoRequest];
    }else{
        if (currentTextField == startTextField) {
            [self showTip:@"请选择红色范围内的地点作为上车点!"];
        }else if (currentTextField == endTextField){
            [self showTip:@"请选择红色范围内的地点作为下车点!"];
        }
    }
}



- (void)showTip:(NSString*)tip{
    
    UILabel* myTipLB = (UILabel*)[self.view viewWithTag:1021];
    
    if (myTipLB == nil) {
        myTipLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, ScreenW, 25)];
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





#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    isMapRegionChanged = YES;

    return YES;
}

- (void)swipeGestureRecognizerMapView{
    isMapRegionChanged = YES;
    
    NSLog(@"swipe");

}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    currentLocationCoord = userLocation.coordinate;
    
    if (isFirstLocation) {
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.1];
        [self requstFerryLocationWithCoordinate:userLocation.coordinate];
    }
    
    isMapRegionChanged = NO;
    isFirstLocation = NO;
//    _mapView.showsUserLocation = NO;
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    isMapRegionChanged = NO;
    NSLog(@"定位失败");
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    //添加标注
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        
        if (annotationView == nil){
            
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            
        }
        
        annotationView.image = [UIImage imageNamed:@"coordinator_small"];
        
        annotationView.canShowCallout = NO;
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
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


- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (isMapRegionChanged) {
        [annotationBtn.layer addAnimation:[self moveAnimation] forKey:nil];
        
        [self performSelector:@selector(refrshCalloutView) withObject:nil afterDelay:.1];
    }
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


#pragma mark - AMapSearchDelegate
- (void)searchRequest:(id)request didFailWithError:(NSError *)error{
    
    [self stopWait];

    NSLog(@"request = %@", error);
}

//- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
//    
//    NSMutableArray* routeArray = [NSMutableArray array];
//
//    int i = 0;
//    for (AMapStep* object in ((AMapPath *)(response.route.paths[0])).steps) {
//
//        NSArray* arr = [object.polyline componentsSeparatedByString:@";"];
//        
//
//        for (NSString* str in arr) {
//            NSArray* arr2 = [str componentsSeparatedByString:@","];
//            if (arr2 && arr2.count == 2) {
//                NSDictionary* dic = @{@"lon":arr2[0],@"lat":arr2[1]};
//                [routeArray addObject:dic];
//            }
//        }
//        
//        i++;
//    }
//
//    distance = ((AMapPath *)(response.route.paths[0])).distance;
//    routeArr = routeArray;
//    
//    [self requstFerryOrderWithmileage:((AMapPath *)(response.route.paths[0])).distance route:routeArray actionId:0];
//}


- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    if(response.regeocode != nil){

//        startLocation = [[FNLocation alloc] init];
//        currentTextField = startTextField;
//        if (response.regeocode.pois.count > 0) {
//            AMapPOI* poi = response.regeocode.pois[0];
//            startTextField.text = [NSString stringWithFormat:@"[当前位置]%@",poi.name];
//            startLocation.name = poi.name;
//        }
//        startLocation.address = response.regeocode.formattedAddress;
//        startLocation.coordinate = _mapView.region.center;
//        [self routeSearchDecide];
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
//    TianFuCarPayVC *tfcPayVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"tianfucarpay"];
//    [timer invalidate];
//    [self.navigationController pushViewController:tfcPayVC animated:YES];
//    
//    return NO;
    
//    TFCarEvaluationVC *tfcVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
//    tfcVC.isTianFuCar = YES;
//    [self.navigationController pushViewController:tfcVC animated:YES];
//    
//    return NO;
    
    currentTextField = textField;

    if (textField == numberTextField) {
        [self showSelectPeopleView];
    }else{
        AddressSearchVC* vc = [[AddressSearchVC alloc] init];
        vc.myDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }

    return NO;
}



#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 14;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 48;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = view ? (UILabel *) view : [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:17]];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%ld",row + 1];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    peopleNumberLB.text = [NSString stringWithFormat:@"选择人数(%ld人)",row + 1];
}

#pragma mark - AlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    
    
    if (btnIndex == 0) {
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        if (alertView.tag == 1) { //下订单
            [self requstFerryOrderWithmileage:distance route:routeArr actionId:1];

        }
        
        if (alertView.tag == 2) {
            [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
        }


        if (alertView.tag == 3) { //取消订单
//            [self requstDeleteFerryOrder];
            [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
        }
        
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
    }
}

#pragma mark - AddressSearchDelegate
//- (void)searchLocation:(FNLocation *)location{
//    [self hiddenTip];
//    
//    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
//    
//    //默认设置不在围栏里面
//    BOOL isContains = NO;
//    //再查看是否中围栏里面
//    for (NSDictionary *fenceDic in coordinateModule.fenceArray) {
//        
//        NSArray *coordinateArr = [fenceDic objectForKey:@"fences"];
//        int ringCount   = (int)coordinateArr.count;
//        //构造多边形数据对象
//        CLLocationCoordinate2D ringCoordinates[ringCount];
//        //三环坐标数组
//        for (int i = 0; i < ringCount; i++) {
//            
//            ringCoordinates[i].latitude = [(coordinateArr[i])[@"latitude"] floatValue];
//            ringCoordinates[i].longitude = [(coordinateArr[i])[@"longitude"] floatValue];
//        }
//        //判断是否中中部
//        if([ContainsMutable isContainsMutableBoundCoords:ringCoordinates count:ringCount coordinate:location.coordinate])
//        {
//            isContains = YES;
//        }
//    }
//    
//    if (isContains) {
////        if (currentTextField == startTextField) {
////            startLocation = location;
////            [_mapView setCenterCoordinate:location.coordinate animated:YES];
////        }else{
////            endLocation = location;
////        }
//        currentTextField.text = location.name;
//        currentTextField = startTextField;
//        [self routeSearchDecide];
//    }else{
//        if (currentTextField == startTextField) {
//            [self showTip:@"请选择红色范围内的地点作为上车点!"];
//        }else if (currentTextField == endTextField){
//            [self showTip:@"请选择红色范围内的地点作为下车点!"];
//        }
//    }
//}



#pragma mark -- Receive APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
//    [timer setFireDate:[NSDate distantFuture]];
    
    //29.天府专车支付反馈（会员端）
    if ([userInfo[@"processType"] intValue] != 24) {
        return;
    }
    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([userInfo[@"state"] intValue] == 1) {
        [self pushWitingViewController];
    }else{
        [MBProgressHUD showTip:((NSDictionary*)userInfo[@"aps"])[@"alert"] WithType:FNTipTypeWarning withDelay:4];
    }
}


//跳转到等待界面
- (void)pushWitingViewController{
  
    [self stopWait];
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    BaiDuCarWaitOrder *waitOrderVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitorder"];
//    waitOrderVC.userLatitude  = startLocation.coordinate.latitude;
//    waitOrderVC.userLongitude = startLocation.coordinate.longitude;
    waitOrderVC.orderId       = orderID;
    waitOrderVC.typeId = 1;
    [self.navigationController pushViewController:waitOrderVC animated:YES];
}


-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == KRequestType_FerryOrderCheck) {
        
        if ([resultData.data[@"resultState"] intValue] == 1) { //订单是否提交成功 resultState=1成功 0 不成功
            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]);
            if ([resultData.data[@"order"][@"state"] intValue] == 1){
                [self pushWitingViewController];
            }
        }
        
    }else if (type == KRequestType_FerryOrder_DelectedOrder){
    
        if (resultData.resultCode == 0) {
            [MBProgressHUD showTip:@"取消订单成功" WithType:FNTipTypeSuccess];
        }
        
    }else if (type == KRequestType_FerryLocationPost){
        
        NSArray* listArr = nil;
        //        listArr = @[@{@"longitude":@"104.06480",@"latitude":@"30.543416"}];
        if ([[resultData.data allKeys] containsObject:@"list"]) {
            listArr = resultData.data[@"list"];
        }
        
        for (NSDictionary*dic in listArr) {
            MAPointAnnotation* carAnno = [[MAPointAnnotation alloc] init];
            carAnno.coordinate = CLLocationCoordinate2DMake([dic[@"latitude"] floatValue], [dic[@"longitude"] floatValue]);
            [_mapView addAnnotation:carAnno];
        }
        
    }else if (type == KRequestType_FerryOrder){
        
        if (resultData.resultCode == 0) {
            
            price = [resultData.data objectForKey:@"price"];
            discount = [resultData.data objectForKey:@"discount"];
            
            orderID = [NSString stringWithFormat:@"%@",[resultData.data objectForKey:@"orderId"]];
            
            
            if (myAction == 0) {
                [self stopWait];
                [self showMoneyAddressView];
            }else{
                [timer setFireDate:[NSDate distantPast]];
            }
        }else if (resultData.resultCode == 100002) {
            
            //鉴权失效重置token
            [[UserPreferences sharedInstance] setToken:nil];
            [[UserPreferences sharedInstance] setUserId:nil];
            
            // 进入登录界面
            [LoginViewController presentAtViewController:self completion:^{
                [MBProgressHUD showTip:@"请登录！" WithType:FNTipTypeFailure];
            }callBalck:^(BOOL isSuccess, BOOL needToHome) {
                if (!isSuccess && [self isKindOfClass:NSClassFromString(@"TravelHistoryViewController")]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else if(isSuccess){
                    [self requstFerryOrderWithmileage:distance route:routeArr actionId:myAction];
                }
            }];
            //重置别名
            [[PushConfiguration sharedInstance] resetAlias];
            [self showTipsView:resultData.message];
            
        }else if (resultData.resultCode == 200001) {
            UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"你有未完成的订单，是否现在查看?" delegate:self cancelButtonTitle:@"立即查看" otherButtonTitles:@"取消", nil];
            [alter show];
        }
        
    }
        
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
    RequestType type = [notification.object[@"type"] intValue];
    
    if (type == KRequestType_FerryOrder) {
        [self showTipsView:@"服务器出错了!"];
    }
    
}


@end
