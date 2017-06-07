//
//  PaymentViewController.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "PayCarViewController.h"

#import "CallCarStateViewController.h"
#import "ContainerViewController.h"
#import "OrderMainViewController.h"
#import "MainViewController.h"
#import "CouponsViewController.h"

#import "PushNotificationAdapter.h"
//#import "FeiNiu_User-Swift.h"
//#import "PingPPayUtil.h"

#define TimerName @"orderOverTime"
#define Dedicated 4     //接送机 4  订票5
typedef NS_ENUM(NSInteger, PayType) {
    PayTypeAli = 1,  //支付宝
    PayTypeWX = 13,  //微信
};

@interface PayCarViewController ()<UserCustomAlertViewDelegate>
{
    //支付倒计时
    __weak IBOutlet UILabel *payTimerLab;
    //总里程
    __weak IBOutlet UILabel *mileageLab;
    //里程总价
    __weak IBOutlet UILabel *mileagePriceLab;
    //人数
    __weak IBOutlet UILabel *peopleCountLab;
    //总费用
    __weak IBOutlet UILabel *totalPriceLab;
    //过路费
    __weak IBOutlet UILabel *tolls;
    //优惠券lab
    __weak IBOutlet UILabel *couponsLab;
    
    //底部View  是否显示过路费
    __weak IBOutlet NSLayoutConstraint *endViewConstraint;
    __weak IBOutlet NSLayoutConstraint *payInfoHeightConstraint;
    
 //-----------------------------------------------------
    //tableView--view
    __weak IBOutlet UIView *mainView;
    //过路费View
    __weak IBOutlet UIView *tollsView;
    
    __weak IBOutlet UIButton *alipayButton;
    __weak IBOutlet UIButton *wechatButton;
    //支付按钮
    __weak IBOutlet UIButton *payButton;
    
    
    UIView *maskView;               //遮罩View
    int payMode;                    //支付类型
    NSTimer *timer;                 //定时器
    int defaultPayTime;             //剩余支付时间
    BOOL paySuccessIdentfier;       //支付成功标志；
    BOOL creatPayIdentfier;         //创建支付请求标志；
    
    BOOL isPushCoupon;                //是否push优惠券
    
    BOOL isToPayRequest;            //是否调起ping++支付
    
//    CouponObj *coupon; //优惠劵对象
}
@end

