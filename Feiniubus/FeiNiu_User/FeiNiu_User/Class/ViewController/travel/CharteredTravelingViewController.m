//
//  CharteredTravelingViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/31.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//
// 包车当前行程

#import "CharteredTravelingViewController.h"
#import <FNUIView/CircleProgressView.h>
#import "CharterPayViewController.h"
#import "ConfirmOrderViewCell.h"
#import "BorderButton.h"
#import "TimerButton.h"
#import "CharterOrderItem.h"
#import "UserCustomAlertView.h"
#import "PushNotificationAdapter.h"
#import "CharterPayViewController.h"
//#import "CharterDetailPayViewController.h"
#import "CharterTravelStateViewController.h"
#import "CharterPayedStateViewController.h"
#import "UserCustomAlertView.h"

@class CharteredTravelSuborderCell;

#define MaxWaitingTime 30 * 60

@implementation CharterOrderPrice (Date)

- (NSDate *)startDate{
    return [NSDate dateFromString:self.startTime format:@"yyyy-MM-dd HH:mm:ss"];
}
- (NSDate *)endDate{
    return [NSDate dateFromString:self.endTime format:@"yyyy-MM-dd HH:mm:ss"];
}
@end

#pragma mark - 
@protocol CharteredTravelCellDelegate <NSObject>
@optional
- (void)charterSubOrderCellDidCancel:(CharteredTravelSuborderCell *)cell;
- (void)charterSubOrderCellDidSubmit:(CharteredTravelSuborderCell *)cell;
@end
@interface CharteredTravelSuborderCell : UserTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblBusInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet BorderButton *btnCancel;
@property (weak, nonatomic) IBOutlet TimerButton *btnPay;
@property (nonatomic, assign) id<CharteredTravelCellDelegate> delegate;
@property (nonatomic, strong) CharterSuborderItem *suborderItem;
@end
@implementation CharteredTravelSuborderCell

