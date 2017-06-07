//
//  TianFuCarPayVC.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/30.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TianFuCarPayVC.h"
#import "CharterRoutingViewController.h"
#import "PingPPayUtil.h"
#import "TFCarEvaluationVC.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "TravelViewController.h"
#import "MainViewController.h"
#import "CouponsViewController.h"
#import "TravelHistoryViewController.h"

NSString *CouponTypeKey = @"type";
NSString *CouponStateKey = @"state";
NSString *CouponLimitKey = @"limit";

@interface TianFuCarPayVC (){
    
    PaymentChannel mode;
    NSTimer* timer;
}

//Top View
@property (strong, nonatomic) IBOutlet UIImageView *driverAvatar;
@property (strong, nonatomic) IBOutlet UILabel  *driverName;
@property (strong, nonatomic) IBOutlet UILabel  *CarNumber;
@property (strong, nonatomic) IBOutlet UILabel  *receiveOrderNumbers;
@property (strong, nonatomic) IBOutlet UILabel  *driverScores;
@property (strong, nonatomic) IBOutlet UIButton *callDriverButton;

//five stars imageview
@property (strong, nonatomic) IBOutlet UIImageView *firstStar;
@property (strong, nonatomic) IBOutlet UIImageView *secondStar;
@property (strong, nonatomic) IBOutlet UIImageView *thirdStar;
@property (strong, nonatomic) IBOutlet UIImageView *fouthStar;
@property (strong, nonatomic) IBOutlet UIImageView *fivethStar;

//middle view
@property (strong, nonatomic) IBOutlet UIButton *alipayButton;
@property (strong, nonatomic) IBOutlet UIButton *wechatButton;
@property (strong, nonatomic) IBOutlet UIButton *arrowButton;
@property (strong, nonatomic) IBOutlet UILabel  *currentCouponLabel;

//Bottom View
@property (strong, nonatomic) IBOutlet UIButton *payButton;

@property (nonatomic, strong) Coupon *coupon;

@end

@implementation TianFuCarPayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initNavigationItems];
    [self initTimer];
    
    [_alipayButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [_alipayButton setBackgroundImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateSelected];
    [_wechatButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [_wechatButton setBackgroundImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateSelected];
    [self alipayButtonClick:_alipayButton];
    
    if (_orderDetailModel) {
        [self setOwerInformation];
    }else if(_orderId){
        [self startWait];
        [self requstFerryOrderCheckState];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePayNotification:) name:FNPayResultNotificationName object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- init property

- (void)initNavigationItems{
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLeft setFrame:CGRectMake(0, 0, 20, 15)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    self.navigationItem.title = @"等待支付";
}


- (void)initTimer{
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requstFerryOrderCheckState) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantFuture]];
}

- (void)initScrollView{
    
    
}

- (void)setOwerInformation{
    if (_orderDetailModel) {
        
        if ([_orderDetailModel.driverName isKindOfClass:[NSString class]]) {
            _driverName.text = _orderDetailModel.driverName;
        }else{
            _driverName.text = @"未知";
        }
        
        _receiveOrderNumbers.text = [NSString stringWithFormat:@"接单数量:%d单",_orderDetailModel.driverOrderNum];


        _driverScores.text = [NSString stringWithFormat:@"%.1f分",_orderDetailModel.driverScore];

        
        if ( [_orderDetailModel.license isKindOfClass:[NSString class]]) {
            _CarNumber.text = _orderDetailModel.license;
        }else{
            _CarNumber.text = @"未知";
        }
        
        if ([_orderDetailModel.driverAvatar isKindOfClass:[NSString class]]) {
            [_driverAvatar setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,_orderDetailModel.driverAvatar]]];
        }else{
            [_driverAvatar setImage:[UIImage imageNamed:@"my_center_head_1"]];
        }
        
        [_payButton setTitle:[NSString stringWithFormat:@"确认支付%.2f元",[_orderDetailModel.price floatValue]/100.f] forState:0];
    }
}


#pragma mark - http requst
-(void)requstFerryOrderCheckState{
    
    NSString* orderId = @"";
    if (_orderDetailModel && _orderDetailModel.orderId) {
        orderId = _orderDetailModel.orderId;
    }else if(_orderId){
        orderId = _orderId;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
        params.data = @{@"orderId":orderId};
    }];
}


#pragma mark -- function methods



#pragma mark -- button event

- (IBAction)alipayBackgroudButtonClick:(id)sender {
    
    _alipayButton.selected = YES;
    _wechatButton.selected = NO;
    mode = PaymentChannel_ALI;
}

- (IBAction)wechatBackgroundButtonClick:(id)sender {
    
    _alipayButton.selected = NO;
    _wechatButton.selected = YES;
    mode = PaymentChannel_Weixin;
}

- (void)backButtonClick{

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

//呼叫司机
- (IBAction)callDriverButtonClick:(id)sender {
    
    if ([_orderDetailModel.driverPhone isKindOfClass:[NSString class]] && _orderDetailModel.driverPhone.length > 0) {
        UIWebView *callWebView = [[UIWebView alloc] init];
        
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _orderDetailModel.driverPhone]];
        
        [callWebView loadRequest:[NSURLRequest requestWithURL:telURL]];
        
        [self.view addSubview:callWebView];
    }else{
        [MBProgressHUD showTip:@"号码为空" WithType:FNTipTypeWarning];
    }

}