@implementation PayCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_interactivePopDisabled = YES;
    
    //默认5分钟
    defaultPayTime = 300;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
        defaultPayTime = defaultPayTime - 1;
        if (defaultPayTime == 0) {
            [timer invalidate];
            [self popViewController];
        }
        payTimerLab.text = [NSString stringWithFormat:@"支付倒计时  %@",[DateUtils timeFormatted:defaultPayTime]];
    } repeats:YES];
    [timer fire];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatPaymentNotification:) name:FnPushType_CallCarPayCharge object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatPaySuccessNotification:) name:FnPushType_CallCarPaySuccess object:nil];
    
    
    //添加遮罩View
    maskView = [UIView new];
    maskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.equalTo(0);
        make.bottom.equalTo(0);
        make.right.equalTo(0);
    }];
    [self startWait];
    
    
    //查询订单信息
    [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedOrder params:^(NetParams *params) {
        params.data = @{@"orderId":_shuttleModel.orderId};
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isPushCoupon = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (isPushCoupon) {
        return;
    }
    [timer invalidate];
}

//优惠券接口---订单信息接口
- (void)configUserInfo
{
    //配置数据
    [self hiddenTollsView:YES];
    //默认选中支付宝支付
    [self alipayBackgroudButtonClick:alipayButton];
    
    mileageLab.text      = [NSString stringWithFormat:@"单人里程费(%.2f公里)",[_shuttleModel.mileage intValue]/1000.0];
    mileagePriceLab.text = [NSString stringWithFormat:@"%.2f元",[_shuttleModel.unitPrice intValue]/100.0];
    peopleCountLab.text  = [NSString stringWithFormat:@"%@人",_shuttleModel.peopleNumber];
    totalPriceLab.text   = [NSString stringWithFormat:@"%.2f",[_shuttleModel.amount intValue]/100.0];
    
    [self updateRealPayMonth];
}

//更新实付金额
- (void)updateRealPayMonth
{
    double money = 0;
    if ([_shuttleModel.amount intValue] <= _shuttleModel.coupon) {
        money = 0.01;
    }else{
        money = [_shuttleModel.amount intValue]/100.0 - _shuttleModel.coupon/100.0;
    }
    NSString *totalPrice;
    if (money <= 0) {
        totalPrice = [NSString stringWithFormat:@"确认支付0.00元"];
    }else{
        totalPrice = [NSString stringWithFormat:@"确认支付%.2f元",money];
    }
    [payButton setTitle:totalPrice forState:UIControlStateNormal];
}

//更新抵扣价格
- (void)updateDeductionMoney
{
//    double realCoupon = 0;
//    if ([_shuttleModel.amount intValue] <= coupon.value) {
//        realCoupon = [_shuttleModel.amount doubleValue]/100.0 - 0.01;
//    }else{
//        realCoupon = coupon.value/100.0;
//    }
//    couponsLab.text = [NSString stringWithFormat:@"-%.2f元",realCoupon];
//    _shuttleModel.couponID = coupon.id;
//    _shuttleModel.coupon = coupon.value;    
}

//是否显示过路费
- (void)hiddenTollsView:(BOOL) boolen
{
    tollsView.hidden = boolen;
//    if (boolen) {
//        endViewConstraint.constant = 0;
//        payInfoHeightConstraint.constant = 155;
//        mainView.fs_height = 480;
//    }else{
//        endViewConstraint.constant = 45;
//        payInfoHeightConstraint.constant = 200;
//        mainView.fs_height = 550;
//    }
}

#pragma marks actions

- (IBAction)btnBack:(id)sender {
    UserCustomAlertView *alertView =[UserCustomAlertView alertViewWithTitle:@"订单还未支付，确认返回吗？" message:@"" delegate:self buttons:@[@"继续支付",@"返回"]];
    if ([alertView viewWithTag:1001]) {
        UILabel *titleLabel = [alertView viewWithTag:1001];
        [titleLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
        }];
    }
    [alertView showInView:self.view];
}

- (IBAction)alipayBackgroudButtonClick:(id)sender {
    
    alipayButton.selected = YES;
    wechatButton.selected = NO;
    payMode = PayTypeAli;
}

- (IBAction)wechatBackgroundButtonClick:(id)sender {
    
    alipayButton.selected = NO;
    wechatButton.selected = YES;
    payMode = PayTypeWX;
}

//优惠券
- (IBAction)clickCounpAction:(UIButton *)sender
{
//    CouponsViewController *couponsController = [CouponsViewController instanceWithStoryboardName:@"Me"];
////    couponsController.couponsParams = @{FNRequestCouponTypeKey:@(CouponTypeDedicated),
////                                        FNRequestCouponStateKey:@(CouponStateNormal),
////                                        FNRequestCouponLimitKey:_shuttleModel.amount};
//    couponsController.selectedCoupon = coupon;
//    
//    couponsController.selectedCouponsCallback = ^(CouponObj *_coupon){
//        coupon = _coupon;
//        //更新抵扣价格
//        [self updateDeductionMoney];
//        //计算优惠后价格
//        [self updateRealPayMonth];
//    };
//    [self.navigationController pushViewController:couponsController animated:YES];
//    
//    isPushCoupon = YES;
}

- (IBAction)payButtonClick:(id)sender {
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_PaymentCreate params:^(NetParams *params) {
        
        NSMutableDictionary *datas = [@{@"orderId":_shuttleModel.orderId,
                                       @"channel":@(payMode),
                                       @"orderType":@(Dedicated)} mutableCopy];
        //是否有优惠券
        if (_shuttleModel.couponID && _shuttleModel.couponID.length > 0) {
            [datas setObject:_shuttleModel.couponID forKey:@"couponId"];
        }
        
        params.method = EMRequstMethod_POST;
        params.data = datas;
    }];
}