- (void)setSuborderItem:(CharterSuborderItem *)suborderItem{
    _suborderItem = suborderItem;
    [self updateUI];
}
- (void)updateUI{
    self.lblBusInfo.text = _suborderItem.bus.description;
    self.lblPrice.text = [NSString stringWithFormat:@"%@元", @(_suborderItem.price / 100)];
    //test
#if DEBUG
//    self.suborderItem.orderState = CharterOrderStatusDriverGot;
#endif
    if (self.suborderItem.orderState == CharterOrderStatusPrepare) {
        self.btnCancel.hidden = NO;
        NSLog(@"%@, %@", [NSDate date], @([[NSDate date] timeIntervalSinceDate:self.suborderItem.createTime]));
        self.btnPay.startTime = [self.suborderItem.waitStartTime timeIntervalSinceDate:self.suborderItem.createTime];
        [self.btnPay startTimerAtTime:[[NSDate date] timeIntervalSinceDate:self.suborderItem.createTime]];
    }else{
        [self.btnPay stopTimer];
        self.btnPay.enabled = YES;

        switch (self.suborderItem.orderState) {
            case CharterOrderStatusDriverGot:{
                self.btnCancel.hidden = NO;
                if (self.suborderItem.payState == CharterOrderPayStatusPaying) {
                    [self.btnPay setTitle:@"支付中(对公转账)" forState:UIControlStateNormal];
                    self.btnPay.enabled = NO;
                }else{
                    if (self.suborderItem.payState == CharterOrderPayStatusPaidInFullFail ||
                        self.suborderItem.payState == CharterOrderPayStatusEarnestPayFail) {
                        [self.btnPay setTitle:@"重新支付" forState:UIControlStateNormal];
                    }else{
                        [self.btnPay setTitle:@"立即支付" forState:UIControlStateNormal];
                    }
                }
                break;
            }
                
            case CharterOrderStatusWaiting:{
                self.btnCancel.hidden = NO;
                if (self.suborderItem.payState == CharterOrderPayStatusPrepareForPay) {
                    [self.btnPay setTitle:@"立即支付" forState:UIControlStateNormal];
                }else if (self.suborderItem.payState == CharterOrderPayStatusPaidInFullFail ||
                          self.suborderItem.payState == CharterOrderPayStatusEarnestPayFail) {
                    [self.btnPay setTitle:@"重新支付" forState:UIControlStateNormal];
                }else{
                    [self.btnPay setTitle:@"等待开始" forState:UIControlStateNormal];
                    self.btnPay.enabled = NO;
                }
                break;
            }
            case CharterOrderStatusTravelling:{
                self.btnCancel.hidden = YES;
                [self.btnPay setTitle:@"正在进行" forState:UIControlStateNormal];
                break;
            }
            
            case CharterOrderStatusTravelEnd:{
                self.btnCancel.hidden = YES;
                [self.btnPay setTitle:@"订单完成" forState:UIControlStateNormal];
                break;
            }
            case CharterOrderStatusSuspend:{
                self.btnCancel.hidden = NO;
                [self.btnPay setTitle:@"继续等待" forState:UIControlStateNormal];
                break;
            }
            case CharterOrderStatusCancel:{
                self.btnCancel.hidden = YES;
                if (self.suborderItem.payState == CharterOrderPayStatusApplyForRefund){
                    [self.btnPay setTitle:@"退款申请中" forState:UIControlStateNormal];
                }else if(self.suborderItem.payState  == CharterOrderPayStatusRefunding){
                    [self.btnPay setTitle:@"退款中" forState:UIControlStateNormal];
                }else if (self.suborderItem.payState == CharterOrderPayStatusRefundReject){
                    [self.btnPay setTitle:@"退款申请驳回" forState:UIControlStateNormal];
                }else if(self.suborderItem.payState == CharterOrderPayStatusRefundDone){
                    [self.btnPay setTitle:@"退款完成" forState:UIControlStateNormal];
                }else if (self.suborderItem.payState == CharterOrderPayStatusRefundFail){
                    [self.btnPay setTitle:@"退款失败" forState:UIControlStateNormal];
                }else{
                    [self.btnPay setTitle:@"已取消" forState:UIControlStateNormal];
                }
                break;
            }
            default:
                break;
        }
    }
}
#pragma mark -
- (IBAction)actionCancel:(BorderButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(charterSubOrderCellDidCancel:)]) {
        [self.delegate charterSubOrderCellDidCancel:self];
    }
}

- (IBAction)actionCommit:(TimerButton *)sender {
    switch (self.suborderItem.orderState) {
        case CharterOrderStatusPrepare:
        case CharterOrderStatusSuspend:{
            [self requestContinue];
            break;
        }
        default:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(charterSubOrderCellDidSubmit:)]) {
                [self.delegate charterSubOrderCellDidSubmit:self];
            }
            break;
        }
    }
}

#pragma mark - RequestMethods
- (void)requestCancelCharterOrder{
    if (!self.suborderItem.subOrderId) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@CharterOrder", KServerAddr];
    [[NetInterface sharedInstance] httpDeleteRequest:url body:@{@"subOrderId":self.suborderItem.subOrderId} suceeseBlock:^(NSString *msg) {
        NSDictionary *result = [JsonUtils jsonToDcit:msg];
        if ([result[@"code"] integerValue] == 0) {
            self.suborderItem.orderState = CharterOrderStatusCancel;
            [self updateUI];
        }else{
            [MBProgressHUD showTip:result[@"message"]  WithType:FNTipTypeFailure withDelay:2];
        }
        
    } failedBlock:^(NSError *msg) {
        [MBProgressHUD showTip:msg.localizedDescription WithType:FNTipTypeFailure withDelay:2];
    }];
}

