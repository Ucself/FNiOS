//
//  CharteredViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/7/31.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//
//  包车


#import <FNUIView/THSegmentedPageViewControllerDelegate.h>
#import <FNUIView/DatePickerView.h>
#import <FNUIView/CustomPickerCarView.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "FNCommon/JsonUtils.h"
#import "CharteredViewController.h"
#import "CharteredTravelingViewController.h"
#import "PushNotificationAdapter.h"
#import "LoginViewController.h"
#import <FNNetInterface/PushConfiguration.h>
#import "RuleViewController.h"
#import "CharterCarTableViewCell.h"
#import "PlacePath.h"
#import "VehicleConfig.h"
//#import <FNMap/FNMap.h>
#import "NSDate+FSExtension.h"


#define CharteredType @"1"//means chartered
#define PostRequest_CharteredPrice [NSString stringWithFormat:@"%@CharterOrderPrice", KServerAddr]
#define GetRequest_VehicleType  [NSString stringWithFormat:@"%@VehicleType",KServerAddr]
#define GetRequest_VehicleLevel [NSString stringWithFormat:@"%@VehicleLevel",KServerAddr]
#define PostRequest_SubmitOrder  [NSString stringWithFormat:@"%@CharterOrder",KServerAddr]
#define GetRequest_VehicleSeat [NSString stringWithFormat:@"%@VehicleSeat",KServerAddr]

#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"

enum{
    RequestType_ComputeCharteredPrice = 1,
//    RequestType_SubmitCharteredOrder
};

@interface CharteredViewController ()<UITableViewDataSource,UITableViewDelegate,THSegmentedPageViewControllerDelegate,DatePickerViewDelegate,CustomPickerCarViewDelegate,AMapSearchDelegate>{
    
    BOOL _isDriverFreeNow;
    BOOL _isComputePrice;
    BOOL _switchButton;
    BOOL _receiveAPNS;
    
    NSInteger _charteredSeat;
    NSInteger _charteredAmount;
    NSInteger _charteredLevel;
    int whichRow;
    
    float _charteredStartLatitude;
    float _charteredStartLongitude;
    float _charteredEndLatitude;
    float _charteredEndLongitude;
    
    NSMutableArray *_levelTypeID;
    NSMutableArray *_geoPointArray;
    NSMutableArray *vechileSeartArr;
    NSMutableArray *_charteredSeatArr;
    NSString       *_charteredOrderID;
    
    AMapSearchAPI *_charteredMapSearchAPI;
    
    NSTimer *timer;
    NSInteger   _repeatCount;
    NSArray *_busDataArray;
    
}
//普通包车
@property (strong, nonatomic) IBOutlet UITableView *tableViewNormal;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) NSMutableArray *charteredCarInfo;
@property (strong, nonatomic) NSString *charteredVirtualId;
@property (strong, nonatomic) NSMutableArray *charteredPathArr;
@property (strong, nonatomic) IBOutlet UIButton *computerPriceButon;

@property (strong, nonatomic) NSString *charteredMiles;
@property (strong, nonatomic) NSString *charteredPassageFares;
@property (strong, nonatomic) NSString *miniDate;
@property (strong, nonatomic) NSString *maxDate;
@property (strong, nonatomic) NSDate *charteredStartDate;
@property (strong, nonatomic) NSDate *charteredEndDate;
@property (strong, nonatomic) CharterCarTableViewCell *customCell;

@end

@implementation CharteredViewController

-(CharterOrderPrice *)charterOrder
{
    if (!_charterOrder) {
        _charterOrder = [[CharterOrderPrice alloc]init];
        _charterOrder.paths = @[[NSNull null],[NSNull null]];
        _charterOrder.vehicleConfigs = @[[NSNull null]];
    }
    return _charterOrder;
}

- (NSMutableArray *)charteredPathArr{
    
    if (!_charteredPathArr) {
        
        _charteredPathArr = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
    }
    
    return _charteredPathArr;
}

- (NSMutableArray *)charteredCarInfo{
    
    if (!_charteredCarInfo) {
        
        _charteredCarInfo = [NSMutableArray arrayWithObjects:[NSNull null] ,nil];
    }
    
    return _charteredCarInfo;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"包车";

    [self initNavigationBar];
    
    [self initProperty];
    
    [self requestCharteredTime];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshPrice];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _isComputePrice = YES;
    
}

