
//
//  CarpoolViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/7/31.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "CarpoolViewController.h"
#import "CustomTicketView.h"
#import "SelectDestViewController.h"
#import "NSDate+FSExtension.h"
#import <FNUIView/DatePickerView.h>

#import "CustomCalendarView.h"
#import "FNCommon/JsonUtils.h"
#import "CarpoolTravelingViewController.h"
#import "CarpoolOrderPrice.h"
#import "FNUIView/MBProgressHUD.h"
#import "CarpoolOrderItem.h"
#import "RuleViewController.h"
#import "LoginViewController.h"
#import <FNNetInterface/PushConfiguration.h>

//#import <FNNetInterface/AFNetworking.h>
#import "PushNotificationAdapter.h"
#import "TravelHistoryViewController.h"

#define StartCityPage 0
#define EndCityPage 1
#define PostRequest_BusShift(A,B) [NSString stringWithFormat:@"%@CarpoolBusShift?startAdCode=%@&endAdcode=%@",KServerAddr, A, B]
#define GetRequest_coupons(A) [NSString stringWithFormat:@"%@coupons?subOrderId=%@", KServerAddr,A]

enum {
    AnnotationViewControllerAnnotationTypeRed = 0,
    AnnotationViewControllerAnnotationTypeGreen,
    AnnotationViewControllerAnnotationTypePurple
};

@interface CarpoolViewController ()<CustomTicketViewDelegate>{
    
    
    int _carpoolLeftRow;
    int _carpoolRightRow;
    int _timeRow;
    int _pickRow;
    
    NSInteger adultNum;
    NSInteger childNum;
    
    NSString *_dateString;
    NSMutableArray *_carpoolComputePriceData;
    
    NSString *_allPrice;
    BOOL _flag;
    BOOL _flagButton;
    NSIndexPath *_flagIndex;
    
}

@property (strong, nonatomic) IBOutlet UILabel *startPlaceLabel;
@property (strong, nonatomic) IBOutlet UILabel *endPlaceLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@property (strong, nonatomic) IBOutlet UILabel *ticketNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *yLabel;

@property (nonatomic, strong) NSMutableString *startPlaceAdcode;
@property (nonatomic, strong) NSMutableString *endPlaceAdcode;
@property (nonatomic, strong) NSString *carpoolVirtualId;

@property (nonatomic, strong) NSMutableString *carpoolAdcodeId;
@property (nonatomic, strong) NSMutableString *carpoolId;

@property (nonatomic, strong) NSMutableString *carpoolStartTime;
@property (nonatomic, strong) NSMutableString *carpoolEndTime;
@property (nonatomic, strong) NSMutableString *carpoolPathId;
@property (nonatomic, strong) NSMutableString *carpoolTrainId;
@property (nonatomic, strong) NSString *carpoolOrderId;

@property (nonatomic, strong) NSIndexPath *tableIndex;
@property (nonatomic, strong) NSIndexPath *collectionIndex;

@end

@implementation CarpoolViewController

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //judge network status
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];

    }
    
    [self registerNotification];
    
    [self initNavigationBar];
    
    [self initProperty];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:@"savevalue"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSuccess:) name:@"LoginSuccessNotification" object:nil];

    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    _carpoolVirtualId = [self getGUID];
}

- (void)handleLoginSuccess:(NSNotification *)notification{
    // 登陆成功，重新计算价格
    [self virtualIdChanged];
}
#pragma mark -- init user interface

- (void)initProperty{
    adultNum = 0;
    _dateString              = [NSString        string];
    _carpoolComputePriceData = [NSMutableArray   array];
    _carpoolAdcodeId         = [NSMutableString string];
    _carpoolId               = [NSMutableString string];
    _carpoolVirtualId        = [self getGUID];
    
    self.yLabel.layer.borderColor = UIColorFromRGB(0x06c1ae).CGColor;
    
//    self.ticketNumLabel.attributedText = [self setRichText:@"1人"];

}