-(void)gotoCallCarStateViewController
{
//    ContainerViewController *container = (ContainerViewController *)[[UIApplication sharedApplication].keyWindow.rootViewController presentedViewController];
//    UINavigationController *nav = (UINavigationController *)container.contentViewController;
//    MainViewController *rootVC = [nav.viewControllers firstObject];
//    rootVC.selectedIndex = 2;
//    
//    //显示飞牛行程订单列表
//    UINavigationController *orderNav = rootVC.selectedViewController;
//    OrderMainViewController *orderMainController = [orderNav.viewControllers firstObject];
//    [orderMainController setSelectIndex:0];
//    orderMainController.feiniuController.needRefresh = YES;
//    
//    CallCarStateViewController *controller = [CallCarStateViewController instanceWithStoryboardName:@"Bus"];
//    controller.orderID = [_shuttleModel.orderId stringValue];
//    
//    [nav setViewControllers:@[rootVC, controller] animated:YES];
//    
//    [self.navigationController popToRootViewControllerAnimated:NO];
    
    CallCarStateViewController *detail = [CallCarStateViewController instanceWithStoryboardName:@"Bus"];
    detail.orderID = [_shuttleModel.orderId stringValue];
    
    NSMutableArray *array =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array removeObjectAtIndex:array.count-1];
    [array addObject:detail];
    
    [self.navigationController setViewControllers:array animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
}


#pragma mark -
//获取支付信息
- (void)requestGetPayCharge
{
    [NetManagerInstance sendRequstWithType:EmRequestType_PaymentCharge params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{
                        @"orderId":_shuttleModel.orderId,
                        @"orderType":@(Dedicated),   //此页面全是接送机订票类型
                        };
    }];
}
//获取订单支付状态  state 0 or 1
- (void)requestGetPayResult
{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_PaymentResult params:^(NetParams *params) {
        params.data = @{
                        @"orderId":_shuttleModel.orderId,
                        @"orderType":@(Dedicated),   //此页面全是接送机订票类型
                        };
    }];
}
//请求优惠卷
- (void)requestGetCoupons
{
//    [NetManagerInstance sendRequstWithType:EmRequestType_GetCoupons params:^(NetParams *params) {
//        params.method = EMRequstMethod_GET;
//        params.data = @{FNRequestCouponTypeKey:@(CouponTypeDedicated),
//                        FNRequestCouponStateKey:@(CouponStateNormal),
//                        FNRequestCouponLimitKey:_shuttleModel.amount};
//    }];
}