- (NSMutableArray<NSMutableArray *> *)tableData{
    if (!_tableData) {
        _tableData = [NSMutableArray array];
        NSArray *sectionOne =
        @[
          [self rowDataByType:CharterSubmitCellTypeStartPlace],
          [self rowDataByType:CharterSubmitCellTypeEndPlace],
          ];
        NSArray *sectionTwo =
        @[
          [self rowDataByType:CharterSubmitCellTypeStartTime],
          [self rowDataByType:CharterSubmitCellTypeEndTime],
          [self rowDataByType:CharterSubmitCellTypeBaoChiZhu],
          ];
        NSArray *sectionThree = @[
                                  [self rowDataByType:CharterSubmitCellTypeAddBus],
                                  ];
        _tableData = [@[[sectionOne mutableCopy], [sectionTwo mutableCopy], [sectionThree mutableCopy]] mutableCopy];
    }
    return _tableData;
}
- (NSDictionary *)rowDataByType:(CharterSubmitCellType)type{
    NSString *icon = @"";
    NSString *content = @"";
    NSString *btnRight = @"";
    switch (type) {
        case CharterSubmitCellTypeStartPlace:{
            icon = @"place_green";
            content = @"您要从哪出发";
            btnRight = @"bus_add_icon";
            break;
        }
        case CharterSubmitCellTypeEndPlace:{
            icon = @"place_red";
            content = @"您要去哪里";
            break;
        }
        case CharterSubmitCellTypeCoverPlace:{
            icon = @"place_red";
            content = @"途径哪里";
            btnRight = @"bus_remove_icon";
            break;
        }
        case CharterSubmitCellTypeStartTime:{
            icon = @"bus_startTime_icon";
            content = @"请选择出发时间";
            break;
        }
        case CharterSubmitCellTypeEndTime:{
            icon = @"bus_endTime_icon";
            content = @"请选择结束时间";
            break;
        }
        case CharterSubmitCellTypeBaoChiZhu:{
            icon = @"bus_car_icon";
            content = @"包驾驶员食宿";
            btnRight = @"checkbox";
            break;
        }
        case CharterSubmitCellTypeAddBus:{
            icon = @"bus_car_icon";
            content = @"请选择车辆";
            btnRight = @"bus_add_icon";
            break;
        }
        case CharterSubmitCellTypeRemoveBus:{
            icon = @"bus_car_icon";
            content = @"请选择车辆";
            btnRight = @"bus_remove_icon";
            break;
        }
        default:
            break;
    }
    return @{@"icon":icon, @"content":content, @"btnRight":btnRight, @"type":@(type)};
}
#pragma mark - Timer
- (void)startTimerWithDelay:(NSTimeInterval)delay orderId:(NSString *)orderId{
    if (!orderId || orderId.length <= 0) {
        [self stopWait];
        return;
    }
    if (timer) {
        [self stopTimer];
    }
    _repeatCount = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimer:) userInfo:@{@"orderId":orderId} repeats:YES];
    if (delay <= 0) {
        [timer fire];
    }else{
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    }
}
- (void)handleTimer:(NSTimer *)t{
    if (_repeatCount >= 2) {
        if (_repeatCount == 2) {
            [self showTip:@"订单发布超时" WithType:FNTipTypeFailure];
        }
        [self stopTimer];
        
        return;
    }
    [self requestOrderInfo:t.userInfo[@"orderId"]];
    _repeatCount ++;
    
}
- (void)stopTimer{
    [timer invalidate];
    timer = nil;
    [self stopWait];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)requestOrderInfo:(NSString *)orderId{
    if (!orderId) {
        return;
    }
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderDetail params:^(NetParams *params) {
        params.data = @{@"OrderId":orderId};
    }];
}
#pragma mark -- init user interface

- (void)initTimer{
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(repeatRequest) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantFuture]];
}