- (void)requestContinue{
    NSString *url = [NSString stringWithFormat:@"%@CharterOrder?subOrderId=%@", KServerAddr, self.suborderItem.subOrderId];
    [[NetInterface sharedInstance] httpPutRequest:url body:@{@"facai":@"facai"} suceeseBlock:^(NSString *msg) {
        self.suborderItem.waitStartTime = [NSDate dateFromString:[JsonUtils jsonToDcit:msg][@"data"][@"waitStartTime"]];
        self.suborderItem.orderState = CharterOrderStatusPrepare;
        [self updateUI];
    } failedBlock:^(NSError *msg) {
        [MBProgressHUD showTip:msg.localizedDescription WithType:FNTipTypeFailure withDelay:2];
    }];
}
- (void)requestOrderDetail{
    NSString *url = [NSString stringWithFormat:@"%@CharterOrderSubDetaile", KServerAddr];
    [[NetInterface sharedInstance] httpGetRequest:url body:@{@"orderId":self.suborderItem.subOrderId} suceeseBlock:^(NSString *msg) {
        
    } failedBlock:^(NSError *msg) {
        
    }];
}

@end




#pragma mark -
@interface CharteredTravelingViewController ()<UITableViewDataSource, UITableViewDelegate, CharteredTravelCellDelegate, UserCustomAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *kmLabel;
@property (weak, nonatomic) IBOutlet UILabel *startPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPlaceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CharterOrderItem *orderItem;
@end

@implementation CharteredTravelingViewController

+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}
#pragma mark - ViewLifeCycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"当前订单";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestOrderInfo:self.orderId];

}

#pragma mark - Monitor
#if DEBUG
//- (CharterOrderPrice *)order{
//    if (_order) {
//        return _order;
//    }
//    _order = [CharterOrderPrice new];
//    _order.paths = @[@{@"pathType":@1,@"name":@"绵阳市中心医院",@"adCode":@"510703",@"sequence":@1,@"location":@"31.457345, 104.753097"},@{@"pathType":@2,@"name":@"绵阳市图书情报学会",@"adCode":@"510703",@"sequence":@1,@"location":@"31.475025, 104.737842"},@{@"pathType":@3,@"name":@"绵阳中学(公交站)",@"adCode":@"510703",@"sequence":@1,@"location":@"31.462166, 104.724350"}];
//    _order.virtualId = [self generateVirualID];
//    _order.type = 1;
//    _order.startTime = [[NSDate date] timeStringByFormat:@"yyyy-MM-dd HH:mm:ss"];
//    _order.endTime = [[NSDate dateWithTimeIntervalSinceNow:57600] timeStringByFormat:@"yyyy-MM-dd HH:mm:ss"];
//    _order.mapSourceType = 1;
//    _order.miles = 40;
//    _order.passageFares = 0;
//    _order.vehicleConfigs = @[@{@"Seat" : @1,@"VehicleLevelId" : @1,@"VehicleTypeId" : @1, @"Amount" : @1}, @{@"Seat" : @48,@"VehicleLevelId" : @1,@"VehicleTypeId" : @1, @"Amount" : @1}];
//    _order.isDriverFree = NO;
//    return _order;
//}
//- (NSString *)generateVirualID{
//    return [NSString stringWithFormat:@"FEINIUO%@", [[NSDate date] timeStringByFormat:@"yyyyMMddHHmmss"]];
//}
//
//- (void)requestPrice{
//    [self startWait];
//    NSString *url = [NSString stringWithFormat:@"%@CharterOrderPrice", KServerAddr];
//    
//    [[NetInterfaceManager sharedInstance] postRequst:url body:self.order.description requestType:KRequestType_sharingvehicleorderpost];
//}
//- (void)requestOrderSubmit{
//    NSString *url = [NSString stringWithFormat:@"%@CharterOrder", KServerAddr];
//    [[NetInterfaceManager sharedInstance] postRequst:url body:self.order.virtualIdDescription requestType:KRequestType_submitrentvehicleorder];
//}
//
#endif
#pragma mark - RequestMethods
- (void)requestOrderInfo:(NSString *)orderId{
    if (!orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderDetail params:^(NetParams *params) {
        params.data = @{@"OrderId":orderId};
    }];
}