- (void)initNavigationBar
{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnRight setFrame:CGRectMake(0, 0, 44, 44)];
    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [btnRight setTitle:@"规则" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(btnRuleClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
    self.navigationItem.title = @"客车订票";
}


#pragma mark -- function method
- (void)getParamsOfComputePrice:(NSString *)startAdcode EndCode:(NSString *)endAdcode{
    
    [self stopWait];
    [NetManagerInstance sendRequstWithType:RequestType_CarpoolBusShift params:^(NetParams *params) {
        params.data = @{@"startAdCode": startAdcode,
                        @"endAdcode":   endAdcode};
    }];
}

- (NSString *)getGUID{
    
    return [[NSUUID UUID] UUIDString] ;
}

- (void)showAlertView:(NSString *)text{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:text
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)popPromptView:(NSString *)text{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    [hud show:YES];
    [hud setLabelText:text];
    [hud setMode:MBProgressHUDModeText];
    [hud hide:YES afterDelay:2];
    
    if (hud.hidden == YES) {
        
        [hud removeFromSuperview];
    }
}


- (BOOL)judgeOrderInfoContent{
    
    if ([_startPlaceLabel.text isEqualToString:@"出发地"]) {
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入出发地" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
        
        [self showTipsView:@"请选择出发地"];
        
        return NO;
    }
    
    if ([_endPlaceLabel.text isEqualToString:@"目的地"]) {
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入目的地" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
        
        [self showTipsView:@"请选择目的地"];
        
        return NO;
    }
    
    if ([_timeLabel.text isEqualToString:@"出发时间"]) {
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输出发时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
        
        [self showTipsView:@"请选择出发时间"];
        
        return NO;
    }
    
    if ([_ticketNumLabel.text isEqualToString:@"出行人数"]) {
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入出行人数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];

        [self showTipsView:@"请选择出行人数"];
        return NO;
    }
    return YES;
}

#pragma mark -- Function Methods

- (void)refreshProperty{
    
    self.carpoolStartTime = [NSMutableString string];
    self.carpoolEndTime   = [NSMutableString string];
    self.carpoolPathId    = [NSMutableString string];
    self.carpoolTrainId   = [NSMutableString string];
    _carpoolLeftRow       = 0;
    _carpoolRightRow      = 0;
    [_timeLabel setText:@"出发时间"];
    [_timeLabel setTextColor:[UIColor grayColor]];
}

#pragma mark - action
//Rule Button
- (void)btnRuleClick
{
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];
        return;
    }
    
    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    
    ruleVC.vcTitle = @"规则";
    ruleVC.urlString = [NSString stringWithFormat:@"%@rule1.html",KAboutServerAddr];
    [self.navigationController pushViewController:ruleVC animated:YES];
}

//start city button
- (IBAction)startPlaceButton:(id)sender {
    
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];
        return;
    }
    
    SelectDestViewController *selectDestVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"selectvc"];
    
    selectDestVC.pageId = StartCityPage;
    
    if (_startPlaceLabel.text) {
        selectDestVC.defaultName = _startPlaceLabel.text;
    }
    
    [self.navigationController pushViewController:selectDestVC animated:YES];
}

//end city button
- (IBAction)endPlaceButton:(id)sender {
    
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];
        return;
    }
    
    if (self.startPlaceAdcode) {
      
        SelectDestViewController *selectDestVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"selectvc"];
        if (_endPlaceLabel.text) {
            selectDestVC.defaultName = _endPlaceLabel.text;
        }
        selectDestVC.pageId = EndCityPage;
        selectDestVC.adCodeId = self.startPlaceAdcode;
        
        [self.navigationController pushViewController:selectDestVC animated:YES];
    
    }else{
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择出发地" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
        [self showTipsView:@"请选择出发地"];
    }
}

//the number of people
- (IBAction)numByTap:(id)sender {
    
//    if (adultNum == 0) {
//        adultNum = 1;
//        self.ticketNumLabel.attributedText = [self setRichText:@"1人"];
//    }
    
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];
        return;
    }
    
    CustomTicketView *ticketView = [CustomTicketView instance];
    
    ticketView.customRow    = _pickRow;
    ticketView.parentAmount = adultNum;
    ticketView.childAmount  = childNum;
    ticketView.delegate     = self;
    
    
    [ticketView showInView:self.view];
}