- (void)initNavigationBar
{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnRight setFrame:CGRectMake(0, 0, 44, 44)];
    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [btnRight setTitle:@"规则" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(btnCharteredRuleClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
}

- (void)initProperty{
    
    _isComputePrice = YES;
    _switchButton   = NO;
    
//    _charteredEndDate = [NSDate date];
//    _charteredStartDate = [NSDate date];
    
    _charteredVirtualId = [self getGUID];
    
    _charteredOrderID = [NSString string];
    
    vechileSeartArr   = [NSMutableArray array];
    _charteredSeatArr = [NSMutableArray array];
    _geoPointArray    = [NSMutableArray array];
    
    _levelTypeID = [NSMutableArray arrayWithObject:@{@"levelId":@(0),@"typeId":@(0)}];
    
//    _charteredMapSearchAPI = [[AMapSearchAPI alloc] initWithSearchKey:KMapAppKey Delegate:self];
}

#pragma mark -- Function Methods

- (NSDate *)dateTransform:(NSString *)dateString Type:(int)type{
    
    NSDate *tempDate = [NSDate date];
    
    if (type == 1) {
        //起始时间为当前时间的2小时后
        return [tempDate dateByAddingTimeInterval:2*60*60];
    }
    
    
    
    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
    [tempFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *tempDateString = [tempFormatter stringFromDate:tempDate];
    NSLog(@"ddddddd = %@", [NSDate today]);
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:[[[NSDate today] substringToIndex:4] intValue]];
    [components setMonth:[[[[NSDate today] substringFromIndex:5] substringToIndex:2] intValue]];
    [components setDay:[[[[NSDate today] substringFromIndex:8] substringToIndex:2] intValue]];
    [components setHour:[@"18" intValue]];
    [components setMinute:[@"0" intValue]];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *date = [calender dateFromComponents:components];
    
    return [date dateByAddingTimeInterval:24*60*60];
}

- (NSArray *)carSeatArry:(NSArray *)carLevel carSeat:(NSArray *)carSeat
{
    NSMutableArray *seatArr = [NSMutableArray array];
    NSMutableArray *amountArr  = [NSMutableArray array];
    
    for (int i = 0; i < carSeat.count; i++) {
        [seatArr addObject:[NSString stringWithFormat:@"%@座",carSeat[i]]];
    }
    
    for (int j = 1; j < 100; j++) {
        [amountArr addObject:[NSString stringWithFormat:@"%d辆",j]];
    }
    
    NSArray *mArr = @[seatArr,carLevel,amountArr];
    
    return mArr;
}


- (NSString *)getGUID
{
    return [[NSUUID UUID] UUIDString] ;
}

- (void)refreshPrice{
    
    self.totalPriceLabel.text = @"￥0.0元";
    [self.computerPriceButon setTitle:@"计算价格" forState:UIControlStateNormal];
    _isComputePrice = YES;
    _charteredVirtualId = [self getGUID];
}

- (void)repeatRequest{
    
    _receiveAPNS = NO;
    
    [self submitCharteredOrder:self.charteredVirtualId];
}

#pragma mark -- button event

- (IBAction)btnSubmit:(id)sender {

    _switchButton = YES;
    
    if (_isComputePrice == YES) {
        
        [self computeCharteredPrice];
    
    }else{
        [self submitCharteredOrder:self.charteredVirtualId];
   }
}

- (void)addPlace:(id)sender event:(id)event
{
    NSUInteger count = [self.tableViewNormal numberOfRowsInSection:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    
    if (_geoPointArray == nil) {
        
        _geoPointArray = [NSMutableArray arrayWithObjects:[NSNull null], nil];
    }
    
    [_geoPointArray addObject:[NSNull null]];
    
    [self.charteredPathArr insertObject:[NSNull null] atIndex:count-1];
    
    if (indexPath) {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.paths];
        [mArr insertObject:[NSNull null] atIndex:indexPath.row];
        self.charterOrder.paths = mArr;

        [[self tableData][0] insertObject:[self rowDataByType:CharterSubmitCellTypeCoverPlace] atIndex:indexPath.row];
        [self.tableViewNormal insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self refreshPrice];
}

- (void)removePlace:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableViewNormal];
    NSIndexPath *indexPath = [self.tableViewNormal indexPathForRowAtPoint:currentTouchPosition];
    
    [_geoPointArray removeObjectAtIndex:indexPath.row - 1];
    
    [self.charteredPathArr removeObjectAtIndex:indexPath.row];
    
    if (indexPath){
        
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.paths];
        [mArr removeObjectAtIndex:indexPath.row];
        self.charterOrder.paths = mArr;
        [[self tableData][0] removeObjectAtIndex:indexPath.row];
        [self.tableViewNormal deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self getMilesfromeMap:_geoPointArray];
    
    [self refreshPrice];
}

