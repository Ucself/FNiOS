//
//  CarpoolTravelingViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolTravelingViewController.h"
#import "UserCustomAlertView.h"
#import "CarpoolTravelStatusProgressView.h"
#import "CarpoolTravelStateViewController.h"
#import "CarpoolOrderItem.h"
#import "PushNotificationAdapter.h"
#import "CarpoolRefundConfirmViewController.h"
#import "TravelHistoryViewController.h"

#define TagDetailContent    0x201

#define TagAlertWithoutRefund 0x202
#define TagAlertWithRefund 0x203

@interface CarpoolTravelingViewController ()<UserCustomAlertViewDelegate>{
    NSTimer     *_checkTimer;
    NSInteger   _retriedCount;
}
@property (weak, nonatomic) IBOutlet CarpoolTravelStatusProgressView *statusProgressView;
@property (weak, nonatomic) IBOutlet UIView *detailView;

@end
@implementation CarpoolTravelingViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:@"CarpoolTravelingViewController"];
}
//18081263639
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"订单详情";

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"取消订单" style:UIBarButtonItemStylePlain target:self action:@selector(actionBarItemCancel:)];
    [cancelItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
//    [self setState:OrderStateWaitingForPay];
//    [self requestCarpoolPrice];
    [self updateState];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 只有已支付的行程中和行程结束的订单不查询, 其他状态订单需要查询。
    if (self.carpoolOrder.payStatus != CarpoolOrderPayStatusPaid ||
        (self.carpoolOrder.orderStatus != CarpoolOrderStatusTravelEnd &&
        self.carpoolOrder.orderStatus != CarpoolOrderStatusTravelling)) {
        [self startCheckTimerWithDelay:1];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_checkTimer invalidate];
    _checkTimer = nil;
}
#pragma mark - Timer
- (void)startCheckTimerWithDelay:(NSTimeInterval)delay{
    if (_checkTimer) {
        [self stopCheckTimer];
    }
    _retriedCount = -1;
    [self startWait];
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleCheckTimer:) userInfo:nil repeats:YES];
    if (delay <= 0) {
        [_checkTimer fire];
    }else{
        [_checkTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    }
}
- (void)stopCheckTimer{
    [_checkTimer invalidate];
    _checkTimer = nil;
    _retriedCount = -1;
    [self stopWait];
}
- (void)handleCheckTimer:(NSTimer *)timer{
    if (_retriedCount >= 2) {
        // 超时
        [self checkOrderTimeout];
    }else{
        [self requestOrderDetail];
        _retriedCount ++;
    }
    
}

- (void)checkOrderTimeout{
    [self stopCheckTimer];
    [self showTip:@"订单创建失败！" WithType:FNTipTypeFailure];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - HTTP Request
- (void)requestOrderDetail{
    if (!self.carpoolOrder || !self.carpoolOrder.orderId) {
        return;
    }
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId":self.carpoolOrder.orderId};
    }];
}

- (void)requestCancelOrder{
    if (!self.carpoolOrder || !self.carpoolOrder.orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderCancel params:^(NetParams *params) {
        params.method = EMRequstMethod_DELETE;
        params.data = @{@"orderId":self.carpoolOrder.orderId};
    }];
}
#pragma mark -
- (void)setState:(OrderState)state{
    _statusProgressView.state = state;
    [self removeChildStateController];
    CarpoolTravelStateViewController *stateVC = [CarpoolTravelStateViewController instaceWithState:state];
    stateVC.carpoolOrder = self.carpoolOrder;
    [self addChildViewController:stateVC];

    [self.detailView addSubview:stateVC.view];
    [stateVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailView.top);
        make.left.equalTo(self.detailView.left);
        make.right.equalTo(self.detailView.right);
        make.bottom.equalTo(self.detailView.bottom);
    }];
    [self.view layoutIfNeeded];
}
- (void)setCarpoolOrder:(CarpoolOrderItem *)carpoolOrder{
    if (_carpoolOrder) {
        _carpoolOrder = carpoolOrder;
        [self updateState];
    }
    _carpoolOrder = carpoolOrder;
}
#pragma mark - PrivateMethods
- (void)removeChildStateController{
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[CarpoolTravelStateViewController class]]) {
            [vc removeFromParentViewController];
            [vc.view removeFromSuperview];
        }
    }
}
- (void)updateState{
#if DEBUG
//    _carpoolOrder.payStatus = CarpoolOrderPayStatusPaid;
//    _carpoolOrder.orderStatus = CarpoolOrderStatusTravelEnd;
#endif
    switch (_carpoolOrder.payStatus) {
        case CarpoolOrderPayStatusNON:{
            [self setState:OrderStateSystem];
            break;
        }
        case CarpoolOrderPayStatusPaidFail:
        case CarpoolOrderPayStatusPrepareForPay:{
            [self setState:OrderStateWaitingForPay];
            break;
        }
        case CarpoolOrderPayStatusPaid:{
            if (_carpoolOrder.orderStatus == CarpoolOrderStatusTravelling){
                [self setState:OrderStateStartTravel];
            }else if (_carpoolOrder.orderStatus == CarpoolOrderStatusTravelEnd){
                [self setState:OrderStateEndTravel];
            }else{
                [self setState:OrderStateIsPay];
            }
            break;
        }
        default:{
            [self setState:OrderStateSystem];
            break;
        }
    }
}
#pragma mark - Actions
- (void)actionBarItemCancel:(UIBarButtonItem *)sender{
    if (self.carpoolOrder.payStatus != CarpoolOrderPayStatusPaid) {
        UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"取消订单" message:@"亲，您确定要取消当前订单吗？" delegate:self];
        alertView.userInfo = @(TagAlertWithoutRefund);
        [alertView showInView:self.navigationController.view];
    }else{
        UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"取消订单" message:@"亲，现在取消订单会扣取一定的手续费哦～" delegate:self];
        alertView.userInfo = @(TagAlertWithRefund);
        [alertView showInView:self.navigationController.view];
    }
}

