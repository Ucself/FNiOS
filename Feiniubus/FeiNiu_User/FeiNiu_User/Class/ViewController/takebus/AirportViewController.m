//
//  AirportViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/18.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "AirportViewController.h"
#import "RuleViewController.h"

//#import<FNMap/FNSearchViewController.h>
//#import<FNMap/FNMapSearch.h>
//#import "CharterCarTableViewCell.h"
//#import "VehicleConfig.h"
//#import "PlacePath.h"
//#import "FNCommon/JsonUtils.h"
//#import "NSDate+FSExtension.h"
//#import <FNUIView/THSegmentedPageViewControllerDelegate.h>
//#import <AMapSearchKit/AMapSearchAPI.h>
//#import <FNMap/FNLocation.h>
//#import <FNUIView/DatePickerView.h>
//#import <FNUIView/CustomPickerCarView.h>
//#import "CharteredTravelingViewController.h"
//#import "RuleViewController.h"

//#define AirpotType @"2"
//#define PostRequest_CharteredPrice [NSString stringWithFormat:@"%@CharterOrderPrice", KServerAddr]
//#define GetRequest_VehicleType  [NSString stringWithFormat:@"%@VehicleType",KServerAddr]
//#define GetRequest_VehicleLevel [NSString stringWithFormat:@"%@VehicleLevel",KServerAddr]
//#define GetRequest_CharterOrderTime [NSString stringWithFormat:@"%@CharterOrderTime",KServerAddr]
//#define PostRequest_SubmitOrder [NSString stringWithFormat:@"%@CharterOrder",KServerAddr]
//#define GetRequest_VehicleSeat [NSString stringWithFormat:@"%@VehicleSeat",KServerAddr]

//#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"

//enum{
//    RequestType_ComputeCharteredPrice = 1,
//    RequestType_SubmitCharteredOrder
//};

//@interface AirportViewController ()<UITableViewDataSource,UITableViewDelegate,THSegmentedPageViewControllerDelegate,FNSearchViewControllerDelegate,CustomPickerCarViewDelegate,DatePickerViewDelegate,AMapSearchDelegate>{
//    
//    BOOL _isDriverFree;
//    BOOL _isComputePrice;
//    BOOL _airportSwitch;
//    BOOL _receiveAPNS;
//    
//    NSInteger _charteredSeat;
//    NSInteger _charteredAmount;
//    NSInteger _charteredLevel;
//    int whichRow;
//    
//    float _charteredStartLatitude;
//    float _charteredStartLongitude;
//    float _charteredEndLatitude;
//    float _charteredEndLongitude;
//    
//    NSMutableArray *_levelTypeID;
//    NSMutableArray *_airportGeoPointArray;
//    NSMutableArray *vechileSeartArr;
//    NSString       *_charteredOrderID;
//    
//    AMapSearchAPI *_charteredMapSearchAPI;
//    
//    NSTimer *time;
//}
//
////普通包车
//@property (weak, nonatomic) IBOutlet UITableView *tableViewNormal;
//@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
//@property (strong, nonatomic) NSIndexPath *rowPath;
//@property (strong, nonatomic) NSMutableArray *charteredCarInfo;
//@property (strong, nonatomic) NSString *charteredVirtualId;
//@property (strong, nonatomic) NSMutableArray *charteredPathArr;
//
//@property (strong, nonatomic) IBOutlet UIButton *computAirportPrice;
//
//@property (strong, nonatomic) NSString *charteredMiles;
//@property (strong, nonatomic) NSString *charteredPassageFares;
//@property (strong, nonatomic) NSString *miniDate;
//@property (strong, nonatomic) NSString *maxDate;
//@property (strong, nonatomic) NSDate *charteredStartDate;
//@property (strong, nonatomic) NSDate *charteredEndDate;
//
//@end