- (void)addCar:(id)sender event:(id)event
{
    NSUInteger count = [self.tableViewNormal numberOfRowsInSection:2];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:2];
    
    if(_charteredCarInfo == nil){
        
        _charteredCarInfo = [NSMutableArray arrayWithObjects:[NSNull null], nil];
    }
    
    [_charteredCarInfo addObject:[NSNull null]];
    
    if (indexPath) {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.vehicleConfigs];
        [mArr addObject:[NSNull null]];
        self.charterOrder.vehicleConfigs = mArr;
        [[self tableData][2] insertObject:[self rowDataByType:CharterSubmitCellTypeRemoveBus] atIndex:indexPath.row];
        [self.tableViewNormal insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self refreshPrice];
}

- (void)removeCar:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableViewNormal];
    
    NSIndexPath *indexPath = [self.tableViewNormal indexPathForRowAtPoint:currentTouchPosition];
    
    [_charteredCarInfo removeObjectAtIndex:indexPath.row];
    
    if (indexPath != nil)
    {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.vehicleConfigs];
        [mArr removeObjectAtIndex:indexPath.row];
        self.charterOrder.vehicleConfigs = mArr;
        [[self tableData][2] removeObjectAtIndex:indexPath.row];
        [self.tableViewNormal deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self refreshPrice];
}

- (void)provideFoodButton:(id)sender{
    
    UIButton *button = (UIButton *)sender;

    button.selected = !button.selected;
    
    (button.selected == YES) ?
    [button setImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateNormal] :
    [button setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    
    _isDriverFreeNow = (button.selected == YES) ? YES : NO;

    _customCell.contentLabel.textColor = (button.selected) ? [UIColor blackColor] : UIColorFromRGB(0xb4b4b4);
    
    [self refreshPrice];
    
}

//get start and end of distance
- (void)getMilesfromeMap:(NSArray *)cityArray{
    
    for (AMapGeoPoint *point in cityArray) {
        
        if ([point isKindOfClass:[NSNull class]]) {
            
            return;
        }
    }
    
    if ((_charteredStartLatitude != 0) &&
        (_charteredStartLongitude != 0) &&
        (_charteredEndLatitude != 0) &&
        (_charteredEndLongitude != 0)) {
        
//        AMapNavigationSearchRequest *request = [[AMapNavigationSearchRequest alloc] init];
//        
//        request.origin = [AMapGeoPoint locationWithLatitude:_charteredStartLatitude longitude:_charteredStartLongitude];
//        request.destination = [AMapGeoPoint locationWithLatitude:_charteredEndLatitude longitude:_charteredEndLongitude];
//        request.searchType       = AMapSearchType_NaviDrive;
//        request.strategy         = 5;//距离优先
//        request.requireExtension = YES;
//        request.waypoints        = cityArray;
//
//        //发起路径搜索
//        [_charteredMapSearchAPI AMapNavigationSearch:request];
    }
}

- (void)requestCharteredTime{
    [NetManagerInstance sendRequstWithType:RequestType_CharterOrderTime params:nil];
}

//Submit order
- (void)submitCharteredOrder:(NSString *)virtualId{

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NetManagerInstance sendRequstWithType:RequestType_SubmitCharteredOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"virtualId":virtualId};
    }];
}

