//
//  CharteredDetailViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CharterPayedStateViewController.h"
#import <WebImage/WebImage.h>
#import "UIColor+Hex.h"
#import "UserCustomAlertView.h"
#import "InvoiceViewController.h"
#import "CharterRoutingViewController.h"
#import "CharterCancelViewController.h"
#import "DetaillistViewController.h"
#import "PushNotificationAdapter.h"


#define TagTableViewLabel   2001


@interface CharterPayedStateViewController ()<UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UserCustomAlertViewDelegate>{
    NSMutableArray<NSString *> *_data;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet UIView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightDetailButton;

@end

@implementation CharterPayedStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"当前订单";
    // Do any additional setup after loading the view.
    [self.suborder.photos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(idx * self.view.frame.size.width, 0, self.view.frame.size.width, self.bannerScrollView.frame.size.height)];
        [iv sd_setImageWithURL:[NSURL URLWithString:obj]];
        [self.bannerScrollView addSubview:iv];
    }];
    self.bannerScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.suborder.photos.count, self.bannerScrollView.bounds.size.height);
    self.lblPrice.text = [NSString stringWithFormat:@"%@ 元", @(self.suborder.price / 100.0f)];
    self.detailView.hidden = YES;
    self.heightDetailButton.constant = 0;
    [self.view layoutIfNeeded];
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    self.navigationController.navigationBar.translucent = YES;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbktrans"] forBarMetrics:UIBarMetricsDefault];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbkgreen"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Private Methods
- (void)loadData{
    _data = [NSMutableArray array];
    [_data addObject:@"订单详情"];
    [_data addObject:[NSString stringWithFormat:@"出发地: %@", self.suborder.starting.name]];
    [_data addObject:[NSString stringWithFormat:@"目的地: %@", self.suborder.destination.name]];
    NSString *formate = @"MM月dd日 HH:mm";
    [_data addObject:[NSString stringWithFormat:@"时间: %@ - %@", [self.suborder.startingTime timeStringByFormat:formate], [self.suborder.returnTime timeStringByFormat:formate]]];
    [_data addObject:[NSString stringWithFormat:@"里程: %.2f KM", self.suborder.kilometers]];
    [_data addObject:[NSString stringWithFormat:@"车牌号: %@", self.suborder.bus.licensePlate]];
    [_data addObject:[NSString stringWithFormat:@"司机信息: %@   %@", self.suborder.driver.driverName, self.suborder.driver.driverPhone]];
    [self.tableView reloadData];
}
- (void)updateUI{
    switch (self.suborder.payState) {
        case CharterOrderPayStatusEarnestPayFail:
        case CharterOrderPayStatusPaidInFullFail:
        case CharterOrderPayStatusPrepareForPay:{
            [self.btnRight setTitle:@"立即支付" forState:UIControlStateNormal];
            break;
        }
        case CharterOrderPayStatusApplyForRefund:{
            [self.btnRight setTitle:@"退款申请中" forState:UIControlStateNormal];
            break;
        }
        case CharterOrderPayStatusRefunding:{
            [self.btnRight setTitle:@"退款中" forState:UIControlStateNormal];
            break;
        }
        case CharterOrderPayStatusRefundReject:
        case CharterOrderPayStatusRefundFail:{
            [self.btnRight setTitle:@"退款失败" forState:UIControlStateNormal];
            break;
        }
        case CharterOrderPayStatusRefundDone:{
            [self.btnRight setTitle:@"退款成功" forState:UIControlStateNormal];
            break;
        }
        case CharterOrderPayStatusNON:{
            [self.btnRight setTitle:@"已取消" forState:UIControlStateNormal];
            break;
        }
        default:{
            if (self.suborder.orderState == CharterOrderStatusTravelling){
                [self.btnRight setTitle:@"订单中" forState:UIControlStateNormal];
            }else if (self.suborder.orderState == CharterOrderStatusTravelEnd){
                [self.btnRight setTitle:@"索要发票" forState:UIControlStateNormal];
                self.detailView.hidden = NO;
                self.heightDetailButton.constant = 50;
                [self.view layoutIfNeeded];
            }else{
                [self.btnRight setTitle:@"取消订单" forState:UIControlStateNormal];
            }
            break;
        }
    }
    
    [self loadData];
}

