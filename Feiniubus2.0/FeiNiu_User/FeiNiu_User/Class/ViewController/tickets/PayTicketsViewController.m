//
//  PayTicketsViewController.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "PayTicketsViewController.h"
#import "CouponsViewController.h"
#import "ContainerViewController.h"
#import "MainViewController.h"
#import "TicketDetailViewController.h"
#import "OrderMainViewController.h"

#import "CreateOrderHeadView.h"
//#import "FeiNiu_User-Swift.h"

#import "PushNotificationAdapter.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, PayType) {
    PayTypeWXAli = 1,  //支付宝
    PayTypeWX = 13,  //微信
};

@interface PayTicketsViewController ()<UITableViewDelegate,UITableViewDataSource,UserCustomAlertViewDelegate>
{
    int payType;   //支付方式 0 代表支付宝 1代表微信
//    CouponObj *coupon; //优惠劵数据
    //提交支付是否处理信息记录
    NSMutableDictionary *payHeadInfor;
    
    BOOL bHasChargeNotify;
    BOOL bHasResultNotify;
    BOOL isToPayRequest;
}


@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) CreateOrderHeadView *headView;
@property (weak, nonatomic) IBOutlet UIButton *confirmPayButton;


@end

@implementation PayTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payChargeNotification:) name:FNPushType_BusTicketsPayCharge object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccessNotification:) name:FNPushType_BusTicketsSuccess object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)initUI
{
    //本页禁用滑动手势
    self.fd_interactivePopDisabled = YES;
    //tableView 头
    NSArray *headViewArray = [[NSBundle mainBundle] loadNibNamed:@"PayTicketsHeadView" owner:self options:nil];
    if (headViewArray.count >0) {
        _headView = headViewArray[0];
    }
    //
    [self setConfirmButtonText];
    //支付方式
    payType = PayTypeWXAli;
    //请求优惠卷
    [NetManagerInstance sendRequstWithType:EmRequestType_GetCoupons params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
//        params.data = @{@"type":@(CouponTypeBooking),
//                        @"state":@(CouponStateNormal),
//                        @"spik":@0,
//                        @"rows":@1,
//                        @"limit":@(_orderTicket.totalAmount),
//                        };
    }];
    //设置默认未去请求p++
    isToPayRequest  = NO;
}
//设置button显示的字
-(void)setConfirmButtonText
{
    //如果数据源都没有
    if (!_orderTicket) {
        [_confirmPayButton setTitle:[[NSString alloc] initWithFormat:@"确认支付%.2f元" ,0.f] forState:UIControlStateNormal];
        return;
    }
    //优惠卷
//    if (coupon) {
//        [_confirmPayButton setTitle:[[NSString alloc] initWithFormat:@"确认支付%.2f元" ,(_orderTicket.totalAmount - coupon.value)/100.f] forState:UIControlStateNormal];
//    }
//    else{
//        [_confirmPayButton setTitle:[[NSString alloc] initWithFormat:@"确认支付%.2f元" ,(_orderTicket.totalAmount)/100.f] forState:UIControlStateNormal];
//    }
    
}

- (IBAction)confirmPayButtonClick:(id)sender {
    //创建支付请求
    NSDictionary *createPayRequestDic ;
//    if (coupon) {
//        createPayRequestDic = @{@"orderId":_orderTicket.orderId,
//                                @"channel":@(payType),
//                                @"orderType":@5,     //客车订票
//                                @"couponId":coupon.id,
//                                @"body":[[NSString alloc] initWithFormat:@"%@到%@支付车票" ,_orderTicket.startCity ,_orderTicket.endCity],
//                                };
//    }
//    else{
//        createPayRequestDic = @{@"orderId":_orderTicket.orderId,
//                                @"channel":@(payType),
//                                @"orderType":@5,     //客车订票
//                                @"body":[[NSString alloc] initWithFormat:@"%@到%@支付车票" ,_orderTicket.startCity ,_orderTicket.endCity],
//                                };
//    }
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_PaymentCreate params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = createPayRequestDic;
    }];
}

-(void)gotoOrderDetailViewController
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.mainController.selectedIndex = 2;
    
    //显示客票订单列表
    UINavigationController *orderNav = app.mainController.selectedViewController;
    OrderMainViewController *orderMainController = [orderNav.viewControllers firstObject];
    [orderMainController setSelectIndex:1];
    
    TicketDetailViewController *detail = [TicketDetailViewController instanceWithStoryboardName:@"TicketsOrder"];
    detail.orderId = _orderTicket.orderId;
    
    [app.mainController.navigationController setViewControllers:@[app.mainController, detail] animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
//    TicketDetailViewController *detail = [TicketDetailViewController instanceWithStoryboardName:@"TicketsOrder"];
//    detail.orderId = _orderTicket.orderId;
//
//    
//    NSMutableArray *array =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    [array removeObjectAtIndex:array.count-1];
//    [array addObject:detail];
//    
//    [self.navigationController setViewControllers:array animated:YES];
}