//scheduling button
- (IBAction)timeByTap:(id)sender {
    
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];
        return;
    }
    
    if (_carpoolComputePriceData.count != 0) {
       
        CustomCalendarView *calendarView = [CustomCalendarView instance];
        
        if ([_dateString length] != 0) {
           
            calendarView.selectedDate = _dateString;
            
        }else{
            
            calendarView.selectedDate = [[NSDate date] fs_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        
        [calendarView setIndexRow        :_timeRow];
        [calendarView setLeftTimeIndex   :_carpoolLeftRow];
        [calendarView setRightTimeIndex  :_carpoolRightRow];
        [calendarView setCalendDataSource:_carpoolComputePriceData];
        [calendarView setCellIsSelected        :_flag];
        [calendarView setScrollButtonIsSelected:_flagButton];
        [calendarView setCustomIndexPath:_tableIndex];
        [calendarView setCustomCollectionIndexPath:_collectionIndex];
        [calendarView setFlagIndex:_flagIndex];
        
        [calendarView showInView:self.view];

    }else{
        
        if ([_endPlaceLabel.text isEqualToString:@"目的地"]) {

            [self showTipsView:@"请选择出发地或目的地"];
            return;
        }
        
        [self showTipsView:@"车票已售完"];
    }
}

//pulished at schedule button
- (IBAction)clickSubmitButton:(id)sender {
    
    if (_networkingStatus == NO) {
        
        [self popPromptView:@"暂无网络"];
        return;
    }
    
    //判断订单信息是否填写完成
    if (![self judgeOrderInfoContent]) {
        return;
    }
    
    [self startWait];
    //submit order
    [NetManagerInstance sendRequstWithType:RequestType_SubmitOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"virtualId":self.carpoolVirtualId};
    }];
}

- (NSAttributedString *)setRichText:(NSString *)string
{
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString:string];
    
    NSUInteger length = [string length];
    
    UIColor *color = nil;
    
    if ([string isEqualToString:@"出行人数"]) {
        
        color = [UIColor grayColor];
        
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:color
                           range:NSMakeRange(0, length)];
    }else {
        
        color = UIColorFromRGB(0x333333);
        
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:color
                           range:NSMakeRange(0, length)];
        
        UIColor *numcolor = UIColorFromRGB(0xff9e05);
        
        if (length > 8) {
            
            [attrString addAttribute:NSForegroundColorAttributeName
                               value:numcolor
                               range:NSMakeRange(3, 1)];
            [attrString addAttribute:NSForegroundColorAttributeName
                               value:numcolor
                               range:NSMakeRange(10, 1)];
        }else{
            
            [attrString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor blackColor]
                               range:NSMakeRange(0, 1)];
        }
    }
    
    
    return attrString;
}

- (IBAction)leftIconClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showtips" object:nil
     ];
}

- (IBAction)middleIconClick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showtips" object:nil
     ];
}

- (IBAction)rightIconClick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showtips" object:nil
     ];
}

#pragma mark - CustomTicketView

-(void)pickerTicketViewOKParentAmount:(NSUInteger)parentAmount childAmount:(NSUInteger)childAmount customTicketView:(CustomTicketView *)ticketView
{
    
    
    if (childAmount <= parentAmount) {
        
//        _pickRow = (int)row;
//        [self.ticketNumLabel setText:[NSString stringWithFormat:@"%d张",_pickRow]];
        
        adultNum = parentAmount;
        childNum = childAmount;
        
        NSString *str = nil;
        
        if (parentAmount == 0) {
            
            str = @"出行人数";
        }else{
           
            str = [CustomTicketView getTicketNum:parentAmount childAmount:childAmount];
        }
        
        
        if (str) {
            self.ticketNumLabel.attributedText = [self setRichText:str];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"virtualidchanged" object:nil];
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"成人票数不得少于儿童票数" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alertView show];
    }
}

#pragma mark -- register notification

- (void)registerNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCityName:) name:@"cityname" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTimeLabel:) name:@"timelabel" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(virtualIdChanged) name:@"virtualidchanged" object:nil];
}

#pragma mark -- notification event