//- (NSArray *)generatePathData{
//    
//    return @[];
//}
#pragma mark - Actions
- (IBAction)actionBtnRight:(UIButton *)sender {
    switch (self.suborder.payState) {
        case CharterOrderPayStatusEarnestPayFail:
        case CharterOrderPayStatusPaidInFullFail:
        case CharterOrderPayStatusPrepareForPay:{
            // 立即支付
            break;
        }
        case CharterOrderPayStatusApplyForRefund:{
            //退款申请中
            break;
        }
        case CharterOrderPayStatusRefunding:{
            // 退款中
            break;
        }
        case CharterOrderPayStatusRefundReject:
        case CharterOrderPayStatusRefundFail:{
             // 退款失败
            break;
        }
        case CharterOrderPayStatusRefundDone:{
            // 退款成功
            break;
        }
        case CharterOrderPayStatusNON:{
            // 已取消
            break;
        }
        default:{
            if (self.suborder.orderState == CharterOrderStatusTravelling){
                // 行程中
                [self.btnRight setTitle:@"订单中" forState:UIControlStateNormal];
            }else if (self.suborder.orderState == CharterOrderStatusTravelEnd){
                // 索要发票
                [self performSegueWithIdentifier:@"CharterToInvoice" sender:nil];
            }else{
                // 取消订单
                UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"取消订单" message:@"您确定要取消当前订单吗？取消会收取一定的手续费～" delegate:self];
                [alert showInView:self.view];
            }
            break;
        }
    }
}
- (IBAction)actionEvaluate:(UIButton *)sender {
}

- (IBAction)actionDetail:(UIButton *)sender {
    DetaillistViewController *detailVC = [DetaillistViewController instanceFromStoryboard];
    detailVC.orderItem = self.suborder;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CharterToInvoice"]) {
        ((InvoiceViewController *)segue.destinationViewController).price = @(self.suborder.price / 100.0f);
        ((InvoiceViewController *)segue.destinationViewController).orderId = self.suborder.subOrderId;
    }else if ([segue.destinationViewController isKindOfClass:[CharterRoutingViewController class]]){
        ((CharterRoutingViewController *)segue.destinationViewController).suborder = self.suborder;
    }
}

#pragma mark - Request Methods
- (void)requestCancelCharterSubOrder{
    if (!self.suborder || !self.suborder.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderCancel params:^(NetParams *params) {
        params.method = EMRequstMethod_DELETE;
        params.data = @{@"subOrderId":self.suborder.subOrderId};
    }];

}
- (void)requestCharterDetail{
//    if (!self.suborder || !self.suborder.subOrderId) {
//        return;
//    }
//    [self startWait];
//    NSString *url = [NSString stringWithFormat:@"%@CharterOrderMainDetaile", KServerAddr];
//    NSString *body = [JsonUtils dictToJson:@{@"OrderId" : self.charterOrder.orderId}];
//
//    [ProtocolInstance apiCharterOrderMainDetaileWithOrderId:self.charterOrder.orderId];
    
}
#pragma mark - TableViewDelegate && Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor colorWithHex:0xb4b4b4];
    }else{
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHex:0x666666];
    }
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return indexPath.row == 0 ? 50 : 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *data = _data[indexPath.row];
    if ([data containsString:self.suborder.driver.driverPhone]) {
        NSString * str=[[NSString alloc] initWithFormat:@"tel:%@",self.suborder.driver.driverPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    return nil;
}
#pragma mark - Scrollview Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.bannerScrollView == scrollView) {
        NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
        self.pageControl.currentPage = page;
    }
}
#pragma mark - AlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (btnIndex == 0) {
        CharterCancelViewController *charterCancelVC = [CharterCancelViewController instanceFromStoryboard];
        charterCancelVC.charterOrder = self.suborder;
        [self.navigationController pushViewController:charterCancelVC animated:YES];
//        [self requestCancelCharterSubOrder];
    }
}
#pragma mark - 
- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    FNPushProccessType type = [userInfo[kProccessType] integerValue];
    NSString *suborderId = userInfo[@"orderId"];
    if (![self.suborder.subOrderId isEqualToString:suborderId]) {
        return;
    }
    if (type == FNPushProccessType_CharterTravelStart) {
        self.suborder.orderState = CharterOrderStatusTravelling;
        [self updateUI];
    }else if (type == FNPushProccessType_CharterTravelEnd){
        self.suborder.orderState = CharterOrderStatusTravelEnd;
        [self updateUI];
    }
}
#pragma mark - Request Callback
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_CharterOrderDetail) {
//        NSDictionary *data = notification.object[@"data"];
        [self updateUI];
    }if (type == FNUserRequestType_CharterOrderCancel) {
        // 取消订单，返回上一级界面
//        [self showTip:@"成功取消订单" WithType:FNTipTypeSuccess];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
}
@end