#pragma mark - Request Callback
- (void)httpRequestFinished:(NSNotification *)notification{
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    NSDictionary *result = resultData.data;
    
    if (type == FNUserRequestType_CarpoolOrderDetail) {
        if (resultData.resultCode == 0) {
            // 查询状态成功
            CarpoolOrderItem *orderItem = [[CarpoolOrderItem alloc]initWithDictionary:result[@"data"]];
            if (orderItem) {
                [self stopWait];
                self.carpoolOrder = orderItem;
                [self stopCheckTimer];
            }
        }
    }if (type == FNUserRequestType_CarpoolOrderCancel) {
        [self stopWait];
        
        CarpoolTravelCancelViewController *cancelVC = [CarpoolTravelCancelViewController instanceFromStoryboard];
        cancelVC.carpoolOrder = self.carpoolOrder;

        NSMutableArray *temp = [NSMutableArray arrayWithObject:[self.navigationController.viewControllers firstObject]];
        [temp addObject:[TravelHistoryViewController instanceFromStoryboard]];
        [temp addObject:cancelVC];
//        [temp addObject:];
        [self.navigationController setViewControllers:temp animated:YES];
//        [self requestOrderDetail];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    DBG_MSG(@"%@", notification.object);
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
    RequestType type = [notification.object[@"type"] intValue];
    
    if (type == FNUserRequestType_CarpoolOrderDetail) {
        // 查询异常出错，停止轮询
        [self stopCheckTimer];
    }else if (FNUserRequestType_CarpoolOrderCancel == type) {
        
    }
}
#pragma mark - APNS Callback
- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    if (![userInfo[@"mainOrderId"] isEqualToString:self.carpoolOrder.orderId]) {
        // 如果推送的订单号不是当前订单号， 则不处理。
        return;
    }
    FNPushProccessType proccessType = [userInfo[kProccessType] integerValue];
    if (proccessType == FNPushProccessType_CarpoolOrderCreate ||
        proccessType == FNPushProccessType_CarpoolStartTime ||
        proccessType == FNPushProccessType_CarpoolTravelStart ||
        proccessType == FNPushProccessType_CarpoolTravelEnd) {
        // 拼车订单生成, 拼车发车时间地点通知, 拼车行程开始通知, 拼车行程结束通知
        // 刷新当前订单详情
        [self requestOrderDetail];
    }
}

- (void)applicationDidResume{
    if (self.navigationController.topViewController == self) {
        [self requestOrderDetail];
    }
}
#pragma mark - AlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    NSLog(@"%@", alertView);
    if ([alertView.userInfo integerValue] == TagAlertWithoutRefund) {
        if (btnIndex == 0) {
            [self requestCancelOrder];
        }
    }else{
        if (btnIndex == 0) {
            CarpoolRefundConfirmViewController *refundVC = [CarpoolRefundConfirmViewController instanceFromStoryboard];
            refundVC.orderItem = self.carpoolOrder;
            [self.navigationController pushViewController:refundVC animated:YES];
        }
    }
}
@end