-(void)navigationViewBackClick
{
    UserCustomAlertView *alertView =[UserCustomAlertView alertViewWithTitle:@"订单支付还未完成\n确认返回吗？" message:@"" delegate:self buttons:@[@"继续支付",@"取消支付"]];
    if ([alertView viewWithTag:1001]) {
        UILabel *titleLabel = [alertView viewWithTag:1001];
        titleLabel.numberOfLines = 0;
        [titleLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
        }];
    }
    
    
    [alertView showInView:self.view];
}
#pragma mark ---UserCustomAlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    switch (btnIndex) {
        case 1:
        {
            //[self gotoOrderDetailViewController];
            TicketDetailViewController *detail = [TicketDetailViewController instanceWithStoryboardName:@"TicketsOrder"];
            detail.orderId = _orderTicket.orderId;
            
            NSMutableArray *array =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//            [array removeObjectAtIndex:array.count-3];
            [array removeObjectsInRange:NSMakeRange(array.count - 2,2)];
            [array addObject:detail];
            [self.navigationController setViewControllers:array animated:YES];
            
        }
            break;
        case 0:
        {
            
        }
            break;
        default:
            break;
    }
}


#pragma mark - 推送处理
-(void)payChargeNotification:(NSNotification*)notification
{
    //后台推送过来
    if (!bHasChargeNotify) {
        bHasChargeNotify = YES;
        //推送提示下单失败
        if ([notification.object objectForKey:@"success"] && [[notification.userInfo objectForKey:@"success"] isEqualToNumber:[[NSNumber alloc] initWithInt:0]]) {
            [self stopWait];
            [self showTipsView:@"支付提交失败，请重试"];
        }
        else {
            //成功后请求获取凭证
            [self requestGetPayCharge];
        }
    }
}

- (void)paySuccessNotification:(NSNotification*)notification
{
    if (!bHasResultNotify) {
        bHasResultNotify = YES;
        
        int success = [[notification.object objectForKey:@"success"] intValue];
        if (success == 1) {
            //成功
            //跳转到订单详情
            [self showTip:@"支付成功" WithType:FNTipTypeSuccess hideDelay:2];
            [self gotoOrderDetailViewController];
            
        }
        else {
            [self showTipsView:@"支付提交失败，请重试"];
        }
    }
    
    [self stopWait];
}

//ping++返回处理
//-(void)payResultNotification:(NSNotification*)notification
//{
//    PingppError *error = notification.object[FNPayResultErrorKey];
//    if (error) {
//        // 失败
//        [self stopWait];
//        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
//        bHasResultNotify = YES;
//    }else{
//        // 成功
//        DBG_MSG(@"ping++支付成功");
//        [self startWait];
//        //20秒去取支付是否成功
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((WaitNotificationSecond-5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (!bHasResultNotify) {
//                bHasResultNotify = YES;
//                //吊起P++ 20秒后去请求结果
//                [self requestGetPayResult];
//            }
//            else
//            {
//                [self stopWait];
//            }
//        });
//    }
//}




#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"couponCell"];
    }
    else
    {
        cell =  [tableView dequeueReusableCellWithIdentifier:@"payCell"];
    }
    
    UIImageView *payIconImage = [cell viewWithTag:101];
    UILabel *payNameLabel = [cell viewWithTag:102];
    UIImageView *paySelectImage = [cell viewWithTag:103];
    UILabel *payCouponLabel = [cell viewWithTag:104];
    
    UIView *lineView = [cell viewWithTag:106];
    lineView.backgroundColor = UIColorFromRGB(0xD0D0D0);
    
    switch (indexPath.row) {
        case 0:
        {
            payIconImage.image = [UIImage imageNamed:@"pay_icon_alipay"];
            payNameLabel.text = @"支付宝支付";
            if (payType == PayTypeWXAli) {
                paySelectImage.image = [UIImage imageNamed:@"checkbox_check"];
            }
            else{
                paySelectImage.image = [UIImage imageNamed:@"checkbox"];
            }
        }
            break;
        case 1:
        {
            payIconImage.image = [UIImage imageNamed:@"pay_icon_wechat"];
            payNameLabel.text = @"微信支付";
            if (payType == PayTypeWX) {
                paySelectImage.image = [UIImage imageNamed:@"checkbox_check"];
            }
            else{
                paySelectImage.image = [UIImage imageNamed:@"checkbox"];
            }
        }
            break;
        case 2:
        {
            payIconImage.image = [UIImage imageNamed:@"coupons_2"];
            payNameLabel.text = @"优惠劵抵扣";
//            if (coupon) {
//                payCouponLabel.text = [[NSString alloc] initWithFormat:@"-%.2f元",coupon.value/100.f];
//            }
//            else
//            {
//                payCouponLabel.text = [[NSString alloc] initWithFormat:@"无可用优惠劵"];
//            }
            lineView.backgroundColor = [UIColor clearColor];
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 185;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [_headView setOrderInfo:_orderTicket];
    _headView.priceLabel.text = [[NSString alloc] initWithFormat:@"%d张共%.2f元",_orderTicket.peopleNumber,_orderTicket.totalAmount/100.f];
    _headView.typeLabel.text = _orderTicket.type == 3? @"滚动发班" : @"";   //2定时，3滚动
    if (_orderTicket.type == 3) {
        _headView.timeLabel.text = [[NSString alloc] initWithFormat:@"%@前有效",_orderTicket.time];
    }
    else{
        _headView.typeLabel.text = [[NSString alloc] initWithFormat:@"%@",_orderTicket.time];
        _headView.timeLabel.text = @"";
    }
    //日期
    NSDate *tickDatte = [DateUtils stringToDate:_orderTicket.date];
    _headView.dateLabel.text = [[NSString alloc] initWithFormat:@"%@（%@）",[DateUtils formatDate:tickDatte format:@"yyyy-MM-dd"],[DateUtils weekFromDate:tickDatte]];
    return _headView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            payType = PayTypeWXAli;
            break;
        case 1:
            payType = PayTypeWX;
            break;
        case 2:
        {
            //跳转到优惠劵页面
//            CouponsViewController *couponsViewController = [CouponsViewController instanceFromStoryboard];
//            couponsViewController.couponsParams = @{FNRequestCouponTypeKey:@(CouponTypeBooking),
//                                                    FNRequestCouponStateKey:@(CouponStateNormal),
//                                                    FNRequestCouponLimitKey:@(_orderTicket.totalAmount),
//                                                    };
//            couponsViewController.selectedCoupon = coupon;
//            couponsViewController.selectedCouponsCallback = ^(CouponObj *selectCoupon){
//                coupon = selectCoupon;
//                [self setConfirmButtonText];
//                [self.mainTableView reloadData];
//            };
//            [self.navigationController pushViewController:couponsViewController animated:YES];
        }
            break;
        
        default:
            break;
    }
    [self.mainTableView reloadData];
}

#pragma mark -

- (void)requestGetPayCharge
{
    [NetManagerInstance sendRequstWithType:EmRequestType_PaymentCharge params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{
                        @"orderId":_orderTicket.orderId,
                        @"orderType":@(5),   //此页面全是客车订票类型
                        };
    }];
}

- (void)requestGetPayResult
{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_PaymentResult params:^(NetParams *params) {
        params.data = @{
                        @"orderId":_orderTicket.orderId,
                        @"orderType":@(5),   //此页面全是客车订票类型
                        };
    }];
}

