//
//  ShuttleStationViewCotroller.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ShuttleStationViewCotroller.h"
#import "ShuttleGeneralTableViewCell.h"
#import "ShuttleStarEndTableViewCell.h"
#import "CallCarStateViewController.h"

#import <FNUIView/CustomPickerView.h>
#import <FNUIView/DatePickerView.h>
#import "PhoneNumberView.h"
#import "ShuttleModel.h"
#import "ChooseStationViewController.h"
#import "FNSearchViewController.h"
#import "FNSearchMapViewController.h"
#import "FNLocation.h"
#import <MAMapKit/MAMapKit.h>
#import "ChooseStationObj.h"
#import "PayCarViewController.h"
#import "SeleterPersonView.h"
#import "MapCoordinaterModule.h"

#import "PushNotificationAdapter.h"
#import "MapViewManager.h"
#import "LoginViewController.h"
#import "DateSelectorView.h"
#import "AddressManager.h"
#import "FNSearchManager.h"
#import "UILabel+Address.h"
#import "AddressBookHelp.h"




typedef NS_ENUM(int, ShuttleOrderType)
{
    OrderType_SongJi      = 1,
    OrderType_JieJi       = 2,
    OrderType_SongQiChe   = 4,
    OrderType_JieQiChe    = 5,
    OrderType_SongHuoChe  = 6,
    OrderType_JieHuoChe   = 7,
};

#define StarText @"在哪上车？"
#define EndText  @"在哪下车？"
@interface ShuttleStationViewCotroller ()<FNSearchViewControllerDelegate,FNSearchMapViewControllerDelegate,AMapSearchDelegate>
{
//    __weak IBOutlet UILabel *navTitleLab;
    __weak IBOutlet UISegmentedControl *navSegmented;
    __weak IBOutlet UIView *tableViewHeaderView;
    
    __weak IBOutlet NSLayoutConstraint *topLayout;      //选择起点地址
    __weak IBOutlet NSLayoutConstraint *bottomLayout;   //选择终点地址
    __weak IBOutlet UIView *addressView;
    
    
    //公里
    __weak IBOutlet UILabel *mileageLab;
    //单价-单位
    __weak IBOutlet UILabel *employerLab;
    //单价
    __weak IBOutlet UILabel *priceLab;
    //总价
    __weak IBOutlet UILabel *totalMoneyLab;
    //优惠券
    __weak IBOutlet UILabel *couponsLab;
    //时间
    __weak IBOutlet UILabel *dateLab;
    //开始地址
    __weak IBOutlet UILabel *starAddressLab;        //tag  20
    //终点地址
    __weak IBOutlet UILabel *endAddressLab;         //tag  21
    //人数
    __weak IBOutlet UILabel *personLab;
    
    __weak IBOutlet UIView *starView;
    __weak IBOutlet UIView *endView;
    __weak IBOutlet UIButton *nextButton;
    //电话号码
    __weak IBOutlet UITextField *phoneNumTextField;
    
    __weak IBOutlet UITableView *myTableView;
    
    NSDictionary *dataRangeDic;
    NSMutableArray *personArr;  //选择人数数组
    NSMutableArray *tableModel;
    
    ShuttleModel *submitModel;  //包含电话、日期、起点、终点、人数
    
    BOOL isChange;              //是否切换 送 or  接
    NSInteger orderType;        //接送机类型    送机1 接机2 送汽车4 接汽车5 送火车站6 接火车站7
    
    //订单是否生成成功
    BOOL isGenerateOrder;
    AddressBookHelp *addressBookHelp;
}
@end

@implementation ShuttleStationViewCotroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    submitModel = [[ShuttleModel alloc] init];
    [self configCustomView];
    [self initUserDatas];
    
