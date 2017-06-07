//
//  CarpoolPayViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolPayViewController.h"
#import "ConfirmOrderViewCell.h"
#import "CarpoolOrderItem.h"
#import "CharterOrderItem.h"
#import "UIColor+Hex.h"
#import "PingPPayUtil.h"
#import "CouponsViewController.h"
#import <FNNetInterface/PushConfiguration.h>
#import "LoginViewController.h"

@interface CarpoolPayViewController ()<UITableViewDataSource, UITableViewDelegate>{
    NSTimer *_checkPayStatusTimer;
    NSUInteger _repeatCount;
    BOOL    _isNoCoupon;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (nonatomic, strong) Coupon *coupon;
@end

@implementation CarpoolPayViewController

+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CarpoolPayViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付";
    [self updateUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePayNotification:) name:FNPayResultNotificationName object:nil];
    [self requestFirstCarpoolCoupon];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_checkPayStatusTimer invalidate];
    _checkPayStatusTimer = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Timer
- (void)startTimerWithDelay:(NSTimeInterval)delay{
    if (_checkPayStatusTimer) {
        [self stopTimer];
    }
    _repeatCount = 0;
    _checkPayStatusTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [self startWait];
    if (delay <= 0) {
        [_checkPayStatusTimer fire];
    }else{
        [_checkPayStatusTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    }
}
- (void)stopTimer{
    [self stopWait];
    [_checkPayStatusTimer invalidate];
    _checkPayStatusTimer = nil;
}
- (void)handleTimer:(NSTimer *)timer{
    if (_repeatCount > 3) {
//        [self showTip:@"支付超时" WithType:FNTipTypeFailure];
        [self stopTimer];
        return;
    }
    [self requestOrderDetail];
    _repeatCount ++;
}
#pragma mark - HTTP Request
- (void)requestFirstCarpoolCoupon{
    //NSString *url = [KServerAddr stringByAppendingString:@"coupons"];
    NSMutableDictionary *dict = [@{FNRequestCouponTypeKey:@(CouponTypeCarpool),
                                     FNRequestCouponStateKey:@(CouponStateNormal),
                                     FNRequestCouponLimitKey:@(0)} mutableCopy];

    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setObject:@(0) forKey:@"spik"];
    [dict setObject:@(20) forKey:@"rows"];
    
    [NetManagerInstance sendRequstWithType:FNUserRequestType_Coupons params:^(NetParams *params) {
        params.data = dict;
    }];
    
}
- (void)requestOrderDetail{
    if (!self.carpoolOrder || !self.carpoolOrder.orderId) {
        return;
    }
    
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId":self.carpoolOrder.orderId};
    }];
}
#pragma mark - Request Callback
- (void)httpRequestFinished:(NSNotification *)notification{
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_CarpoolOrderDetail) {
        self.carpoolOrder = [[CarpoolOrderItem alloc]initWithDictionary:resultData.data[@"data"]];
        if (self.carpoolOrder.payStatus == CarpoolOrderPayStatusPaid) {
            [self stopTimer];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (type == FNUserRequestType_Coupons){
        [self stopWait];
        NSArray *results = resultData.data[@"list"];
        if (results.count > 0) {
            Coupon *coupon = [[Coupon alloc]initWithDictionary:[results firstObject]];
            self.coupon = coupon;
            _isNoCoupon = NO;
        }else{
            _isNoCoupon = YES;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
    RequestType type = [notification.object[@"type"] integerValue];
    if (FNUserRequestType_CarpoolOrderCancel == type) {
        
    }
}

#pragma mark - Pay result
- (void)handlePayNotification:(NSNotification *)notification{
    PingppError *error = notification.object[FNPayResultErrorKey];
    if (error) {
        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
    }else{
//        [self showTip:@"支付成功" WithType:FNTipTypeSuccess];
//        [self stopTimer];
        [self startTimerWithDelay:2];
    }
}
#pragma mark - 
- (void)setCarpoolOrder:(CarpoolOrderItem *)carpoolOrder{
    _carpoolOrder = carpoolOrder;
    [self updateUI];
}
- (void)updateUI{
    NSString *price;
    NSMutableAttributedString *desc;
    // 拼车支付
    CGFloat currentPrice = (_carpoolOrder.price - self.coupon.total) / 100.0f;
    if (currentPrice < 0) {
        currentPrice = 0;
    }
    price = [NSString stringWithFormat:@"￥%.1f元", currentPrice];
    NSArray *tempPrice = [price componentsSeparatedByString:@"."];
    if ([[tempPrice lastObject] integerValue] == 0) {
        price = [[tempPrice firstObject] stringByAppendingString:@"元"];
    }
    desc = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@--%@  ", _carpoolOrder.startName, _carpoolOrder.destinationName]];
    [desc appendAttributedString:[[NSAttributedString alloc]initWithString:@(_carpoolOrder.tickets.count).stringValue attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:GloabalTintColor]}]];
    [desc appendAttributedString:[[NSAttributedString alloc]initWithString:@"张票"]];

    self.lblPrice.text = price;
    self.lblDesc.attributedText = desc;
    @try {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
#pragma mark - 
- (IBAction)actionPay:(UIButton *)sender {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (!selectedIndexPath) {
        [self showTip:@"请选择支付方式！" WithType:FNTipTypeWarning];
        return;
    }

    NSMutableDictionary *params = [@{
                             @"channel":[PingPPayUtil channelStringValue:selectedIndexPath.row],
                             @"orderNo":_carpoolOrder.orderId,
                             @"subject":[NSString stringWithFormat:@"%@-%@", _carpoolOrder.startName, _carpoolOrder.destinationName],
                             @"body":@"飞牛bus支付",
                             @"chargeType":@2,
                             @"orderType":@(FNUserPayOrderType_CarpoolOrder)} mutableCopy];
    if (self.coupon && self.coupon.couponId) {
        [params setObject:self.coupon.couponId forKey:@"couponId"];
    }
    [self startWait];
    [PingPPayUtil payWithParams:params complete:^(NSDictionary *result) {
        NSString *code = result[@"code"];
        if (code && [code intValue] == 0) {
            NSString *content = result[@"content"];
            if (!content || content.length <= 0) {
//                [self startWaitWithMessage:@"检查支付状态"];
                [self startTimerWithDelay:2];
            }else{
                [self stopWait];
                [Pingpp createPayment:result[@"content"] viewController:self appURLScheme:@"FeiNiuBusUser" withCompletion:^(NSString *result, PingppError *error) {
                    if (error) {
                        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
                    }else{
//                        [self showTip:result WithType:FNTipTypeSuccess];
                        [self startTimerWithDelay:2];
                    }
                }];
            }
        }else{
            if ([code intValue] == 100002) {
                [self showTip:@"请登录" WithType:FNTipTypeFailure];

                //鉴权失效重置token
                [[UserPreferences sharedInstance] setToken:nil];
                [[UserPreferences sharedInstance] setUserId:nil];
                
                // 进入登录界面
                [LoginViewController presentAtViewController:self needBack:YES requestToHomeIfCancel:NO completion:^{
                    
                } callBalck:^(BOOL isSuccess, BOOL needToHome) {
                    if (!isSuccess) {
                        
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
                    }
                }];
                
                //重置别名
                [[PushConfiguration sharedInstance] resetAlias];
            }else{
                [self showTip:result[@"message"] WithType:FNTipTypeFailure];
            }
            [self stopWait];
        }
    }];
    
}

- (void)setCoupon:(Coupon *)coupon{
    _coupon = coupon;
    [self updateUI];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - TableViewDelegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        PayInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayInfoCell"];
        cell.paymentType = (PaymentChannel)indexPath.row;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponToIdentifier"];
        // tag:101,title; tag:102, subtitle
        UILabel *lblDetail = (UILabel *)[cell.contentView viewWithTag:102];
        if (_isNoCoupon) {
            lblDetail.text = @"暂无可用优惠券";
            lblDetail.textColor = [UIColor colorWithHex:0xb4b4b4];
        }else{
            if (self.coupon) {
                lblDetail.text = [NSString stringWithFormat:@"当前已抵用%@元", @(self.coupon.total/100)];
            }else{
                lblDetail.text = @"有可用优惠券";
            }
            lblDetail.textColor = [UIColor colorWithHex:GloabalTintColor];
        }
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.height < 500 ? 35 : 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == 0 ? 15 : 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return indexPath;
    }else{
        // 跳转到优惠券界面
        CouponsViewController *couponsVC = [CouponsViewController instanceFromStoryboard];
        couponsVC.couponsParams = @{FNRequestCouponTypeKey:@(CouponTypeCarpool), FNRequestCouponStateKey:@(CouponStateNormal), FNRequestCouponLimitKey:@(0)};
        __weak CarpoolPayViewController *weakSelf = self;
        couponsVC.selectedCoupon = self.coupon;
        
        couponsVC.selectedCouponsCallback = ^(Coupon *coupon){
            weakSelf.coupon = coupon;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController pushViewController:couponsVC animated:YES];
    }
    return nil;
}

@end