- (IBAction)couponButtonClick:(id)sender {
    
    // 跳转到优惠券界面
    CouponsViewController *couponsVC = [CouponsViewController instanceFromStoryboard];
    couponsVC.couponsParams = @{CouponTypeKey:@(CouponTypeSpecialCar), FNRequestCouponStateKey:@(CouponStateNormal), CouponLimitKey:@(0)};
    
    __weak TianFuCarPayVC *weakSelf = self;
    couponsVC.selectedCoupon = self.coupon;
    
    couponsVC.selectedCouponsCallback = ^(Coupon *coupon){
        
        weakSelf.coupon = coupon;
        
        weakSelf.currentCouponLabel.text = [NSString stringWithFormat:@"当前可抵用%ld元",(long)coupon.total/100];
        
        float tempPrice = ([_orderDetailModel.price floatValue] - coupon.total)/100.f;
        
        if (tempPrice < 0) {
            tempPrice = 0;
        }
        
        [weakSelf.payButton setTitle:[NSString stringWithFormat:@"确认支付%.2f元",tempPrice] forState:0];
    };
    
    [self.navigationController pushViewController:couponsVC animated:YES];
}

- (IBAction)alipayButtonClick:(id)sender {
    
//    _alipayButton.selected = !_alipayButton.selected;
//    _alipayButton.selected ?
//    [_alipayButton setBackgroundImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateNormal] :
//    [_alipayButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
//    
//    if (_wechatButton.selected) {
//        _alipayButton.selected = NO;
//        [_alipayButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
//    }
//    
//    if (_alipayButton.selected) {
//        mode = PaymentChannel_ALI;
//    }
    
    _alipayButton.selected = YES;
    _wechatButton.selected = NO;
    mode = PaymentChannel_ALI;

}


- (IBAction)wechatButtonClick:(id)sender {
    
//    _wechatButton.selected = !_wechatButton.selected;
//    
//    _wechatButton.selected ?
//    [_wechatButton setBackgroundImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateNormal] :
//    [_wechatButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
//    
//    if (_alipayButton.selected) {
//        _wechatButton.selected = NO;
//        [_wechatButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
//    }
//    
//    if (_wechatButton.selected) {
//        
//        mode = PaymentChannel_Weixin;
//    }
    
    _alipayButton.selected = NO;
    _wechatButton.selected = YES;
    mode = PaymentChannel_Weixin;
}

//arrow coupon
- (IBAction)arrowButtonClick:(id)sender {
    
  
}

//pay at once
- (IBAction)payButtonClick:(id)sender {
    
    NSMutableDictionary *params = [@{@"channel":[PingPPayUtil channelStringValue:mode],
                                     @"orderNo":_orderDetailModel.orderId,
                                     @"subject":@"FeiNiuBus",
                                     @"body":@"飞牛bus支付",
                                     @"chargeType":@2,
                                     @"orderType":@(FNUserPayOrderType_TianfuCarOrder)} mutableCopy];

    if (self.coupon && self.coupon.couponId) {
        [params setObject:self.coupon.couponId forKey:@"couponId"];
    }

    [self startWait];
    [PingPPayUtil payWithParams:params complete:^(NSDictionary *result) {
        
        [timer setFireDate:[NSDate distantPast]];

        NSString *code = result[@"code"];
        if (code && [code intValue] == 0) {
            
            float tempPrice = ([_orderDetailModel.price floatValue] - self.coupon.total)/100.f;
            
            if (tempPrice <= 0) {
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self stopWait];
            }else{
                [Pingpp createPayment:result[@"content"] viewController:self appURLScheme:@"FeiNiuBusUser" withCompletion:^(NSString *result, PingppError *error) {
                    NSLog(@"result=%@",result);
                }];
            }
            
        }else{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self stopWait];
            [self showTip:result[@"message"] WithType:FNTipTypeFailure hideDelay:3];
        }
    }];
}

#pragma mark -
- (void)handlePayNotification:(NSNotification *)notification{
    PingppError *error = notification.object[FNPayResultErrorKey];
    
    [self stopWait];

    if (error) {
        [self showTip:[error getMsg] WithType:FNTipTypeFailure hideDelay:2];
    }else{
        // 成功
        [self showTip:@"支付成功" WithType:FNTipTypeSuccess hideDelay:1.0];
        [self startWait];
    }
}


#pragma mark -- Receive APNS

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
//    //29.天府专车支付反馈（会员端）
    if ([userInfo[@"processType"] intValue] != 29) {
        return;
    }
    
    //state:  1，支付成功  2，支付失败
    if ([userInfo[@"state"] intValue] == 1) {
        [self pushCarEvaluationVC];
    }else{
        [self stopWait];
        [MBProgressHUD showTip:((NSDictionary*)userInfo[@"aps"])[@"alert"] WithType:FNTipTypeWarning];
    }
}



- (void)pushCarEvaluationVC{
    [timer invalidate];
    [self stopWait];

    TFCarEvaluationVC *tfcVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
    tfcVC.orderDetailModel = _orderDetailModel;
    tfcVC.isTianFuCar = YES;
    [self.navigationController pushViewController:tfcVC animated:YES];
}


-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == KRequestType_FerryOrderCheck) {
        if ([resultData.data[@"resultState"] intValue] == 1) { //订单是否提交成功 resultState=1成功 0 不成功
            
            if (!_orderDetailModel) {
                self.orderDetailModel = [[TFCarOrderDetailModel alloc] initWithDictionary:resultData.data[@"order"]];
                [self setOwerInformation];
            }
            
            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]);
            NSDictionary* orderDetail = resultData.data[@"order"];
            int payState = [orderDetail[@"payState"] intValue];
            if (payState == 3) {//已付款
                [self pushCarEvaluationVC];
            }
        }
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{

}

@end