- (void)showPromptView{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请完善信息"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)btnCharteredRuleClick{
    
    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    ruleVC.vcTitle = @"规则";
    ruleVC.urlString = [NSString stringWithFormat:@"%@rule2.html",KAboutServerAddr];
    [self.navigationController pushViewController:ruleVC animated:YES];
}
#pragma mark - Request Methods
- (void)requestBusListData{
    VehicleConfig *config = [self.charterOrder.vehicleConfigs objectAtIndex:self.rowPath.row];
    
    NSUInteger seatIndex = 0;
    NSUInteger levelIndex = 0;
    NSUInteger amountIndex = 0;
    
    if (![config isKindOfClass:[NSNull class]]) {
        seatIndex = 0;
        levelIndex = 0;
        amountIndex = 0;
    }
    void (^showBusPickerViewBlock)() = ^{
        CustomPickerCarView *pickerCarView = [[CustomPickerCarView alloc]
                                              initWithFrame:self.view.frame
                                              dataSourceArray:_busDataArray
                                              seatIndex:_charteredSeat
                                              levelIndex:_charteredLevel
                                              amountIndex:_charteredAmount];
        
        pickerCarView.isShowTitle = YES;
        pickerCarView.delegate = self;
        [pickerCarView showInView:self.view];
    };
    
    NSMutableArray *carAllInfo = [NSMutableArray arrayWithObject:@"不限"];
    if (!_busDataArray || _busDataArray.count <= 0) {
        [[NetInterface sharedInstance] httpGetRequest:GetRequest_VehicleType body:nil suceeseBlock:^(NSString *msg) {
            
            NSArray *carLevelArr = [JsonUtils jsonToDcit:msg][@"list"];
            
            [[NetInterface sharedInstance] httpGetRequest:GetRequest_VehicleSeat body:nil suceeseBlock:^(NSString *msg) {
                
                DBG_MSG(@"msg = %@", msg);
                
                vechileSeartArr = [JsonUtils jsonToDcit:msg][@"list"];
                
                [[NetInterface sharedInstance] httpGetRequest:GetRequest_VehicleLevel body:nil suceeseBlock:^(NSString *msg) {
                    
                    NSArray *carTypeArr = [JsonUtils jsonToDcit:msg][@"list"];
                    
                    for (NSDictionary *carLevel in carLevelArr) {
                        
                        for (NSDictionary *carType in carTypeArr) {
                            
                            [carAllInfo addObject:[NSString stringWithFormat:@"%@%@", carLevel[@"name"],carType[@"name"]]];
                        }
                    }
                    
                    for (NSDictionary *carLevel in carLevelArr) {
                        
                        for (NSDictionary *carType in carTypeArr) {
                            
                            [_levelTypeID addObject:@{@"levelId":carLevel[@"id"],@"typeId":carType[@"id"]}];
                        }
                    }
                    _busDataArray = [self carSeatArry:carAllInfo carSeat:vechileSeartArr];
                    showBusPickerViewBlock();
                    
                } failedBlock:^(NSError *msg) {
                    
                }];
                
            } failedBlock:^(NSError *msg) {
                
                DBG_MSG(@"msg = %@", msg);
                
                [self showTip:@"请求超时" WithType:FNTipTypeFailure];
            }];
            
        } failedBlock:^(NSError *msg) {
            
        }];
    }else{
        showBusPickerViewBlock();
    }
}
#pragma mark- uitableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 2 ? 0 : 10;
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 1 ? 0 : 1;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tableData][section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self tableData].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CharterCarTableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CharterCarTableViewCell class]) forIndexPath:indexPath];
    NSDictionary *dic = [self tableData][indexPath.section][indexPath.row];
    cell.placeImageView.image = [UIImage imageNamed:dic[@"icon"]];
    cell.contentLabel.text = dic[@"content"];
    cell.contentLabel.textColor = UIColorFromRGB(0xb4b4b4);
    NSString *btnRightIcon = dic[@"btnRight"];
    if (btnRightIcon && btnRightIcon.length > 0) {
        cell.addButton.hidden = NO;
        [cell.addButton setImage:[UIImage imageNamed:dic[@"btnRight"]] forState:UIControlStateNormal];
    }else{
        cell.addButton.hidden = YES;
    }
    
    CharterSubmitCellType type = [dic[@"type"] integerValue];
    if (type == CharterSubmitCellTypeStartPlace ||
        type == CharterSubmitCellTypeEndPlace ||
        type == CharterSubmitCellTypeCoverPlace) {
        PlacePath *place = self.charterOrder.paths[indexPath.row];
        if (place && [place isKindOfClass:[PlacePath class]]) {
            cell.contentLabel.textColor = UIColorFromRGB(0x333333);
            cell.contentLabel.text = place.name;
        }
        if (type == CharterSubmitCellTypeStartPlace) {
            [cell.addButton addTarget:self action:@selector(addPlace:event:) forControlEvents:UIControlEventTouchUpInside];
        }else if (type == CharterSubmitCellTypeCoverPlace){
            [cell.addButton addTarget:self action:@selector(removePlace:event:) forControlEvents:UIControlEventTouchUpInside];
        }
    }else if (type == CharterSubmitCellTypeStartTime) {
        if (self.charterOrder.startTime) {
            cell.contentLabel.text = self.charterOrder.startTime;
            cell.contentLabel.textColor = UIColorFromRGB(0x333333);
        }
    }else if (type == CharterSubmitCellTypeEndTime){
        if (self.charterOrder.endTime) {
            cell.contentLabel.text = self.charterOrder.endTime;
            cell.contentLabel.textColor = UIColorFromRGB(0x333333);
        }
    }else if (type == CharterSubmitCellTypeAddBus ||
              type == CharterSubmitCellTypeRemoveBus){
        VehicleConfig *config = self.charterOrder.vehicleConfigs[indexPath.row];
        if (config && [config isKindOfClass:[VehicleConfig class]]) {
            cell.contentLabel.text = [NSString stringWithFormat:@"%@",config.vehileTypeLevel];
            cell.contentLabel.textColor = UIColorFromRGB(0x333333);
        }
        if (type == CharterSubmitCellTypeAddBus) {
            [cell.addButton addTarget:self action:@selector(addCar:event:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [cell.addButton addTarget:self action:@selector(removeCar:event:) forControlEvents:UIControlEventTouchUpInside];
        }
    }else if (type == CharterSubmitCellTypeBaoChiZhu){
        _customCell = cell;
        _isDriverFreeNow = YES;
        _customCell.contentLabel.textColor = [UIColor blackColor];
        [_customCell.addButton setImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateNormal];
        [_customCell.addButton setSelected:YES];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.rowPath = indexPath;
    NSDictionary *dic = [self tableData][indexPath.section][indexPath.row];
    CharterSubmitCellType type = [dic[@"type"] integerValue];
    switch (type) {
        case CharterSubmitCellTypeStartPlace:
        case CharterSubmitCellTypeEndPlace:
        case CharterSubmitCellTypeCoverPlace:{
//            FNSearchViewController *vc = [[FNSearchViewController alloc]init];
//            
//            vc.fnSearchDelegate = self;
//            
//            vc.isShowTopTableView = YES;
//            
//            [self.navigationController pushViewController:vc animated:YES];
//            break;
        }
        case CharterSubmitCellTypeStartTime:
        case CharterSubmitCellTypeEndTime:{
            
            DatePickerView *datePicker = [[DatePickerView alloc] initWithFrame:self.view.frame];
            
            datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            
            if (indexPath.row == 0) {
                
                datePicker.minDate = [self dateTransform:_miniDate Type:1];
                
            }else if (indexPath.row == 1){
                
                datePicker.minDate = [self dateTransform:_miniDate Type:2];
            }
            
            
            datePicker.maxDate = [NSDate fs_dateFromString:_maxDate format:@"yyyy-MM-dd HH:mm:ss"];
            datePicker.delegate = self;
            
            whichRow = type - CharterSubmitCellTypeStartTime;
            if (whichRow == 0) {
                datePicker.currentDate = _charteredStartDate;
            }else{
                datePicker.currentDate = _charteredEndDate;
            }
            datePicker.isShowTitle = YES;
            
//            datePicker.datePicker.minimumDate = [self dateTransform];
            
//            datePicker.datePicker.minimumDate = [NSDate fs_dateFromString:_miniDate format:@"yyyy-MM-dd HH:mm:ss"];
//            datePicker.datePicker.maximumDate = [NSDate fs_dateFromString:_maxDate format:@"yyyy-MM-dd HH:mm:ss"];
            [datePicker showInView:self.view];
            break;
        }
        case CharterSubmitCellTypeBaoChiZhu:{
            CharterCarTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self provideFoodButton:cell.addButton];
            break;
        }
        default:{
            [self requestBusListData];
            break;
        }
    }
    return;
}

#pragma mark - FNSearchViewControllerDelegate
//- (void)searchViewController:(FNSearchViewController *)searchViewController didSelectLocation:(FNLocation *)location
//{
//    if (self.rowPath.section == 0) {
//        
//        PlacePath *path = [self.charterOrder.paths objectAtIndex:self.rowPath.row];
//        
//        if ([path isKindOfClass:[NSNull class]]) {
//            
//            path = [[PlacePath alloc]init];
//        }
//        
//        path.name     = location.name;
//        path.adCode   = location.adCode;
//        path.sequence = 1;
//        path.location = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
//        
//        int rowCount = (int)[self.tableViewNormal numberOfRowsInSection:0];
//        
//        if (self.rowPath.row == 0) {
//            
//            path.pathType = 1;//起点
//            _charteredStartLatitude  = location.coordinate.latitude;
//            _charteredStartLongitude = location.coordinate.longitude;
//            
//        }else if (self.rowPath.row == rowCount - 1) {
//            
//            path.pathType = 2;//终点
//            
//            _charteredEndLatitude = location.coordinate.latitude;
//            _charteredEndLongitude = location.coordinate.longitude;
//     
//        }else{
//            
//            path.pathType = 3;//途经
//            
//            AMapGeoPoint *geoPoint = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
//            
//            [_geoPointArray replaceObjectAtIndex:self.rowPath.row - 1 withObject:geoPoint];
//        }
//        
//        [self getMilesfromeMap:_geoPointArray];//计算里程数
//        
//        NSDictionary *pathDic = @{@"pathType":@(path.pathType),
//                                  @"name":path.name,
//                                  @"adCode":path.adCode,
//                                  @"sequence":@(path.sequence),
//                                  @"location":path.location};
//        
//        
//        [self.charteredPathArr replaceObjectAtIndex:self.rowPath.row withObject:pathDic];
//        
//        NSMutableArray *mArr = [self.charterOrder.paths mutableCopy];
//        
//        [mArr replaceObjectAtIndex:self.rowPath.row withObject:path];
//        
//        self.charterOrder.paths = mArr;
//        
//        [self.tableViewNormal reloadRowsAtIndexPaths:@[self.rowPath] withRowAnimation:UITableViewRowAnimationNone];
//
//        self.rowPath = nil;
//        
//        [self refreshPrice];
//    }
//    
//    
//}

#pragma mark - DatePickerDelegate

-(void)pickerViewOK:(NSString *)date
{

    if (whichRow == 0) {
        
        _charteredStartDate = [NSDate date];
        _charteredStartDate = [NSDate fs_dateFromString:date format:@"yyyy-MM-dd HH:mm"];
        

//        if ([_charteredStartDate compare:_charteredEndDate] ==  NSOrderedDescending || [_charteredStartDate compare:_charteredEndDate] == NSOrderedSame) {
//            
//            NSDate *tempDate = _charteredStartDate;
//
//            _charteredEndDate = [tempDate dateByAddingTimeInterval:34*60*60];
//        }
        
    }else{
        
        _charteredEndDate = [NSDate date];
        _charteredEndDate = [NSDate fs_dateFromString:date format:@"yyyy-MM-dd HH:mm"];
    }
    
    if (self.rowPath.section == 1) {
        
        if (self.rowPath.row == 0) {
            
            self.charterOrder.startTime = date;
            
        }else if (self.rowPath.row == 1){
            
            self.charterOrder.endTime = date;
            
        }
    }
    
    if (self.rowPath) {
        [self.tableViewNormal reloadRowsAtIndexPaths:@[self.rowPath] withRowAnimation:UITableViewRowAnimationNone];
        self.rowPath = nil;
    }
    
    [self refreshPrice];
}

#pragma mark - CustomPickerCarViewDelegate

- (void)pickerCarViewOKSeatIndex:(NSUInteger)seatIndex levelIndex:(NSUInteger)levelIndex amountIndex:(NSUInteger)amountIndex title:(NSString *)title pickerCarView:(CustomPickerCarView *)pickerCarView{
    
    _charteredSeat   = seatIndex;
    _charteredLevel  = levelIndex;
    _charteredAmount = amountIndex;
    
    if (self.rowPath.section == 2) {
        
        VehicleConfig *config = [self.charterOrder.vehicleConfigs objectAtIndex:self.rowPath.row];
        
        if ([config isKindOfClass:[NSNull class]]) {
            
            config = [[VehicleConfig alloc]init];
        }
        
        config.vehileTypeLevel = title;
        
        int levelId = [_levelTypeID[pickerCarView.carTypeAndLevelId][@"levelId"] intValue];
        int typeId = [_levelTypeID[pickerCarView.carTypeAndLevelId][@"typeId"] intValue];
        
        NSDictionary *vehicleInfoDic = @{@"Seat":vechileSeartArr[seatIndex],@"VehicleLevelId":@(levelId),@"VehicleTypeId":@(typeId),@"Amount":@(amountIndex+1)};
        
        [self.charteredCarInfo replaceObjectAtIndex:self.rowPath.row withObject:vehicleInfoDic];
        
        NSMutableArray *mArr = [self.charterOrder.vehicleConfigs mutableCopy];
        
        [mArr replaceObjectAtIndex:self.rowPath.row withObject:config];
        
        self.charterOrder.vehicleConfigs = mArr;
    }
    
    if (self.rowPath) {
        
        [self.tableViewNormal reloadRowsAtIndexPaths:@[self.rowPath] withRowAnimation:UITableViewRowAnimationNone];
        self.rowPath = nil;
    }
    
    [self refreshPrice];
}

- (NSString *)viewControllerTitle
{
    return @"包车";
}


#pragma mark -- Compute Chartered Price
- (NSInteger)orderType{
    return 1;
}
- (void)computeCharteredPrice{

    if ((_charterOrder.startTime.length == 0) ||
        (_charterOrder.endTime.length == 0) ||
        (_charteredMiles.length == 0) ||
        (_charteredPassageFares.length == 0) ||
        (_charteredCarInfo.count == 0) ||
        (self.charteredPathArr.count == 0)) {
        
        [self showPromptView];
        
    }else{
        
        [self startWait];
        [NetManagerInstance sendRequstWithType:RequestType_ComputeCharteredPrice params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            params.data = @{@"type":@([self orderType]),
                            @"startTime":[_charterOrder.startTime stringByAppendingString:@":00"],
                            @"endTime":[_charterOrder.endTime stringByAppendingString:@":00"],
                            @"mapSourceType":@"1",
                            @"miles":_charteredMiles,
                            @"passageFares":_charteredPassageFares,
                            @"virtualId":_charteredVirtualId,
                            @"isDriverFree":@(_isDriverFreeNow),
                            @"vehicleConfigs":_charteredCarInfo,
                            @"paths":self.charteredPathArr};
        }];
    }
}