- (void)changeCityName:(NSNotification *)notification{
    
    if ([notification.object intValue] == EndCityPage) {
        
        if (![self.carpoolId isEqualToString:notification.userInfo[@"pathId"]]) {
            
            [self startWait];
            _dateString = @"";
            self.endPlaceAdcode = notification.userInfo[@"adCode"];
            self.carpoolId = notification.userInfo[@"pathId"];
            [self.endPlaceLabel setText:notification.userInfo[@"name"]];
            [self getParamsOfComputePrice:_startPlaceAdcode EndCode:self.endPlaceAdcode];
        }
        
    }else if([notification.object intValue] == StartCityPage){
        
        if ([self.endPlaceLabel.text isEqualToString:self.startPlaceLabel.text]) {
         
            self.endPlaceLabel.text = @"目的地";
        }
        
        if (![self.startPlaceAdcode isEqualToString:notification.userInfo[@"adcodeId"]]) {
            
            [self.startPlaceLabel setText:notification.userInfo[@"name"]];
            self.startPlaceAdcode = notification.userInfo[@"adcodeId"];
            self.endPlaceLabel.text = @"目的地";
        }
    }
    
    [self refreshProperty];//初始化日期
}

//listen starplace or endplace or time or people numbers changed
- (void)virtualIdChanged{
    
    if (adultNum == 0) {
        return;
    }
    
    [NetManagerInstance sendRequstWithType:RequestType_ComputePrice params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"virtualId":        self.carpoolVirtualId,
                        @"peopleNumber":     @(adultNum),
                        @"childrenNumber":   @(childNum),
                        @"bookingStartTime": self.carpoolStartTime,
                        @"bookingEndTime":   self.carpoolEndTime,
                        @"pathId":           self.carpoolPathId,
                        @"trainId":          self.carpoolTrainId};
        
    }];
}

