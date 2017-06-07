//
//  ApplyRouteViewController.m
//  FeiNiu_User
//
//  Created by CYJ on 16/5/26.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ApplyScheduledViewController.h"
#import "ApplySuccessViewController.h"
#import "FNSearchViewController.h"
//#import "CityObj.h"
#import "CityInfoCache.h"

#import <FNUIView/UserCustomAlertView.h>
#import <FNUIView/DatePickerView.h>

#import "FeiNiu_User-Swift.h"

@interface ApplyScheduledViewController ()<UITextFieldDelegate, FNSearchViewControllerDelegate, DatePickerViewDelegate, UserCustomAlertViewDelegate>
{

}

@property (nonatomic, copy) NSString *onworkTime;
@property (nonatomic, copy) NSString *offworkTime;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DatePickerView *datePicker;
@end

@implementation ApplyScheduledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _onworkTime = @"09:00";
//    _offworkTime = @"18:00";
    
    
    if ([CityInfoCache sharedInstance].commuteCurCity == nil) {
        [self startWait];
        [[NetInterfaceManager sharedInstance] sendRequstWithType:EmRequestType_CommuteOpenCity params:^(NetParams *params) {
            
        }];
    }
}

//- (void)btnBackClick:(id)sender
//{
//    [self popViewController];
//}

#pragma  mark -
-(DatePickerView*)getDateView
{
    if (!self.datePicker) {
        self.datePicker = [[DatePickerView alloc] init];
        self.datePicker.delegate = self;
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        self.datePicker.minuteInterval = 10;
//        self.datePicker.minDate = [DateUtils dateFromString:@"09:00" format:@"HH:mm"];
//        self.datePicker.maxDate = [DateUtils dateFromString:@"18:00" format:@"HH:mm"];
        //self.datePicker.currentDate = [DateUtils dateFromString:@"09:00" format:@"HH:mm"];
    }
    
    return self.datePicker;
}

- (void)pickerView:(DatePickerView*)view selectDate:(NSString*)date
{
    if (view.extTag == 0) {
        self.onworkTime = date;
    }
    else {
        self.offworkTime = date;
    }
    
    [self.tableView reloadData];
}

-(FNSearchViewController*)getMapController
{
    FNSearchViewController *searchController  = [FNSearchViewController instanceWithStoryboardName:@"ShuttleBus"];
    searchController.fnSearchDelegate = self;
    searchController.isShuttleBus = false;
    
    return searchController;
}

- (void)searchViewController:(FNSearchViewController *)searchViewController didSelectLocation:(FNLocation *)location;
{
    if ([searchViewController.navTitle isEqualToString:@"选择上车地点"]) {
        self.homeAddr = location.name;
        self.homeCoorinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    }
    else {
        self.componyAddr = location.name;
        self.componyCoorinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    }
    
    [self.tableView reloadData];
}

- (IBAction)btnCommitClick:(id)sender {
    if (!self.homeAddr) {
        [self showTip:@"请填写您住在哪儿" WithType:FNTipTypeFailure];
        return;
    }
    if (!self.componyAddr) {
        [self showTip:@"请填写公司在哪儿" WithType:FNTipTypeFailure];
        return;
    }
    if (!self.onworkTime) {
        [self showTip:@"请填写上班时间" WithType:FNTipTypeFailure];
        return;
    }
    if (!self.offworkTime) {
        [self showTip:@"请填写下班时间" WithType:FNTipTypeFailure];
        return;
    }
    
    
    if ([self.homeAddr isEqualToString:self.componyAddr]) {
        [self showTip:@"家庭住址与公司地址相同" WithType:FNTipTypeFailure];
        return;
    }
    
    CityObj *city = [CityInfoCache sharedInstance].commuteCurCity;
    if (city) {
         [self startWait];
        [[NetInterfaceManager sharedInstance] sendRequstWithType:EmRequestType_CommuteApply params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            params.data = @{@"adcode":city.adcode,
                            @"on_address":self.homeAddr,
                            @"on_latitude":[NSNumber numberWithDouble: self.homeCoorinate.latitude],
                            @"on_longitude":[NSNumber numberWithDouble: self.homeCoorinate.longitude],
                            @"off_address":self.componyAddr,
                            @"off_latitude":[NSNumber numberWithDouble: self.componyCoorinate.latitude],
                            @"off_longitude":[NSNumber numberWithDouble: self.componyCoorinate.longitude],
                            @"on_duty_time":self.onworkTime,
                            @"off_duty_time":self.offworkTime};
        }];
    }
    
}

- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    ApplySuccessViewController *c = [ApplySuccessViewController instanceWithStoryboardName:@"Me"];
    c.homeAddr = self.homeAddr;
    c.componyAddr = self.componyAddr;
    c.onworkTime = self.onworkTime;
    c.offworkTime = self.offworkTime;
    
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    [viewControllers addObject:c];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark -  uitableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"applyTableCell" forIndexPath:indexPath];
    
    UIImageView *cellImage = [cell viewWithTag:101];
    UILabel *cellTitleLabel = [cell viewWithTag:102];
    UILabel *cellSubTitleLabel = [cell viewWithTag:103];
    UIView *longLineView = [cell viewWithTag:104];
    [longLineView setHidden:YES];
    
    switch (indexPath.row) {
        case 0: {
            cellImage.image = [UIImage imageNamed:@"icon_home"];
            cellTitleLabel.text = @"家庭住址";
            cellSubTitleLabel.text = self.homeAddr ? self.homeAddr : @"您住在哪儿?";
            cellSubTitleLabel.textColor = self.homeAddr == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
        case 1: {
            cellImage.image = [UIImage imageNamed:@"icon_mac"];
            cellTitleLabel.text = @"公司地址";
            cellSubTitleLabel.text = self.componyAddr ? self.componyAddr : @"公司在哪儿?";
            cellSubTitleLabel.textColor = self.componyAddr == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
        case 2: {
            cellImage.image = [UIImage imageNamed:@"icon_time_work"];
            cellTitleLabel.text = @"上班时间";
            cellSubTitleLabel.text = self.onworkTime ? self.onworkTime : @"几点上班?";
            cellSubTitleLabel.textColor = self.onworkTime == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
        case 3: {
            cellImage.image = [UIImage imageNamed:@"icon_time_off_duty"];
            cellTitleLabel.text = @"下班时间";
            cellSubTitleLabel.text = self.offworkTime ? self.offworkTime : @"几点下班?";
            cellSubTitleLabel.textColor = self.offworkTime == nil ? UITextColor_LightGray : UITextColor_DarkGray;
            [longLineView setHidden:NO];
        }
            break;
            
        default:
            break;
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            FNSearchViewController *mapController = [self getMapController];
            mapController.navTitle =@"选择上车地点";
            [self.navigationController pushViewController:mapController animated:YES];
        }
            break;
        case 1: {
            FNSearchViewController *mapController = [self getMapController];
            mapController.navTitle =@"选择下车地点";
            [self.navigationController pushViewController:mapController animated:YES];
        }
            break;
        case 2: {
            DatePickerView *dateView = [self getDateView];
            dateView.extTag = 0;
            if (self.onworkTime) {
                dateView.currentDate = [DateUtils dateFromString:self.onworkTime format:@"HH:mm"];
            }
            else{
                dateView.currentDate = [DateUtils dateFromString:@"09:00" format:@"HH:mm"];
            }
            
            [dateView showInView:self.view];
        }
            break;
        case 3: {
            DatePickerView *dateView = [self getDateView];
            dateView.extTag = 1;
            if (self.offworkTime) {
                dateView.currentDate = [DateUtils dateFromString:self.offworkTime format:@"HH:mm"];
            }
            else {
                dateView.currentDate = [DateUtils dateFromString:@"18:00" format:@"HH:mm"];
            }
            [dateView showInView:self.view];
        }
            break;
            default:
            break;
    }
}


#pragma mark- http request handler

-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    if (resultData.type == EmRequestType_CommuteOpenCity) {
        NSArray *cityAr = [CityObj mj_objectArrayWithKeyValuesArray:resultData.data];
        
        [CityInfoCache sharedInstance].arCommuteCitys = cityAr;
        
        FNLocation *location = [CityInfoCache sharedInstance].curLocation;
        if (location) {
            for (CityObj *city in cityAr) {
                if ([[location.adCode substringToIndex:4] isEqualToString:[city.adcode substringToIndex:4]]) {
                    [CityInfoCache sharedInstance].commuteCurCity = city;
                    break;
                }
            }
        }else {
            [CityInfoCache sharedInstance].commuteCurCity = [cityAr firstObject];
        }
        
        
    }
    else if (resultData.type == EmRequestType_CommuteApply) {
        UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"提交成功!" message:@"感谢您关注飞牛巴士!" delegate:self];
        [alert showInView:self.view];
    }
    
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

@end