//    [self fetchDateRangeRequest];
    addressBookHelp = [[AddressBookHelp alloc] initWithAddressDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generateOrderSuccessNofitifation:) name:FNPushType_CallCarGenerateOrder object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [phoneNumTextField addTarget:self action:@selector(phoneNumTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)fetchDateRangeRequest
{
//    //获取时间范围
//    [self startWait];
//    [NetManagerInstance sendRequstWithType:EmRequestType_GetDateRange params:^(NetParams *params) {
//    }];
}

- (void)initUserDatas
{
    //配置默认选择地点
    if (_defaultLocation && _defaultLocation.name.length > 0) {
        
        FNLocation *location = [FNLocation new];
        location.name = _defaultLocation.name;
        location.coordinate = CLLocationCoordinate2DMake([_defaultLocation.latitude doubleValue], [_defaultLocation.longitude doubleValue]);
        
        starAddressLab.text = _defaultLocation.name;
        starAddressLab.location = location;
    }else{
        starAddressLab.text = EndText;
    }
    
    
    //如果没有地址--请求地址
    AddressManager *address = [AddressManager sharedInstance];
    if (!address.allAddressArray || address.allAddressArray.count == 0) {
        [self startWait];
        MapCoordinaterModule *module = [MapCoordinaterModule sharedInstance];
        [NetManagerInstance sendRequstWithType:EmRequestType_GetCommonAddress params:^(NetParams *params) {
//            params.data = @{@"adCode":@(module.adCode),
//                            @"type" : @(0)};    //type 0 请求所有站点
        }];
    }else{
        //默认显示第一个
        ChooseStationObj *choose = [address defaultChooseAddressForType:self.shuttleStation];
        if (choose) {
            FNLocation *location = [FNLocation new];
            location.name = choose.name;
            location.coordinate = CLLocationCoordinate2DMake([choose.latitude doubleValue], [choose.longitude doubleValue]);
            
            endAddressLab.text = choose.name;
            endAddressLab.location = location;
            [self calculatemMileage];
        }else{
            endAddressLab.text = StarText;
        }
    }
    //配置默认手机号
//    User *user = [UserPreferInstance getUserInfo];
//    if (user && user.phone && user.phone.length > 0) {
//        phoneNumTextField.text = user.phone;
//        submitModel.phoneNumber = user.phone;
//    }
//    
    //默认一位乘客
    submitModel.peopleNumber = @(1);
    submitModel.mileage = @(0);
    
    personArr = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 9; i++) {
        [personArr addObject:[NSString stringWithFormat:@"%d人",i]];
    }
    
    
    //获取默认单价--请求
    //传1、1 获取单价
    ShuttleModel *shuttle = [[ShuttleModel alloc] init];
    shuttle.peopleNumber = @(1);
    shuttle.mileage = @(1);
    [self sendCalculatePrice:shuttle];
}