- (void)changeTimeLabel:(NSNotification *)notification{
    
    self.carpoolStartTime = notification.object[@"starttime"];
    self.carpoolEndTime   = notification.object[@"endtime"];
    self.carpoolPathId    = notification.object[@"pathid"];
    self.carpoolTrainId   = notification.object[@"trainid"];
    _carpoolLeftRow       = [notification.object[@"leftrow"] intValue];
    _carpoolRightRow      = [notification.object[@"rightrow"] intValue];
    _timeRow              = [notification.object[@"indexRow"] intValue];
    _flag                 = [notification.object[@"isSelected"] boolValue];
    _flagButton           = [notification.object[@"scrollButtonSelected"] boolValue];
    _tableIndex           = notification.object[@"talbeIndex"];
    _collectionIndex      = notification.object[@"collectionIndex"];
    _flagIndex            = notification.object[@"flagIndex"];
    
    //滚动
    if ([notification.userInfo[@"type"] intValue] == 10) {
        
        [_timeLabel setTextColor:[UIColor blackColor]];
        
        [self.timeLabel setText:[NSString stringWithFormat:@"%@ %@", notification.userInfo[@"date"], notification.userInfo[@"time"]]];
        
        _dateString = [[[notification.userInfo[@"date"] substringToIndex:10] stringByReplacingOccurrencesOfString:@"年" withString:@"-"] stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
        
    }else{
       
        [_timeLabel setTextColor:[UIColor blackColor]];
        [self.timeLabel setText:notification.userInfo[@"time"]];
        //
        _dateString = [[[_timeLabel.text substringToIndex:10] stringByReplacingOccurrencesOfString:@"年" withString:@"-"] stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
        
    }
    
    _dateString = [_dateString stringByAppendingString:@" 00:00:00"];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"virtualidchanged" object:nil];
}

#pragma mark -- httprequest  respone

- (void)httpRequestFinished:(NSNotification *)notification{
    
    NSLog(@"value = %@", notification.object);
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    int type = resultData.requestType;
    NSDictionary *data = resultData.data;
    
    switch (type) {
            
        case RequestType_ComputePrice:
            
            if (resultData.resultCode == 0) {
                
                NSString *price =[NSString stringWithFormat:@"%.1f", [resultData.data[@"price"] floatValue]/100];
                
                NSArray *arr = [price componentsSeparatedByString:@"."];
                
                if ([(NSString *)arr[1] isEqualToString:@"0"]) {
                    
                    _allPrice = [NSString stringWithFormat:@"￥%d元",[((NSString *)resultData.data[@"price"]) intValue]/100];
                    
                    [self.priceLabel setText:[NSString stringWithFormat:@"￥%d元",[((NSString *)resultData.data[@"price"]) intValue]/100]];
                }else{
                    
                    _allPrice = [NSString stringWithFormat:@"￥%.1f元",[((NSString *)resultData.data[@"price"]) floatValue]/100];
                    
                    [self.priceLabel setText:[NSString stringWithFormat:@"￥%.1f元",[((NSString *)resultData.data[@"price"]) floatValue]/100]];
                }
                
                
                
                //compute coupon price
//                CGFloat couponValue = [((NSString *)notification.object[@"data"][@"marketPrice"]) doubleValue] - [((NSString *)notification.object[@"data"][@"price"]) doubleValue];
//                
//                if (couponValue == 0) {
//                    
//                    [self.yLabel setHidden:YES];
//                    
//                }else{
//                    [self.yLabel setHidden:NO];
//                    [self.yLabel setText:[NSString stringWithFormat:@"比车站优惠%.1f元",couponValue/100]];
//                }
            }else{
                
                [self showTipsView:resultData.message];
            }
            
            
            break;
            
        case RequestType_SubmitOrder:
            
            if ([_allPrice isEqualToString:@"0"]) {
                [self showTipsView:@"车票已售完"];
                return;
            }
            
            self.carpoolOrderId = data[@"orderId"];
            
            if (resultData.resultCode == 0) {
               
                CarpoolTravelingViewController *carpoolVC = [CarpoolTravelingViewController instanceFromStoryboard];
                
                CarpoolOrderItem *item = [CarpoolOrderItem new];
                
                item.orderId = self.carpoolOrderId;
                
                carpoolVC.carpoolOrder = item;
                
                TravelHistoryViewController *travelManageVC = [TravelHistoryViewController instanceFromStoryboard];
                NSMutableArray *temp = [self.navigationController.viewControllers mutableCopy];
                [temp removeObject:self];
                [temp addObject:travelManageVC];
                [temp addObject:carpoolVC];
                [self.navigationController setViewControllers:temp animated:YES];
                
//                [self.navigationController pushViewController:carpoolVC animated:YES];
            }else{
                [self showTipsView:resultData.message];
            }

            break;
            
        case RequestType_checkOrderSuccess:
         
            if ([resultData.data[@"status"] intValue] == 2) {
                
                [self popPromptView:@"当日车票已售完"];
                return;
            }
            
            break;
            
        case  RequestType_CarpoolBusShift:
        {
            _carpoolComputePriceData = (NSMutableArray *)resultData.data[@"list"];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"message = %@", _carpoolComputePriceData);
        }
            
        default:
            break;
    }
}

- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
    
}

#pragma mark -- network request

//submit order success or failed
- (void)checkSubmitSuccessOrFailed:(NSString *)orderId{
    
    [NetManagerInstance sendRequstWithType:RequestType_checkOrderSuccess params:^(NetParams *params) {
        params.data = @{@"orderId":orderId};
    }];

}

#pragma mark -- Receive APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
//    FNPushProccessType type = [userInfo[kProccessType] integerValue];
//    if (type == FNPushProccessType_CarpoolOrderCreate) {
//        if ([userInfo[@"code"] integerValue] == 0) {
//            CarpoolTravelingViewController *carpoolVC = [CarpoolTravelingViewController instanceFromStoryboard];
//            
//            CarpoolOrderItem *item = [CarpoolOrderItem new];
//            
//            item.orderId = userInfo[@"mainOrderId"];
//            
//            carpoolVC.carpoolOrder = item;
//            
//            [self.navigationController pushViewController:carpoolVC animated:YES];
//        }else{
//            [self showTip:userInfo[@"message"] WithType:FNTipTypeFailure];
//        }
//    }
}

#pragma mark -- talbe view delegate




@end
