//
//  ComfirmOrderViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/31.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CharterPayViewController.h"
#import "ConfirmOrderViewCell.h"
#import "Coupon.h"
#import "CouponsViewController.h"
#import "UnionPayViewController.h"
#import "UIColor+Hex.h"

@interface CharterPayViewController ()<UITableViewDataSource, UITableViewDelegate>{
    BOOL    _isVIP;
    NSInteger   _depositPrice;  // 定金价
}
@property (nonatomic, strong) Coupon *coupon;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;

@end


@implementation CharterPayViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyboad instantiateViewControllerWithIdentifier:@"CharterPayViewController"];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _lblAmount.text = [NSString stringWithFormat:@"￥%@", @(self.suborderItem.price / 100.0f)];
    self.title = @"订单支付";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePayNotification:) name:FNPayResultNotificationName object:nil];
    [self requestVIPPirce];
    @try {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [self requestFirstCharterCoupon];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)initUI
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setCoupon:(Coupon *)coupon{
    _coupon = coupon;
    self.lblAmount.text = [NSString stringWithFormat:@"￥%.1f", [self price]];
    @try {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
- (CGFloat)price{
    CGFloat p = self.suborderItem.price - self.coupon.total;
    if (p <= 0) {
        p = 0;
    }
    return p / 100.0f;

}
#pragma mark - Request Methods
- (void)requestFirstCharterCoupon{
    NSMutableDictionary *dict = [@{FNRequestCouponTypeKey:@(CouponTypeCharter),
                                   FNRequestCouponStateKey:@(CouponStateNormal),
                                   FNRequestCouponLimitKey:@(0)} mutableCopy];
    
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setObject:@(0) forKey:@"spik"];
    [dict setObject:@(1) forKey:@"rows"];

    [NetManagerInstance sendRequstWithType:FNUserRequestType_Coupons params:^(NetParams *params) {
        params.data = dict;
    }];
}
- (void)requestVIPPirce{
    if (!self.suborderItem || !self.suborderItem.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_GetVIPPrice params:^(NetParams *params) {
        params.data = @{@"subOrderId":self.suborderItem.subOrderId};
    }];
}

- (void)requestSuborderDetail{
    if (!self.suborderItem || !self.suborderItem.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterSubOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId":self.suborderItem.subOrderId};
    }];
}

- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    NSDictionary *data = resultData.data;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_CharterSubOrderDetail) {
        if (resultData.resultCode == 0) {
            [self showTip:@"支付成功" WithType:FNTipTypeSuccess];
        }else{
            [self showTip:resultData.message WithType:FNTipTypeFailure];
        }
    }else if (type == FNUserRequestType_GetVIPPrice){
        _isVIP = [data[@"isVip"] boolValue];
        _depositPrice = [data[@"depositPrice"] integerValue];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }else if (type == FNUserRequestType_Coupons){
        NSArray *results = resultData.data[@"list"];
        if (results.count > 0) {
            Coupon *coupon = [[Coupon alloc]initWithDictionary:[results firstObject]];
            self.coupon = coupon;
        }
    }
    
}
#pragma mark - 
- (void)handlePayNotification:(NSNotification *)notification{
    PingppError *error = notification.object[FNPayResultErrorKey];
//    [self stopWait];
    if (error) {
        // 失败
        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
    }else{
        // 成功
        [self showTip:@"支付成功" WithType:FNTipTypeSuccess hideDelay:1.0];
        [self performSelector:@selector(popToCharterdTravelingVC) withObject:nil afterDelay:1];
//        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:1];
    }
}
- (void)popToCharterdTravelingVC{
    __block UIViewController *vc;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"CharteredTravelingViewController")]) {
            vc = obj;
            *stop = YES;
        }
    }];
    if (vc) {
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark - Actions
- (IBAction)actionPay:(UIButton *)sender {
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    PayInfoCell *paymentCell;
    NSInteger chargeType = 2;

    for (NSIndexPath *aIndexPath in selectedIndexPaths) {
        if (aIndexPath.section == 1) {
            paymentCell = [self.tableView cellForRowAtIndexPath:aIndexPath];
        }else if (aIndexPath.section == 2){
            chargeType = 1;
        }
    }
    if (!paymentCell) {
        [self showTip:@"请选择支付方式！" WithType:FNTipTypeWarning];
        return;
    }
    if (paymentCell.paymentType == PaymentChannel_UPMP) {
        // 企业对公转账， 银联支付
        [self performSegueWithIdentifier:@"ToDuigong" sender:@(chargeType)];
        return;
    }
    NSMutableDictionary *params = [@{@"amount":[NSString stringWithFormat:@"%.1f", [self price]],
                             @"channel":[PingPPayUtil channelStringValue:paymentCell.paymentType],
                             @"orderNo":self.suborderItem.subOrderId,
                             @"subject":@"飞牛BUS",
                             @"body":@"sss",
                             @"chargeType":@(chargeType),
                             @"orderType":@(FNUserPayOrderType_CharterOrder)} mutableCopy];
    if (self.coupon && self.coupon.couponId) {
        [params setObject:self.coupon.couponId forKey:@"couponId"];
    }
    [self startWait];
    [PingPPayUtil payWithParams:params complete:^(NSDictionary *result) {
        [self stopWait];
        NSString *code = result[@"code"];
        if (code && [code intValue] == 0) {
            NSString *content = result[@"content"];
            if (!content || content.length <= 0) {
//                [self startWaitWithMessage:@"检查支付状态"];
//                [self startWait];
                [self performSelector:@selector(popToCharterdTravelingVC) withObject:nil afterDelay:1];
            }else{
                [Pingpp createPayment:result[@"content"] viewController:self appURLScheme:@"FeiNiuBusUser" withCompletion:^(NSString *result, PingppError *error) {
                    if (error) {
                        [self showTip:[PingPPayUtil errorMessage:error] WithType:FNTipTypeFailure];
                    }else{
                        [self showTip:result WithType:FNTipTypeSuccess];
                        [self performSelector:@selector(popToCharterdTravelingVC) withObject:nil afterDelay:1];
                    }
                }];
            }
            
        }else{
            [self showTip:result[@"message"] WithType:FNTipTypeFailure];
        }
    }];
}
#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ToDuigong"]) {
        ((UnionPayViewController *)segue.destinationViewController).orderId = self.suborderItem.subOrderId;
        ((UnionPayViewController *)segue.destinationViewController).couponId = self.coupon.couponId;
        ((UnionPayViewController *)segue.destinationViewController).payOrderType = FNUserPayOrderType_CharterOrder;
        ((UnionPayViewController *)segue.destinationViewController).chargeType = [sender integerValue];
    }
}
#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return (self.suborderItem.route.count + 4) * [ConfirmOrderViewCell heightForRow];
    }
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // 订单信息
        return 1;
    }
    else if (section == 1) {
        return 3;
    }
    else if (section == 2) {
        return 1;
    }else if (section == 3){
        return 1;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:[ConfirmOrderViewCell identifier]];
        ((ConfirmOrderViewCell *)cell).suborder = self.suborderItem;
    }
    else if (indexPath.section == 1){
        
        cell = [tableView dequeueReusableCellWithIdentifier:[PayInfoCell identifier]];
        ((PayInfoCell *)cell).paymentType = (PaymentChannel)indexPath.row;
    }
    else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:[PayInfoCell identifier]];
        ((PayInfoCell *)cell).paymentType = (PaymentChannel)(PaymentChannel_EarnestFeiniu + indexPath.row);
        if (!_isVIP) {
            cell.contentView.alpha = 0.5;
            ((PayInfoCell *)cell).lblDetail.textColor = [UIColor colorWithHex:DarkTintColor];
            ((PayInfoCell *)cell).ivIcon.tintColor = [UIColor colorWithHex:0x333333];
        }else{
            cell.contentView.alpha = 1;
            ((PayInfoCell *)cell).ivIcon.tintColor = [UIColor colorWithHex:GloabalTintColor];
            ((PayInfoCell *)cell).lblDetail.textColor = [UIColor colorWithHex:GloabalTintColor];

        }
    }else{
        // section = 3
        cell = [tableView dequeueReusableCellWithIdentifier:@"CouponToIdentifier"];
        // tag:101,title; tag:102, subtitle
        UILabel *lblDetail = (UILabel *)[cell.contentView viewWithTag:102];
        lblDetail.text = [NSString stringWithFormat:@"当前已抵用%@元", @(self.coupon.total/100)];
    }
    
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return nil;
    }else if (indexPath.section == 1){
        NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
        for (NSIndexPath *aIndexPath in selectedIndexPaths) {
            if (aIndexPath.section == indexPath.section) {
                [tableView deselectRowAtIndexPath:aIndexPath animated:NO];
            }
        }
        return indexPath;
    }else if (indexPath.section == 2){
        if (_isVIP) {
            return indexPath;
        }else{
            [self showTip:@"不是合作商家不可选择定金支付" WithType:FNTipTypeWarning];
            return nil;
        }
    }else{
        // 跳转到优惠券界面
        CouponsViewController *couponsVC = [CouponsViewController instanceFromStoryboard];
        couponsVC.couponsParams = @{FNRequestCouponTypeKey:@(CouponTypeCharter), FNRequestCouponStateKey:@(CouponStateNormal), FNRequestCouponLimitKey:@(0)};
        __weak CharterPayViewController *weakSelf = self;
        couponsVC.selectedCoupon = self.coupon;
        couponsVC.selectedCouponsCallback = ^(Coupon *coupon){
            weakSelf.coupon = coupon;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController pushViewController:couponsVC animated:YES];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}
@end