- (void)requestSuborderDetail:(NSString *)suborderId withLoadingMsg:(NSString *)msg{
    if (!suborderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterSubOrderDetail params:^(NetParams *params) {
        params.data = @{@"OrderId":suborderId};
    }];
}
#pragma mark - PrivateMethods
// 初始化UI
//-(void)initUI{
////    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
////    btnRight.frame = CGRectMake(0, 0, 70, 44);
////    [btnRight addTarget:self action:@selector(cancelRoute) forControlEvents:UIControlEventTouchUpInside];
////    btnRight.titleLabel.font = [UIFont systemFontOfSize:15.f];
////    [btnRight setTitle:@"取消订单" forState:UIControlStateNormal];
////    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
////    self.navigationItem.rightBarButtonItem = item;
//    
//    //
//    _timeLabel.text = @"";
//    _kmLabel.text = @"";
//    _startPlaceLabel.text = @"";
//    _endPlaceLabel.text = @"";
//    _tipLabel.text = @"";
//}

- (void)updateUI{
    _timeLabel.text = [NSString stringWithFormat:@"%@-%@", [self.orderItem.startTime timeStringByFormat:@"MM月dd日 HH:mm"], [self.orderItem.returnTime timeStringByFormat:@"MM月dd日 HH:mm"]];
    _kmLabel.text = [NSString stringWithFormat:@"%.2f KM", self.orderItem.kilometers];
    _startPlaceLabel.text = self.orderItem.startingName;
    _endPlaceLabel.text = self.orderItem.destinationName;
    BOOL isPrepare = NO;
    for (CharterSuborderItem *item in self.orderItem.subOrder) {
        if (item.orderState == CharterOrderStatusPrepare) {
            isPrepare = YES;
        }
    }
    self.tipLabel.text = isPrepare ? @"亲，您发布的用车需求已有司机收到，请耐心等待，最多30分钟就会有车主抢单～" : @"";
    [self.tableView reloadData];
}


//#pragma mark- Actions
// 导航栏右边按钮
//- (void)cancelRoute{
////    [self requestPrice];
//
////    UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"取消订单" message:@"亲，现在取消订单会扣取一定的手续费哦～" delegate:nil];
////    [alertView showInView:self.view];
//
//}
#pragma mark - TableViewDelegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _orderItem.subOrder.count;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CharteredTravelSuborderCell *cell = [tableView dequeueReusableCellWithIdentifier:[CharteredTravelSuborderCell identifier]];
    cell.suborderItem = _orderItem.subOrder[indexPath.section];
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CharteredTravelSuborderCell *cell = [tableView cellForRowAtIndexPath:indexPath];
#if DEBUG
//    cell.suborderItem.orderState = CharterOrderStatusSuccessDone;
#endif
    
    switch (cell.suborderItem.orderState) {
        case CharterOrderStatusDriverGot:{
            if (cell.suborderItem.payState == CharterOrderPayStatusPaying) {
                [self performSegueWithIdentifier:@"ToWaitPay" sender:cell.suborderItem];
            }else{
                [self performSegueWithIdentifier:@"ToCharterDetailWaitPay" sender:cell.suborderItem];
            }
            break;
        }
        case CharterOrderStatusSuspend:
        case CharterOrderStatusPrepare:{
            [self performSegueWithIdentifier:@"ToCharterDetailPrepare" sender:cell.suborderItem];
            break;
        }
        case CharterOrderStatusCancel:{
            [self performSegueWithIdentifier:@"ToCancelState" sender:cell.suborderItem];
            break;
        }
        case CharterOrderStatusTravelling:
        case CharterOrderStatusTravelEnd:
        case CharterOrderStatusWaiting:
        default:{
            [self performSegueWithIdentifier:@"ToCharterDetail" sender:cell.suborderItem];
            break;
        }
    }

    return nil;
}
#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ToCharterDetailWaitPay"]) {
        CharterTravelStateGrabbedViewController *vc = segue.destinationViewController;
        vc.suborder = sender;
    }else if ([segue.identifier isEqualToString:@"ToCharterDetail"]){
        CharterPayedStateViewController *vc = segue.destinationViewController;
        vc.suborder = sender;
    }else if ([segue.identifier isEqualToString:@"ToCharterDetailPrepare"]){
        CharterTravelStatePrepareViewController *prepareVC = segue.destinationViewController;
        prepareVC.suborder = sender;
    }else if ([segue.identifier isEqualToString:@"ToWaitPay"]){
        CharterTravelStateViewController *prepareVC = segue.destinationViewController;
        prepareVC.suborder = sender;
    }else if ([segue.identifier isEqualToString:@"ToCancelState"]){
        ((CharterTravelStateViewController *)segue.destinationViewController).suborder = sender;
    }
}
#pragma mark - UserAlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (btnIndex == 0) {
        @try {
            [((CharteredTravelSuborderCell *)alertView.userInfo) requestCancelCharterOrder];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}