- (void)configCustomView
{
    NSString *navFirst = @"接站";
    NSString *navSecond = @"送站";
    switch (_shuttleStation) {
        case ShuttleStationTypeBus:
        {
//            navTitleLab.text = @"汽车站接送";
            orderType = 1;
        }
            break;
        case ShuttleStationTypeAirport:
        {
//            navTitleLab.text = @"机场接送";
            orderType = 3;
            navFirst = @"接机";
            navSecond = @"送机";
            
//            [stationBtn setTitle:@"接机" forState:UIControlStateNormal];
//            [sendStationBtn setTitle:@"送机" forState:UIControlStateNormal];
        }
            break;
        case ShuttleStationTypeTrain:
        {
//            navTitleLab.text = @"火车站接送";
            orderType = 2;
        }
            break;
            
        default:
            break;
    }
    
    [navSegmented setTitle:navFirst forSegmentAtIndex:0];
    [navSegmented setTitle:navSecond forSegmentAtIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark actions

- (IBAction)clickTapActions:(UITapGestureRecognizer *)sender
{
    //关闭键盘
    [phoneNumTextField resignFirstResponder];
    
    NSInteger tag = sender.view.tag - 10;
    switch (tag) {
        case 0:     //电话
        {
            
            [phoneNumTextField becomeFirstResponder];
//            PhoneNumberView *phoneView = [[PhoneNumberView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
//            phoneView.addressDelegate = self;
//            phoneView.clickComplete = ^(NSString *phoneNumber){
//                if (![BCBaseObject isMobileNumber:phoneNumber]) {
//                    [self showTipsView:@"请输入正确的手机号！"];
//                    return;
//                }
//                submitModel.phoneNumber = phoneNumber;
//                phoneLab.text = phoneNumber;
//            };
//            [phoneView showInView:self.view];
        }
            break;
        case 1:     //时间
        {
//            if (!dataRangeDic) {
//                [self fetchDateRangeRequest];
//                return;
//            }
            NSString *starTime = @"00:00:00";
            NSString *endTime  = @"23:59:00";
            NSInteger precision= 10;
            DateSelectorView *dateView = [[DateSelectorView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH) starTime:starTime endTime:endTime minuteInterval:precision];
            dateView.clickCompleteBlock = ^(NSString *showDateString,NSString *useDate,BOOL isReal){
                submitModel.date = useDate;
                submitModel.realTime = isReal;
                
                //是否是立即预约
                if (isReal == 1) {
                    dateLab.text = showDateString;
                }else{
                    dateLab.text = [showDateString substringToIndex:showDateString.length - 3];
                }
            };
            [dateView showInView:self.view];
        }
            break;
        case 2:     //起点
        {
            [self performSegueWithIdentifier:@"FNSearchMapViewController" sender:nil];
        }
            break;
        case 3:     //终点
        {
            [self performSegueWithIdentifier:@"ChooseStationViewController" sender:nil];
        }
            break;
        case 4:     //人数
        {
            CustomPickerView *pickerView = [[CustomPickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH) dataSourceArray:personArr useType:1];
            pickerView.clickComplete = ^(NSString *resultString){
                submitModel.peopleNumber = [NSNumber numberWithInt:[resultString intValue]];
                personLab.text = resultString;

                [self sendCalculatePrice:submitModel];
            };
            [pickerView showInView:self.view];
            
//            [pickerView showInView:self.view];
//            SeleterPersonView *personView = [[SeleterPersonView alloc] init];
//            [personView showInView:self.view];
//            personView.clickSeleterPersonCount = ^(NSInteger personCount){
//                submitModel.peopleNumber = @(personCount);
//                personLab.text = [NSString stringWithFormat:@"%ld人",personCount];
//
//                [self sendCalculatePrice:submitModel];
//            };
        }
            break;
            
        default:
            break;
    }
}


- (IBAction)changeStationAction:(UISegmentedControl *)sender
{
    NSInteger tag = sender.selectedSegmentIndex;
    switch (tag) {
        case 0:     //接
        {
            isChange = NO;
        }
            
            break;
        case 1:     //送
        {
            isChange = YES;
        }
            
            break;
            
        default:
            break;
    }
    [self assignmentSubmitModel];
    
    if (isChange) {
        submitModel.starAddressName != nil ? (starAddressLab.text = submitModel.starAddressName) : (starAddressLab.text = StarText);
        submitModel.endAddressName != nil ? (endAddressLab.text  = submitModel.endAddressName) : (endAddressLab.text  = EndText);
//        if (!submitModel.starAddressName) {
//            endAddressLab.text = StarText;
//        }
//        if (!submitModel.endAddressName) {
//             starAddressLab.text  = EndText;
//        }
        [UIView animateWithDuration:0.5 animations:^{
            topLayout.constant = 54;
            bottomLayout.constant = 54;
            [addressView layoutIfNeeded];
        }];
    }else{
        submitModel.starAddressName != nil ? (endAddressLab.text = submitModel.starAddressName) : (endAddressLab.text = StarText);
        submitModel.endAddressName != nil ? (starAddressLab.text  = submitModel.endAddressName) : (starAddressLab.text  = EndText);
//        if (!submitModel.starAddressName) {
//            starAddressLab.text = StarText;
//        }
//        if (!submitModel.endAddressName) {
//            endAddressLab.text  = EndText;
//        }
        [UIView animateWithDuration:0.5 animations:^{
            topLayout.constant = 0;
            bottomLayout.constant = 0;
            [addressView layoutIfNeeded];
        }];
    }
}

//选择通讯录号码
- (IBAction)clickChoosePhoneNumAction:(UIButton *)sender
{
    [addressBookHelp showAddressBookController];
    __weak typeof(self) weakSelf = self;
    __weak typeof(phoneNumTextField) weakPhoneNumTextField = phoneNumTextField;
    __weak typeof(submitModel) weakSubmitModel = submitModel;
    addressBookHelp.clickComplete = ^(NSString *phoneNum, NSString *error){
        if (error) {
            [weakSelf showTipsView:error];
        }else{
            weakSubmitModel.phoneNumber = phoneNum;
            weakPhoneNumTextField.text = phoneNum;
        }
    };
}

- (void)phoneNumTextFieldDidChange:(UITextField *)textField
{
    if (textField == phoneNumTextField) {
        if (textField.text.length > 11) {
            phoneNumTextField.text = [textField.text substringToIndex:11];
        }
        submitModel.phoneNumber = textField.text;
    }
}

//点击tableView
- (IBAction)tableViewClickAction:(UITapGestureRecognizer *)sender
{
    [phoneNumTextField resignFirstResponder];
}

#pragma mark 提交订单
- (IBAction)clickNextSubmitOrder:(UIButton *)sender
{
    [self assignmentSubmitModel];
    if ([self checkSubmitButtonState]) {
        [self checkOrderType];
        
        MapCoordinaterModule *mound = [MapCoordinaterModule sharedInstance];
        if (mound.fenceArray.count == 0) {
            [self showTipsView:@"围栏数据出错啦~"];
            return;
        }
        
        if (orderType == OrderType_JieJi || orderType == OrderType_JieQiChe ||orderType == OrderType_JieHuoChe) {
            BOOL isContainsMutable = [mound isContainsInFenceWithLatitude:submitModel.endAddress.latitude longitude:submitModel.endAddress.longitude];
            if (!isContainsMutable) {
                [self showTipsView:@"抱歉！该位置未开通飞牛巴士服务。"];
                return;
            }
        }
        else {
            BOOL isContainsMutable = [mound isContainsInFenceWithLatitude:submitModel.starAddress.latitude longitude:submitModel.starAddress.longitude];
            if (!isContainsMutable) {
                [self showTipsView:@"抱歉！该位置未开通飞牛巴士服务。"];
                return;
            }
        }
        
        [self startWait];
//        获取起始地址
        [NetManagerInstance sendRequstWithType:EmRequestType_PostDedicatedOrder params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            MapCoordinaterModule *module = [MapCoordinaterModule sharedInstance];
            params.data = @{
                @"orderType"    :@(orderType),
                @"useDate"      :submitModel.date,
                @"peopleNumber" :submitModel.peopleNumber,
                @"starting"     :submitModel.starAddressName,
                @"sLatitude"    :@(submitModel.starAddress.latitude),
                @"sLongitude"   :@(submitModel.starAddress.longitude),
                @"destination"  :submitModel.endAddressName,
                @"dLatitude"    :@(submitModel.endAddress.latitude),
                @"dLongitude"   :@(submitModel.endAddress.longitude),
//                @"adCode"       :@(module.adCode),
                @"mileage"      :submitModel.mileage,
                @"contactPhone" :submitModel.phoneNumber,
                @"realTime"     :@(submitModel.realTime)
            };
        }];
        NSLog(@"起点%@---终点%@",submitModel.starAddressName,submitModel.endAddressName);
    }
}

//
- (void)assignmentSubmitModel
{
    FNLocation *starLocation;
    FNLocation *endLocation;
    if (isChange) {
        endLocation = endAddressLab.location;
        starLocation = starAddressLab.location;
    }else{
        starLocation = endAddressLab.location;
        endLocation = starAddressLab.location;
    }
    
    submitModel.starAddressName = starLocation.name;
    submitModel.starAddress = starLocation.coordinate;
    submitModel.endAddressName = endLocation.name;
    submitModel.endAddress = endLocation.coordinate;
}

- (IBAction)btnBack:(id)sender {
    [self popViewController];
}

- (void)sendCalculatePrice:(ShuttleModel*)shuttle
{
    if (shuttle.peopleNumber && shuttle.mileage) {
        [self startWait];
        [self checkOrderType];
        [NetManagerInstance sendRequstWithType:EmRequestType_GetPrice params:^(NetParams *params) {
            params.data = @{@"peopleNumber":shuttle.peopleNumber,
                            @"mileage":shuttle.mileage,
                            @"ordertype":@(orderType)};
        }];
    }
}

#pragma mark HTTP
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *result = [notification object];
//    if (result.type == EmRequestType_GetDateRange) {    //日期范围---暂时不调用
//        [self stopWait];
//        dataRangeDic = result.data;
//        
//    }else
    if (result.type == EmRequestType_GetPrice){       //计算价格
        [self stopWait];
        //单价
        priceLab.text = [NSString stringWithFormat:@"%.2f元",[result.data[@"unitPrice"] intValue]/100.0];
        employerLab.text = [NSString stringWithFormat:@"/%@",result.data[@"employer"]];
        
        //总价
        double coupon = [result.data[@"couponPrice"] doubleValue]/100.0;
        double price = [result.data[@"price"] doubleValue]/100.0;
        double totalMoney = price - coupon;
        if (!endAddressLab.location) {
            totalMoney = 0;
        }else{
            totalMoney = totalMoney > 0 ? totalMoney : 0.01;
        }
        totalMoneyLab.text = [NSString stringWithFormat:@"%.2f元",totalMoney];
        
        
        if (coupon >= price) {
            couponsLab.text = [NSString stringWithFormat:@"优惠券已抵用%.2f元",price - 0.01]; //优惠
        }else{
            couponsLab.text = (coupon > 0) ? [NSString stringWithFormat:@"优惠券已抵用%.2f元",coupon] : @""; //优惠
        }
        submitModel.coupon = coupon;
        submitModel.totalPrice = result.data[@"price"];
        
    }else if (result.type == EmRequestType_PostDedicatedOrder){     //提交订单
        
        submitModel.orderId = result.data[@"orderId"];

        //提交订单后 等待20秒 如果没有推送手动查询一次
        isGenerateOrder = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!isGenerateOrder) {
                isGenerateOrder = YES;
                [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedOrder params:^(NetParams *params) {
                    params.data = @{@"orderId":submitModel.orderId};
                }];
            }
        });

    }else if (result.type == EmRequestType_GetDedicatedOrder){      //获取订单信息
        
        [self stopWait];
        //==1
        if ([result.data[@"state"] integerValue] == 1) {
            
            ShuttleModel *model = [ShuttleModel mj_objectWithKeyValues:result.data[@"order"]];
            model.totalPrice = submitModel.totalPrice;
            
            PayCarViewController *payController = [PayCarViewController instanceWithStoryboardName:@"Bus"];
            payController.shuttleModel = model;
            [self.navigationController pushViewController:payController animated:YES];
            //[self performSegueWithIdentifier:@"toPaymentViewController" sender:model];
            
        }else{
            [self showTipsView:@"对不起，您出行的时间小牛已经全部有约，请您尝试下其他用车时间"];
        }
    }else if(result.type == EmRequestType_GetCommonAddress){    //获取站点
        
        AddressManager *address = [AddressManager sharedInstance];
        address.allAddressArray = result.data;
        
        //默认显示第一个
        ChooseStationObj *choose = [address defaultChooseAddressForType:self.shuttleStation];
        if (choose) {
            FNLocation *location = [FNLocation new];
            location.name = choose.name;
            location.coordinate = CLLocationCoordinate2DMake([choose.latitude doubleValue], [choose.longitude doubleValue]);
            
            endAddressLab.text = choose.name;
            endAddressLab.location = location;
            [self calculatemMileage];
            
        }else{
            endAddressLab.text = EndText;
        }
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

#pragma marks  FNSearchDelegate
- (void)searchViewController:(FNSearchViewController *)searchViewController didSelectLocation:(FNLocation *)location
{
    BOOL isFence = [self checkLocationInFenceWithLatitude:location.latitude longitude:location.longitude];
    if (!isFence) {
        return;
    }
    [self configStarAddress:location];
}

- (void)searchMapViewController:(FNSearchMapViewController *)searchViewController didSelectLocation:(FNLocation *)location
{
    BOOL isFence = [self checkLocationInFenceWithLatitude:location.latitude longitude:location.longitude];
    if (!isFence) {
        return;
    }
    [self configStarAddress:location];
}

- (void)configStarAddress:(FNLocation *)location
{
    starAddressLab.text = location.name;
    starAddressLab.location = location;
    [self calculatemMileage];
}

- (BOOL)checkLocationInFenceWithLatitude:(double)latitude longitude:(double)longitude
{
    MapCoordinaterModule *coordinateModule = [MapCoordinaterModule sharedInstance];
    BOOL isContainsMutable = [coordinateModule isContainsInFenceWithLatitude:latitude longitude:longitude];
    
    if (!isContainsMutable) {
        [self showTipsView:@"抱歉！该位置未开通飞牛巴士服务。"];
    }
    
    return isContainsMutable;
}

#pragma marks -help

//计算两点里程
- (void)calculatemMileage
{
    CLLocationCoordinate2D starLocation = starAddressLab.location.coordinate;
    CLLocationCoordinate2D endLocation = endAddressLab.location.coordinate;

    if ((starLocation.latitude !=0 && starLocation.longitude) && (endLocation.latitude !=0 && endLocation.longitude != 0)) {
        
        AMapGeoPoint *starPoint = [AMapGeoPoint locationWithLatitude:starLocation.latitude longitude:starLocation.longitude];
        AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:endLocation.latitude longitude:endLocation.longitude];
        
        AMapDrivingRouteSearchRequest *routeRequest = [[AMapDrivingRouteSearchRequest alloc] init];
        routeRequest.origin = starPoint;
        routeRequest.destination = endPoint;
        routeRequest.strategy = 2;
        
        FNSearchManager *manager = [FNSearchManager sharedInstance];
        [manager searchForRequest:routeRequest completionBlock:^(AMapRouteSearchBaseRequest *request, AMapRouteSearchResponse *response, NSError *error) {
            if (error || !response || response.route.paths == nil || response.route.paths.count == 0 || response.route.paths[0] == nil) {
                
                [self showTipsView:@"网络连接异常，请重试"];
                submitModel.mileage = @(0);
                mileageLab.text = @"0.0";
                return;
            }
            
            AMapPath *path = response.route.paths[0];
            //米
            NSString *distanceString = [NSString stringWithFormat:@"%ld",path.distance];
            double distanceDouble = [distanceString doubleValue];
            submitModel.mileage = @(distanceDouble);
            
            //公里
            mileageLab.text = [NSString stringWithFormat:@"%.2f",distanceDouble/1000];
            
            [self sendCalculatePrice:submitModel];
        }];
    }
}