-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    switch (resultData.type) {
        case EmRequestType_GetCoupons:
        {
            if ([resultData.data isKindOfClass:[NSArray class]] && ((NSArray*)resultData.data).count > 0) {
//                coupon = [CouponObj mj_objectWithKeyValues:(NSArray*)resultData.data[0]];
                [self setConfirmButtonText];
                [self.mainTableView reloadData];
            }
        }
            break;
        case EmRequestType_PaymentCreate:
        {
            bHasChargeNotify = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!bHasChargeNotify) {
                    bHasChargeNotify = YES;
                    //成功后请求获取凭证
                    [self requestGetPayCharge];
                }
            });
            
        }
            break;
        case EmRequestType_PaymentCharge:
        {
            if ([resultData.data objectForKey:@"state"] &&
                [[resultData.data objectForKey:@"state"] isEqual:[[NSNumber alloc] initWithInt:1]]) {
                
                bHasResultNotify = NO;
                NSString *payCharge = [resultData.data objectForKey:@"charge"] ? [resultData.data objectForKey:@"charge"] : nil;
                [self stopWait];  //跳转P++支付请求的时候清除加载等待
                isToPayRequest = YES;//标记发送给p++支付请求
//                [Pingpp createPayment:payCharge appURLScheme:@"FeiNiuBusUserPay" withCompletion:^(NSString *result, PingppError *error) {
//                    if (error) {
//                        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
//                    }
//                    else {
//                        
//                    }
//                }];
            }
            else{
                [self stopWait];
                [self showTipsView:@"支付调起失败，请重新支付"];
            }
        }
            break;
        case EmRequestType_PaymentResult:
        {
            [self stopWait];
            int state = [[resultData.data objectForKey:@"state"] intValue];
            if (state == 1) {
                //跳转到订单详情
                DBG_MSG(@"支付成功!");
                [self showTip:@"支付成功" WithType:FNTipTypeSuccess hideDelay:2];
                [self gotoOrderDetailViewController];
            }
            else {
                [self showTipsView:@"支付失败，请重新支付"];
            }
        }
            break;
        default:
            break;
    }
    
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
}

#pragma mark -- 
-(void)onApplicationBecomeActive
{
    [super onApplicationBecomeActive];
//    if (isToPayRequest && !bHasResultNotify) {
//        //手动点击回到应用程序模拟一次通知执行
//        [[NSNotificationCenter defaultCenter] postNotificationName:FNPayResultNotificationName object:nil];
//        
//    }
}
@end