@implementation AirportViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"中转车/接送机";
}
- (NSInteger)orderType{
    return 2;
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
          ];
        NSArray *sectionThree = @[
                                  [self rowDataByType:CharterSubmitCellTypeAddBus],
                                  ];
        _tableData = [@[[sectionOne mutableCopy], [sectionTwo mutableCopy], [sectionThree mutableCopy]] mutableCopy];
    }
    return _tableData;
}



- (void)btnCharteredRuleClick{
    
    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    ruleVC.vcTitle = @"规则";
    ruleVC.urlString = [NSString stringWithFormat:@"%@rule3.html",KAboutServerAddr];
    [self.navigationController pushViewController:ruleVC animated:YES];
}


//-(CharterOrderPrice *)charterOrder
//{
//    if (!_charterOrder) {
//        _charterOrder = [[CharterOrderPrice alloc]init];
//        _charterOrder.paths = @[[NSNull null],[NSNull null]];
//        _charterOrder.vehicleConfigs = @[[NSNull null]];
//    }
//    return _charterOrder;
//}
//
//- (NSMutableArray *)charteredPathArr{
//    
//    if (!_charteredPathArr) {
//        
//        _charteredPathArr = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
//    }
//    
//    return _charteredPathArr;
//}
//
//- (NSMutableArray *)charteredCarInfo{
//    
//    if (!_charteredCarInfo) {
//        
//        _charteredCarInfo = [NSMutableArray arrayWithObjects:[NSNull null] ,nil];
//    }
//    
//    return _charteredCarInfo;
//}
//
//- (NSArray *)carSeatArry:(NSArray *)carLevel carSeat:(NSArray *)carSeat
//{
//    NSMutableArray *seatArr = [NSMutableArray array];
//    NSMutableArray *amountArr  = [NSMutableArray array];
//    
//    for (int i = 0; i < carSeat.count; i++) {
//        [seatArr addObject:[NSString stringWithFormat:@"%@座",carSeat[i]]];
//    }
//    
//    for (int j = 1; j < 100; j++) {
//        [amountArr addObject:[NSString stringWithFormat:@"%d辆",j]];
//    }
//    
//    NSArray *mArr = @[seatArr,carLevel,amountArr];
//    
//    return mArr;
//}
//
//- (NSString *)viewControllerTitle{
//    return @"中转车/接送机";
//}
//
//- (void)dealloc{
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [time invalidate];
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    [self initNavigationBar];
//    
//    [self initProperty];
//    
//    [self requestCharteredTime];
//    
//    [self initTimer];
//}
//
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self refreshPrice];
//}
//
//
//- (void)viewWillDisappear:(BOOL)animated{
//    
//    _isComputePrice = YES;
//    
//}
//
//#pragma mark -- init user interface
//
//- (void)initTimer{
//    
//    time = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(repeatRequest) userInfo:nil repeats:YES];
//    [time setFireDate:[NSDate distantFuture]];
//}
//
//- (void)initNavigationBar
//{
//    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    [btnRight setFrame:CGRectMake(0, 0, 44, 44)];
//    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
//    [btnRight setTitle:@"规则" forState:UIControlStateNormal];
//    [btnRight addTarget:self action:@selector(btnAirportRuleClick) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
//    
//    self.navigationItem.title = @"中转车/接送机";
//}
//
//- (void)initProperty{
//    
//    _isComputePrice = YES;
//    _airportSwitch  = NO;
//    
//    _charteredEndDate = [NSDate date];
//    _charteredStartDate = [NSDate date];
//    
//    _charteredVirtualId = [self getGUID];
//    
//    _charteredOrderID = [NSString string];
//    
//    vechileSeartArr   = [NSMutableArray array];
//    
//    _levelTypeID = [NSMutableArray arrayWithObjects:@{@"levelId":@"0",@"typeId":@"0"}, nil];
//    
//    _charteredMapSearchAPI = [[AMapSearchAPI alloc] initWithSearchKey:KMapAppKey Delegate:self];
//    
//}
//
//#pragma mark -- function methods
//
//- (NSString *)getGUID
//{
//    return [[NSUUID UUID] UUIDString] ;
//}
//
//- (void)refreshPrice{
//    
//    [self.totalPriceLabel setText:@"￥0.0元"];
//    [self.computAirportPrice setTitle:@"计算价格" forState:UIControlStateNormal];
//    
//    _isComputePrice = YES;
//    
//    _charteredVirtualId = [self getGUID];
//}
//
//- (void)repeatRequest{
//    
//    _receiveAPNS = NO;
//    NSDictionary *virtualParams = @{@"virtualId":self.charteredVirtualId};
//    
//    [self submitCharteredOrder:virtualParams];
//}
//
//#pragma mark- Button
//
//- (IBAction)btnSubmit:(id)sender {
//    
//    _airportSwitch = YES;
//    
//    if (_isComputePrice == YES) {
//        
//        [self computeAirportPrice];
//        
//    }else{
//        
//        NSDictionary *virtualParams = @{@"virtualId":self.charteredVirtualId};
//        
//        [self submitCharteredOrder:virtualParams];
//    }
//}
//
//- (void)addPlace:(id)sender event:(id)event
//{
//    NSUInteger count = [self.tableViewNormal numberOfRowsInSection:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
//    
//    if (_airportGeoPointArray == nil) {
//        
//        _airportGeoPointArray = [NSMutableArray arrayWithObjects:[NSNull null], nil];
//    }
//    
//    [_airportGeoPointArray addObject:[NSNull null]];
//    
//    [self.charteredPathArr insertObject:[NSNull null] atIndex:count-1];
//    
//    if (indexPath) {
//        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.paths];
//        [mArr insertObject:[NSNull null] atIndex:indexPath.row];
//        self.charterOrder.paths = mArr;
//        [self.tableViewNormal insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    
//    [self refreshPrice];
//}
//
//- (void)removePlace:(id)sender event:(id)event
//{
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.tableViewNormal];
//    NSIndexPath *indexPath = [self.tableViewNormal indexPathForRowAtPoint:currentTouchPosition];
//    
//    [_airportGeoPointArray removeObjectAtIndex:indexPath.row-1];
//    
//    [self.charteredPathArr removeObjectAtIndex:indexPath.row];
//    
//    if (indexPath)
//    {
//        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.paths];
//        [mArr removeObjectAtIndex:indexPath.row];
//        self.charterOrder.paths = mArr;
//        [self.tableViewNormal deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    
//    [self refreshPrice];
//    [self getMilesfromeMap:_airportGeoPointArray];
//}
//
//- (void)addCar:(id)sender event:(id)event
//{
//    NSUInteger count = [self.tableViewNormal numberOfRowsInSection:1];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:1];
//    
//    if(_charteredCarInfo == nil){
//        
//        _charteredCarInfo = [NSMutableArray arrayWithObjects:[NSNull null], nil];
//    }
//    
//    [_charteredCarInfo addObject:[NSNull null]];
//    
//    if (indexPath) {
//        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.vehicleConfigs];
//        [mArr addObject:[NSNull null]];
//        self.charterOrder.vehicleConfigs = mArr;
//        [self.tableViewNormal insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    
//    [self refreshPrice];
//}
//
//- (void)removeCar:(id)sender event:(id)event
//{
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.tableViewNormal];
//    NSIndexPath *indexPath = [self.tableViewNormal indexPathForRowAtPoint:currentTouchPosition];
//    
//    [_charteredCarInfo removeObjectAtIndex:indexPath.row - 2];
//    
//    if (indexPath != nil)
//    {
//        NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.charterOrder.vehicleConfigs];
//        [mArr removeObjectAtIndex:indexPath.row - 2];
//        self.charterOrder.vehicleConfigs = mArr;
//        [self.tableViewNormal deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    
//    [self refreshPrice];
//}
//
////get start and end of distance
//- (void)getMilesfromeMap:(NSArray *)cityArray{
//    
//    for (AMapGeoPoint *point in cityArray) {
//        
//        if ([point isKindOfClass:[NSNull class]]) {
//            
//            return;
//        }
//    }
//    
//    if ((_charteredStartLatitude != 0) && (_charteredStartLongitude != 0) &&
//        (_charteredEndLatitude != 0) &&
//        (_charteredEndLongitude != 0)) {
//        
//        AMapNavigationSearchRequest *request = [[AMapNavigationSearchRequest alloc] init];
//        request.origin = [AMapGeoPoint locationWithLatitude:_charteredStartLatitude longitude:_charteredStartLongitude];
//        request.destination = [AMapGeoPoint locationWithLatitude:_charteredEndLatitude longitude:_charteredEndLongitude];
//        request.searchType = AMapSearchType_NaviDrive;
//        request.strategy = 2;//距离优先
//        request.requireExtension = YES;
//        request.waypoints = cityArray;
//        
//        //发起路径搜索
//        [_charteredMapSearchAPI AMapNavigationSearch:request];
//    }
//}
//
//- (void)requestCharteredTime{
//    
//    [[NetInterface sharedInstance] httpGetRequest:GetRequest_CharterOrderTime body:nil suceeseBlock:^(NSString *msg) {
//        
//        NSDictionary *dicMsg = [JsonUtils jsonToDcit:msg];
//        
//        _miniDate = dicMsg[@"charterTime"][@"startTime"];
//        _maxDate  = dicMsg[@"charterTime"][@"endTiem"];
//        
//    } failedBlock:^(NSError *msg) {
//        
//    }];
//}
//
////Submit order
//- (void)submitCharteredOrder:(NSDictionary *)dicParams{
//    [self startWait];
//   [[NetInterfaceManager sharedInstance] postRequst:PostRequest_SubmitOrder body:[JsonUtils dictToJson:dicParams] requestType:RequestType_SubmitCharteredOrder];
//}
//
//- (void)showPromptView{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"请完善信息"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil, nil];
//    [alertView show];
//}
//
//- (void)btnAirportRuleClick{
//    
//    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
//    ruleVC.vcTitle = @"规则";
//    [self.navigationController pushViewController:ruleVC animated:YES];
//}
//
//#pragma mark- uitableview delegate
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 44;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 0) {
//        return self.charterOrder.paths.count;
//    }else{
//        return self.charterOrder.vehicleConfigs.count + 2;
//    }
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CharterCarTableViewCell *cell = nil;
//    
//    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CharterCarTableViewCell class]) forIndexPath:indexPath];
//    
//    if (indexPath.section == 0) {
//        
//        PlacePath *place = self.charterOrder.paths[indexPath.row];
//        
//        if (indexPath.row == 0) {
//            
//            cell.placeImageView.image = [UIImage imageNamed:@"place_green"];
//            
//            cell.addButton.hidden = NO;
//            [cell.addButton setImage:[UIImage imageNamed:@"bus_add_icon"] forState:UIControlStateNormal];
//            [cell.addButton addTarget:self action:@selector(addPlace:event:) forControlEvents:UIControlEventTouchUpInside];
//            
//            if ([place isKindOfClass:[NSNull class]]) {
//                
//                cell.contentLabel.textColor = UIColorFromRGB(0xb4b4b4);
//                cell.contentLabel.text = @"从这里出发";
//                
//            }else{
//                
//                cell.contentLabel.textColor = UIColorFromRGB(0x333333);
//                cell.contentLabel.text = place.name;
//                
//            }
//            
//        }else if(indexPath.row == (self.charterOrder.paths.count - 1)){
//            
//            cell.placeImageView.image = [UIImage imageNamed:@"place_red"];
//            cell.addButton.hidden = YES;
//            
//            if ([place isKindOfClass:[NSNull class]]) {
//                
//                cell.contentLabel.textColor = UIColorFromRGB(0xb4b4b4);
//                cell.contentLabel.text = @"您要去哪里";
//                
//            }else{
//                
//                cell.contentLabel.textColor = UIColorFromRGB(0x333333);
//                cell.contentLabel.text = place.name;
//            }
//            
//        }else{
//            
//            cell.placeImageView.image = [UIImage imageNamed:@"place_red"];
//            cell.addButton.hidden = NO;
//            [cell.addButton setImage:[UIImage imageNamed:@"bus_remove_icon"] forState:UIControlStateNormal];
//            [cell.addButton addTarget:self action:@selector(removePlace:event:) forControlEvents:UIControlEventTouchUpInside];
//            
//            if ([place isKindOfClass:[NSNull class]]) {
//                
//                cell.contentLabel.textColor = UIColorFromRGB(0xb4b4b4);
//                cell.contentLabel.text = @"途径哪里";
//                
//            }else{
//                
//                cell.contentLabel.textColor = UIColorFromRGB(0x333333);
//                cell.contentLabel.text = place.name;
//            }
//        }
//        
//    }else{
//        
//        if (indexPath.row == 0) {
//            
//            cell.placeImageView.image = [UIImage imageNamed:@"bus_startTime_icon"];
//            cell.addButton.hidden = YES;
//            cell.contentLabel.text = self.charterOrder.startTime ? self.charterOrder.startTime : @"请选择出发时间";
//            cell.contentLabel.textColor = self.charterOrder.startTime ? UIColorFromRGB(0x333333) : UIColorFromRGB(0xb4b4b4);
//            
//        }else if (indexPath.row == 1){
//            
//            cell.placeImageView.image = [UIImage imageNamed:@"bus_endTime_icon"];
//            cell.addButton.hidden = YES;
//            cell.contentLabel.text = self.charterOrder.endTime ? self.charterOrder.endTime : @"请选择结束时间";
//            cell.contentLabel.textColor = self.charterOrder.endTime ? UIColorFromRGB(0x333333) : UIColorFromRGB(0xb4b4b4);
//            
//        }else if (indexPath.row > 1){
//            
//            cell.placeImageView.image = [UIImage imageNamed:@"bus_car_icon"];
//            cell.addButton.hidden = NO;
//            VehicleConfig *config = self.charterOrder.vehicleConfigs[indexPath.row - 2];
//            
//            if (indexPath.row == 2) {
//                
//                [cell.addButton setImage:[UIImage imageNamed:@"bus_add_icon"] forState:UIControlStateNormal];
//                [cell.addButton addTarget:self action:@selector(addCar:event:) forControlEvents:UIControlEventTouchUpInside];
//                
//            }else{
//                
//                [cell.addButton setImage:[UIImage imageNamed:@"bus_remove_icon"] forState:UIControlStateNormal];
//                [cell.addButton addTarget:self action:@selector(removeCar:event:) forControlEvents:UIControlEventTouchUpInside];
//                
//            }
//            
//            if ([config isKindOfClass:[NSNull class]]) {
//                
//                cell.contentLabel.text = @"请选择车辆";
//                cell.contentLabel.textColor = UIColorFromRGB(0xb4b4b4);
//                
//            }else{
//                
//                cell.contentLabel.text = [NSString stringWithFormat:@"%@",config.vehileTypeLevel];
//                cell.contentLabel.textColor = UIColorFromRGB(0x333333);
//            }
//        }
//    }
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    self.rowPath = indexPath;
//    
//    if (indexPath.section == 0) {
//        
//        FNSearchViewController *vc = [[FNSearchViewController alloc]init];
//        vc.fnSearchDelegate = self;
//        vc.isShowTopTableView = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//        
//    }else{
//        
//        if (indexPath.row == 0 || indexPath.row == 1) {
//            DatePickerView *datePicker = [[DatePickerView alloc] initWithFrame:self.view.frame];
//            datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//            datePicker.delegate = self;
//            
//            if (indexPath.row == 0) {
//                
//                whichRow = 0;
//                datePicker.currentDate = _charteredStartDate;
//                
//            }else{
//                
//                whichRow = 1;
//                datePicker.currentDate = _charteredEndDate;
//            }
//            
//            datePicker.isShowTitle = YES;
//            datePicker.datePicker.minimumDate = [NSDate fs_dateFromString:_miniDate format:@"yyyy-MM-dd HH:mm:ss"];
//            datePicker.datePicker.maximumDate = [NSDate fs_dateFromString:_maxDate format:@"yyyy-MM-dd HH:mm:ss"];
//            [datePicker showInView:self.view];
//            
//        }else if (indexPath.row > 1){
//                
//            VehicleConfig *config = [self.charterOrder.vehicleConfigs objectAtIndex:self.rowPath.row - 2];
//            
//            NSUInteger seatIndex = 0;
//            NSUInteger levelIndex = 0;
//            NSUInteger amountIndex = 0;
//            
//            if (![config isKindOfClass:[NSNull class]]) {
//                seatIndex = 0;
//                levelIndex = 0;
//                amountIndex = 0;
//            }
//            
//             NSMutableArray *carAllInfo = [NSMutableArray arrayWithObject:@"不限"];
//            
//            [[NetInterface sharedInstance] httpGetRequest:GetRequest_VehicleType body:nil suceeseBlock:^(NSString *msg) {
//                
//                NSArray *carLevelArr =  [JsonUtils jsonToDcit:msg][@"list"];
//                
//                [[NetInterface sharedInstance] httpGetRequest:GetRequest_VehicleSeat body:nil suceeseBlock:^(NSString *msg) {
//                    
//                    DBG_MSG(@"msg = %@", msg);
//                    
//                    vechileSeartArr = [JsonUtils jsonToDcit:msg][@"list"];
//                    
//                    [[NetInterface sharedInstance] httpGetRequest:GetRequest_VehicleLevel body:@"" suceeseBlock:^(NSString *msg) {
//                        
//                        NSArray *carTypeArr = [JsonUtils jsonToDcit:msg][@"list"];
//                        
//                        for (NSDictionary *carLevel in carLevelArr) {
//                            
//                            for (NSDictionary *carType in carTypeArr) {
//                                
//                                [carAllInfo addObject:[NSString stringWithFormat:@"%@%@", carLevel[@"name"],carType[@"name"]]];
//                            }
//                        }
//                        
//                        static dispatch_once_t onceToken;
//                        dispatch_once(&onceToken, ^{
//                            
//                            for (NSDictionary *carLevel in carLevelArr) {
//                                
//                                for (NSDictionary *carType in carTypeArr) {
//                                    
//                                    [_levelTypeID addObject:@{@"levelId":carLevel[@"id"],@"typeId":carType[@"id"]}];
//                                }
//                            }
//                        });
//                        
//                        CustomPickerCarView *pickerCarView = [[CustomPickerCarView alloc]
//                                                              initWithFrame:self.view.frame
//                                                              dataSourceArray:[self carSeatArry:carAllInfo carSeat:vechileSeartArr]
//                                                              seatIndex:_charteredSeat
//                                                              levelIndex:_charteredLevel
//                                                              amountIndex:_charteredAmount];
//                        
//                        pickerCarView.isShowTitle = YES;
//                        pickerCarView.delegate = self;
//                        [pickerCarView showInView:self.view];
//                        
//                        
//                    } failedBlock:^(NSError *msg) {
//                        
//                    }];
//                    
//                } failedBlock:^(NSError *msg) {
//                    
//                    DBG_MSG(@"msg = %@", msg);
//                    
//                    [self showTip:@"请求超时" WithType:FNTipTypeFailure];
//                }];
//
//                
//            } failedBlock:^(NSError *msg) {
//                
//            }];
//        }
//
//    }
//}
//
//#pragma mark - DatePickerDelegate
//
//-(void)pickerViewOK:(NSString *)date
//{
//    if (whichRow == 0) {
//        
//        _charteredStartDate = [NSDate date];
//        _charteredStartDate = [NSDate fs_dateFromString:date format:@"yyyy-MM-dd HH:mm"];
//        
//    }else{
//        
//        _charteredEndDate = [NSDate date];
//        _charteredEndDate = [NSDate fs_dateFromString:date format:@"yyyy-MM-dd HH:mm"];
//    }
//    
//    if (self.rowPath.section == 1) {
//        
//        if (self.rowPath.row == 0) {
//            
//            self.charterOrder.startTime = date;
//            
//        }else if (self.rowPath.row == 1){
//            
//            self.charterOrder.endTime = date;
//            
//        }
//    }
//    
//    if (self.rowPath) {
//        
//        [self.tableViewNormal reloadRowsAtIndexPaths:@[self.rowPath] withRowAnimation:UITableViewRowAnimationNone];
//        self.rowPath = nil;
//    }
//    
//    [self refreshPrice];
//}
//
//
//
//#pragma mark - CustomPickerCarViewDelegate
//
//- (void)pickerCarViewOKSeatIndex:(NSUInteger)seatIndex levelIndex:(NSUInteger)levelIndex amountIndex:(NSUInteger)amountIndex title:(NSString *)title pickerCarView:(CustomPickerCarView *)pickerCarView{
//    
//    _charteredSeat   = seatIndex;
//    _charteredLevel  = levelIndex;
//    _charteredAmount = amountIndex;
//    
//    if (self.rowPath.section == 1) {
//        
//        if (self.rowPath.row > 1) {
//            
//            VehicleConfig *config = [self.charterOrder.vehicleConfigs objectAtIndex:self.rowPath.row - 2];
//            
//            if ([config isKindOfClass:[NSNull class]]) {
//                
//                config = [[VehicleConfig alloc]init];
//            }
//            
//            config.vehileTypeLevel = title;
//            
//            int levelId = [_levelTypeID[pickerCarView.carTypeAndLevelId][@"levelId"] intValue];
//            int typeId = [_levelTypeID[pickerCarView.carTypeAndLevelId][@"typeId"] intValue];
//            
//            NSDictionary *vehicleInfoDic = @{@"Seat":vechileSeartArr[seatIndex],@"VehicleLevelId":@(levelId),@"VehicleTypeId":@(typeId),@"Amount":@(amountIndex+1)};
//            
//            [self.charteredCarInfo replaceObjectAtIndex:self.rowPath.row-2 withObject:vehicleInfoDic];
//            
//            NSMutableArray *mArr = [self.charterOrder.vehicleConfigs mutableCopy];
//            
//            [mArr replaceObjectAtIndex:self.rowPath.row - 2 withObject:config];
//            
//            self.charterOrder.vehicleConfigs = mArr;
//        }
//    }
//    
//    if (self.rowPath) {
//        
//        [self.tableViewNormal reloadRowsAtIndexPaths:@[self.rowPath] withRowAnimation:UITableViewRowAnimationNone];
//        self.rowPath = nil;
//    }
//    
//    [self refreshPrice];
//    
//}
//
//#pragma mark - FNSearchViewControllerDelegate
//
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
//            path.pathType = 1;
//            _charteredStartLatitude = location.coordinate.latitude;
//            _charteredStartLongitude = location.coordinate.longitude;
//            
//            [self getMilesfromeMap:_airportGeoPointArray];
//            
//        }else if (self.rowPath.row == rowCount - 1) {
//            
//            path.pathType = 2;
//            
//            _charteredEndLatitude = location.coordinate.latitude;
//            _charteredEndLongitude = location.coordinate.longitude;
//            
//            [self getMilesfromeMap:_airportGeoPointArray];
//            
//        }else{
//            
//            path.pathType = 3;
//            
//            AMapGeoPoint *geoPoint = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
//            
//            [_airportGeoPointArray replaceObjectAtIndex:self.rowPath.row - 1 withObject:geoPoint];
//            
//            [self getMilesfromeMap:_airportGeoPointArray];
//        }
//        
//        NSDictionary *pathDic = @{@"pathType":@(path.pathType),
//                                  @"name":path.name,
//                                  @"adCode":path.adCode,
//                                  @"sequence":@(path.sequence),
//                                  @"location":path.location};
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
//}
//
//#pragma mark -- Compute Chartered Price
//
//- (void)computeAirportPrice{
//    
//    
//    if ((_charterOrder.startTime.length == 0) ||
//        (_charterOrder.endTime.length == 0) ||
//        (_charteredMiles.length == 0) ||
//        (_charteredPassageFares.length == 0) ||
//        (_charteredCarInfo.count == 0) ||
//        (self.charteredPathArr.count == 0)) {
//        
//        [self showPromptView];
//        
//    }else{
//        [self startWait];
//        NSDictionary *priceParams = @{@"type":AirpotType,
//                                      @"startTime":_charterOrder.startTime,
//                                      @"endTime":_charterOrder.endTime,
//                                      @"mapSourceType":@"1",
//                                      @"miles":_charteredMiles,
//                                      @"passageFares":_charteredPassageFares,
//                                      @"virtualId":_charteredVirtualId,
//                                      @"isDriverFress":[NSString stringWithFormat:@"%d",_isDriverFree],
//                                      @"vehicleConfigs":_charteredCarInfo,
//                                      @"paths":self.charteredPathArr};
//        
//        [[NetInterfaceManager sharedInstance] postRequst:PostRequest_CharteredPrice body:[JsonUtils dictToJson:priceParams] requestType:RequestType_ComputeCharteredPrice];
//    }
//}
//
//
//#pragma mark -- AMapSearchDelegate
//
//- (void)searchRequest:(id)request didFailWithError:(NSError *)error{
//    
//    NSLog(@"request = %@", error);
//}
//
//- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
//    
//    NSLog(@"respone = %@", response.route);
//    
//    //driveCar miles
//    _charteredMiles = [NSString stringWithFormat:@"%.2f", (double)((AMapPath *)(response.route.paths[0])).distance/1000];
//    
//    //driveCar cost
//    _charteredPassageFares = [NSString stringWithFormat:@"%.2f", ((AMapPath *)(response.route.paths[0])).tolls * 100];;
//}
//
//#pragma mark -- http respone
//
//- (void)httpRequestFinished:(NSNotification *)notification{
//    
//    if (_airportSwitch == YES) {
//        _airportSwitch = NO;
//        
//        [self stopWait];
//        
//        int type = [notification.object[@"type"] intValue];
//        
//        switch (type) {
//            case RequestType_ComputeCharteredPrice:
//                
//                self.charteredVirtualId = notification.object[@"data"][@"virtualId"];
//                
//                self.totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f元",[((NSString *)notification.object[@"data"][@"price"]) doubleValue]/100];
//                
//                [self.computAirportPrice setTitle:@"发布行程" forState:UIControlStateNormal];
//                
//                _isComputePrice = NO;
//                
//                break;
//                
//            case RequestType_SubmitCharteredOrder:
//                
//                if ([notification.object[@"data"][@"code"] intValue] == 0) {
//                    
//                    _receiveAPNS = YES;
//                    
//                    [time setFireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
//                }
//                
//                break;
//                
//            default:
//                break;
//        }
//    }
//
//}
//
//- (void)httpRequestFailed:(NSNotification *)notification{
//    [super httpRequestFailed:notification];
//}
//
//#pragma mark -- receive APNS
//
//- (void)pushNotificationArrived:(NSDictionary *)userInfo{
//    
//    NSLog(@"包车收到APNS");
//    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    
//    if (_receiveAPNS == YES) {
//        
//        _receiveAPNS = NO;
//        
//        //"0"提交订单成功
//        if ([userInfo[@"code"] intValue] == 0) {
//            
//            //"1"生成订单
//            if ([userInfo[@"processType"] intValue] == 1) {
//                
//                //APNS
//                _charteredOrderID =  userInfo[@"orderId"];
//                
//                CharteredTravelingViewController *vc = [[UIStoryboard storyboardWithName:@"Travel" bundle:nil] instantiateViewControllerWithIdentifier:@"CharteredTravelingViewController"];
//                
//                vc.orderId = _charteredOrderID;
//                NSLog(@"ORDERID = %@", vc.orderId);
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//    }
//}

@end