- (BOOL)checkSubmitButtonState
{
    if (!submitModel.phoneNumber) {
        [self showTipsView:@"请输入联系人！"];
        return NO;
    }else{
        if (![BCBaseObject isMobileNumber:phoneNumTextField.text]) {
            [self showTipsView:@"请输入正确的电话号码！"];
            return NO;
        }
    }
    if (!submitModel.date) {
        [self showTipsView:@"请选择时间！"];
        return NO;
    }
    if (submitModel.starAddress.latitude == 0 || submitModel.starAddress.longitude == 0) {
        [self showTipsView:@"请选择出发地！"];
        return NO;
    }
    if (submitModel.endAddress.latitude == 0 || submitModel.endAddress.longitude == 0) {
        [self showTipsView:@"请选择目的地！"];
        return NO;
    }
    if ([submitModel.peopleNumber integerValue] == 0) {
        [self showTipsView:@"请选择人数！"];
        return NO;
    }
    if ([submitModel.mileage doubleValue] == 0.0) {
        [self calculatemMileage];
        return NO;
    }
    
    return YES;
}

/**
 *  检测订单类型
 *
 *  @return
 */
- (void)checkOrderType
{
    //isChange YES 接机   NO 是送机

   switch (_shuttleStation) {
        case ShuttleStationTypeBus:
        {
            orderType = isChange ? OrderType_SongQiChe : OrderType_JieQiChe;
        }
            break;
        case ShuttleStationTypeAirport:
        {
            orderType = isChange ? OrderType_SongJi : OrderType_JieJi;
        }
            break;
        case ShuttleStationTypeTrain:
        {
            orderType = isChange ? OrderType_SongHuoChe : OrderType_JieHuoChe;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString *identifierStr = segue.identifier;
    //选择终点
    if ([identifierStr isEqualToString:@"ChooseStationViewController"]) {
        ChooseStationViewController *chooseController = [segue destinationViewController];
        chooseController.navTitle = isChange ? @"选择上车地点" : @"选择下车地点";
        chooseController.type = self.shuttleStation;
        chooseController.adressName = submitModel.endAddressName;
        chooseController.clickPopAction = ^(ChooseStationObj *choose){
            
            endAddressLab.text = choose.name;
            
            FNLocation *location = [FNLocation new];
            location.name = choose.name;
            location.coordinate = CLLocationCoordinate2DMake([choose.latitude doubleValue],[choose.longitude doubleValue]);
            endAddressLab.location = location;
            
            [self calculatemMileage];
        };
    }else if ([identifierStr isEqualToString:@"FNSearchViewController"]){
        FNSearchViewController *searchController = [segue destinationViewController];
        searchController.fnSearchDelegate = self;
        searchController.navTitle = isChange ? @"选择下车地点" : @"选择上车地点";
        
    }else if ([identifierStr isEqualToString:@"FNSearchMapViewController"]){
    
        FNSearchMapViewController *mapController = [segue destinationViewController];
        mapController.fnMapSearchDelegate = self;
        mapController.navTitle = isChange ? @"选择下车地点" : @"选择上车地点";
        
    }else if ([identifierStr isEqualToString:@"toPaymentViewController"]){
        PayCarViewController *payController = [segue destinationViewController];
        payController.shuttleModel = sender;
    }
}

#pragma mark  notification
- (void)generateOrderSuccessNofitifation:(NSNotification *)notification
{
    [self stopWait];
    if (!isGenerateOrder) {
        isGenerateOrder = YES;
        if ([[notification object][@"success"] intValue] == 0) {
            
            //        noCarView.hidden = NO;
            [self showTipsView:@"对不起，您出行的时间小牛已经全部有约，请您尝试下其他用车时间"];
        }else{
            //        noCarView.hidden = YES;
            PayCarViewController *payController = [PayCarViewController instanceWithStoryboardName:@"Bus"];
            payController.shuttleModel = submitModel;
            [self.navigationController pushViewController:payController animated:YES];
            //[self performSegueWithIdentifier:@"toPaymentViewController" sender:submitModel];
        }
    }
}


#pragma mark KeyBoardNotification
- (void)keyboardWillShow:(NSNotification *)notif {
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    myTableView.contentOffset = CGPointMake(0, myTableView.contentOffset.y+rect.size.height);
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    myTableView.contentOffset = CGPointMake(0, 0);
}

@end