#pragma mark -- AMapSearchDelegate

//- (void)searchRequest:(id)request didFailWithError:(NSError *)error{
//    
//    NSLog(@"request = %@", error);
//}
//
//- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
//
//    NSLog(@"respone = %@", response.route);
//
////    //driveCar miles
//    _charteredMiles = [NSString stringWithFormat:@"%.2f", (double)((AMapPath *)(response.route.paths[0])).distance/1000];
//    
//    //driveCar cost
//    _charteredPassageFares = [NSString stringWithFormat:@"%.2f", ((AMapPath *)(response.route.paths[0])).tolls * 100];
//}

#pragma mark -- http respone

- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    NSInteger type = resultData.requestType;
    NSDictionary *data = resultData.data;
    
    if (type == FNUserRequestType_CharterOrderDetail){
        if (resultData.resultCode == 0) {
            //"1"生成订单
            NSString *orderId = data[@"charterOrder"][@"id"];
            if (orderId && orderId.length > 0) {
                _charteredOrderID =  orderId;
                
                CharteredTravelingViewController *vc = [[UIStoryboard storyboardWithName:@"Travel" bundle:nil] instantiateViewControllerWithIdentifier:@"CharteredTravelingViewController"];
                
                vc.orderId = _charteredOrderID;
                NSLog(@"ORDERID = %@", vc.orderId);
                [self.navigationController pushViewController:vc animated:YES];
            }
            [self stopTimer];
        }
    }
    
    if (_switchButton == NO) {
        return;
    }
    
    if (_switchButton == YES) {
        _switchButton = NO;
        
        
        if (type == RequestType_ComputeCharteredPrice) {
            NSLog(@"开始计算包车价格");
            
            if (resultData.resultCode == 0) {
                
                self.charteredVirtualId = resultData.data[@"virtualId"];
                
                self.totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f元",[((NSString *)resultData.data[@"price"]) doubleValue]/100];
                
                [self.computerPriceButon setTitle:@"发布订单" forState:UIControlStateNormal];
                
                _isComputePrice = NO;
                
            }else{
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:resultData.message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }else if(type == RequestType_SubmitCharteredOrder){
            if (resultData.resultCode == 0) {
                
                _receiveAPNS = YES;
                
                [self startTimerWithDelay:10 orderId:resultData.data[@"orderId"]];

                
            }else{
                [self showTip:resultData.message WithType:FNTipTypeFailure];
            }
        }else if(type == RequestType_CharterOrderTime){
            
            _miniDate = data[@"charterTime"][@"startTime"];
            _maxDate  = data[@"charterTime"][@"endTiem"];
        }
    }

}

- (void)httpRequestFailed:(NSNotification *)notification{
    
    [super httpRequestFailed:notification];
    
}

#pragma mark -- receive APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
    NSLog(@"包车收到APNS");
    
    [timer invalidate];

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if (_receiveAPNS == YES) {
        
        _receiveAPNS = NO;
        
        //"0"提交订单成功
        if ([userInfo[@"code"] intValue] == 0) {
            
            //"1"生成订单
            if ([userInfo[@"processType"] intValue] == 1) {
                
                //APNS
                _charteredOrderID =  userInfo[@"orderId"];
                
                CharteredTravelingViewController *vc = [[UIStoryboard storyboardWithName:@"Travel" bundle:nil] instantiateViewControllerWithIdentifier:@"CharteredTravelingViewController"];
                
                vc.orderId = _charteredOrderID;
                NSLog(@"ORDERID = %@", vc.orderId);
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}
@end