#pragma mark - httpresponse
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = [notification object];
    if (resultData.type == EmRequestType_PaymentCreate) {       //创建支付请求
        
        creatPayIdentfier = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!creatPayIdentfier) {
                //成功后请求获取凭证
                creatPayIdentfier = YES;
                [self requestGetPayCharge];
            }
        });
        
    }else if (resultData.type == EmRequestType_PaymentCharge){  //获取支付凭证
    
        [self stopWait];
        if ([resultData.data[@"state"] intValue] == 2) {    //支付完成或者不需要支付
            
            [self gotoCallCarStateViewController];
            
        }else{
            [self pingPayMentWithCharge:resultData.data[@"charge"]];//调用ping++支付
        }
        
    }else if (resultData.type == EmRequestType_GetDedicatedOrder){  //获取订单信息
    
        _shuttleModel = [ShuttleModel mj_objectWithKeyValues:resultData.data[@"order"]];
        [self configUserInfo];
        //获取优惠券
        [self requestGetCoupons];
        
        
        [self stopWait];
        [maskView removeFromSuperview];
    }else if (resultData.type == EmRequestType_PaymentResult){      //最终支付结果
        
        NSInteger state = [resultData.data[@"state"] integerValue];
        if (state == 1) {
            //跳转到呼车页
            [self showTip:@"支付成功" WithType:FNTipTypeSuccess hideDelay:2];
            [self gotoCallCarStateViewController];
            //[self performSegueWithIdentifier:@"CallCarStateViewController" sender:[_shuttleModel.orderId stringValue]];
        }
        else {
            [self showTipsView:@"支付失败，请重试"];
        }
        [self stopWait];
    }else if (resultData.type == EmRequestType_GetCoupons){
        //给一个默认优惠券
        if ([resultData.data isKindOfClass:[NSArray class]] && ((NSArray*)resultData.data).count > 0) {
//            coupon = [CouponObj mj_objectWithKeyValues:(NSArray*)resultData.data[0]];
            
            //更新抵扣价格
            [self updateDeductionMoney];
            [self updateRealPayMonth];
            [self configUserInfo];
        }else{
            couponsLab.text = @"无可用优惠券";
        }
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

//调用ping++
- (void)pingPayMentWithCharge:(NSString *) charge
{
    if (charge && charge.length > 0) {
        isToPayRequest = YES;
//        [Pingpp createPayment:charge appURLScheme:@"FeiNiuBusUserPay" withCompletion:^(NSString *result, PingppError *error) {
//            if (error) {
//                //[self showTipsView:[[NSString alloc] initWithFormat:@"%@" ,result]];
//                [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
//            }
//        }];
    }else{
        [self stopWait];
        [self showTipsView:@"支付调起失败，请重新支付"];
    }
}


#pragma mark 通知
//提交支付
- (void)creatPaymentNotification:(NSNotification *)nofitication
{
    if (!creatPayIdentfier) {
        creatPayIdentfier = YES;
        if ([nofitication.object[@"success"] integerValue] == 0) {
            
            [self stopWait];
            [self showTipsView:@"支付提交失败，请重试"];
            return;
        }{
            [self stopWait];
            [self requestGetPayCharge];
        }
    }
    
}

//支付成功通知
- (void)creatPaySuccessNotification:(NSNotification *)notification
{
    if (!paySuccessIdentfier) {
        paySuccessIdentfier = YES;
        
        int success = [[notification.object objectForKey:@"success"] intValue];
        if (success == 1) {
            //跳转到呼车页

            if ([[self.shuttleModel.orderId stringValue] isEqualToString:[notification.object objectForKey:@"orderId"]]) {
                //检查是否当前订单
                [self showTip:@"支付成功" WithType:FNTipTypeSuccess hideDelay:2];
                [self gotoCallCarStateViewController];
            }
        }
        else {
            [self showTipsView:@"支付提交失败，请重试"];
        }
    }
    
    [self stopWait];
}

//ping++ 支付结果
//- (void)payResultNotification:(NSNotification *)notifacation
//{
//   
//    PingppError *error = notifacation.object[FNPayResultErrorKey];
//    if (error) {
//        // 失败
//        paySuccessIdentfier = YES;
//        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
//        
//        [self stopWait];
//    }else{
//        // 成功   去服务器取是否成功，  以服务器为准
//        DBG_MSG(@"ping++支付成功");
//        [self startWait];
//        //如果支付成功 未收到服务器成功推送  手动去服务端拿支付状态
////        paySuccessIdentfier = NO;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond+5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (!paySuccessIdentfier) {
//                paySuccessIdentfier = YES;
//                [self requestGetPayResult];
//            }
//        });
//    }
//}

#pragma mark --
-(void)onApplicationBecomeActive
{
    [super onApplicationBecomeActive];
    if (isToPayRequest && !paySuccessIdentfier) {
        //手动点击回到应用程序模拟一次通知执行
       // [[NSNotificationCenter defaultCenter] postNotificationName:FNPayResultNotificationName object:nil];
        
    }
}



#pragma mark customAlertView delegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    if (btnIndex != 1 ) {
        return;
    }
    [self popViewController];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//// Get the new view controller using [segue destinationViewController].
//// Pass the selected object to the new view controller.
////
//    if ([[segue identifier] isEqualToString:@"CallCarStateViewController"]) {
//        CallCarStateViewController *stateController = [segue destinationViewController];
//        stateController.orderID = sender;
//    }
//}

- (void)dealloc
{
    [timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