#pragma mark - CellButton Click Delegate
- (void)charterSubOrderCellDidCancel:(CharteredTravelSuborderCell *)cell{
    UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"取消订单" message:@"亲，您确定要取消当前订单吗？" delegate:self];
    alertView.userInfo = cell;
//    alertView.tag = TagAlertWithoutRefund;
    [alertView showInView:self.view];
}
- (void)charterSubOrderCellDidSubmit:(CharteredTravelSuborderCell *)cell{
    switch (cell.suborderItem.payState) {
        case CharterOrderPayStatusPaidInFullFail:
        case CharterOrderPayStatusEarnestPayFail:
        case CharterOrderPayStatusPrepareForPay:{
            // 进入支付
            CharterPayViewController *payVC = [CharterPayViewController instanceFromStoryboard];
            payVC.suborderItem = cell.suborderItem;
            [self.navigationController pushViewController:payVC animated:YES];
            break;
        }
        default:
            break;
    }
}
#pragma mark - Notifications
- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    if (![userInfo[@"mainOrderId"] isEqualToString:self.orderItem.orderId]) {
        // 如果当前主订单和推送的主订单不一样， 不做任何操作。
        return;
    }
    FNPushProccessType type = [userInfo[kProccessType] integerValue];
    switch (type) {
        case FNPushProccessType_CharterOrderCreate:{
            NSString *orderId = userInfo[@"orderId"];
            if (![orderId isEqualToString:self.orderItem.orderId]) {
                return;
            }
            [self requestOrderInfo:orderId];
            break;
        }
        case FNPushProccessType_CharterTravelStart:
        case FNPushProccessType_CharterTravelEnd:
        case FNPushProccessType_CharterOrderGrab:
        case FNPushProccessType_CharterOrderInvalid:{
            NSString *mainOrderId = userInfo[@"mainOrderId"];
            if (![mainOrderId isEqualToString:self.orderItem.orderId]) {
                return;
            }
            [self requestSuborderDetail:userInfo[@"orderId"] withLoadingMsg:@"您已被抢单！"];
            break;
        }
        default:
            break;
    }
}

- (void)applicationDidResume{
    if (self.navigationController.topViewController == self) {
        [self requestOrderInfo:self.orderId];
    }
}
#pragma mark Http
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;

    switch (type) {
//        case KRequestType_sharingvehicleorderpost:{
//            self.order.prePrice = [notification.object[@"data"][@"price"] integerValue];
//            [self performSelector:@selector(requestOrderSubmit) withObject:nil afterDelay:2];
//            break;
//        }
//        case KRequestType_submitrentvehicleorder:{
//            self.orderId = notification.object[@"data"][@"orderId"];
//            [self performSelector:@selector(requestOrderInfo:) withObject:self.orderId afterDelay:3];
//            break;
//        }
        case FNUserRequestType_CharterOrderDetail:{
            _orderItem = [[CharterOrderItem alloc]initWithDictionary:resultData.data[@"charterOrder"]];
            [self updateUI];
            break;
        }
        case FNUserRequestType_CharterSubOrderDetail:{
            NSDictionary *order = resultData.data[@"order"];

            [self.orderItem.subOrder enumerateObjectsUsingBlock:^(CharterSuborderItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([order[@"subOrderId"] isEqualToString:obj.subOrderId]) {
                    [obj updateOrderInfo:order];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:idx]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    *stop = YES;
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
}
@end
