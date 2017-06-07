//
//  CharterTravelStateViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/18.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterTravelStateViewController.h"
#import "CharterOrderItem.h"
#import "UIColor+Hex.h"
#import "PushNotificationAdapter.h"
#import "CharterDetailPayTipsViewController.h"
#import "CharterPayViewController.h"
#import "CharterCancelTravelCell.h"

@implementation CharterTravelStateViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    if (self.suborder.startingTime && self.suborder.returnTime) {
        self.lblTimeInfo.text = [NSString stringWithFormat:@"%@ - %@", [self.suborder.startingTime timeStringByFormat:@"MM月dd日 HH:mm"], [self.suborder.returnTime timeStringByFormat:@"MM月dd日 HH:mm"]];
    }else{
        self.lblTimeInfo.text = @"-";
    }
    
    if (self.suborder.bus) {
        self.lblBusInfo.text = [NSString stringWithFormat:@"%@", self.suborder.bus];
    }else{
        self.lblBusInfo.text = @"";
    }
    
    if (self.suborder.kilometers) {
        self.lblKM.text = [NSString stringWithFormat:@"%.2f KM", self.suborder.kilometers];
    }else{
        self.lblKM.text = @"";
    }
    if (self.suborder.starting) {
        self.lblStartName.text = [NSString stringWithFormat:@"%@", self.suborder.starting.name];
    }else{
        self.lblStartName.text = @"";
    }
    
    if (self.suborder.destination) {
        self.lblDestination.text = [NSString stringWithFormat:@"%@", self.suborder.destination.name];
    }else{
        self.lblDestination.text = @"";
    }
    self.lblPrice.text = @(self.suborder.price / 100.0f).stringValue;
}
@end




@implementation CharterTravelStatePrepareViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)setupUI{
    [super setupUI];
    NSDate *date = [NSDate date];
    _startIndex = [date timeIntervalSinceDate:self.suborder.createTime];
    if (_startIndex <= 0) {
        _startIndex = 0;
    }
    self.progressView.elapsedTime = _startIndex;
    self.progressView.timeLimit = 30 * 60 + [self.suborder.waitStartTime timeIntervalSinceDate:self.suborder.createTime];
    self.progressView.status = @"等待时间";
    self.progressView.tintColor = [UIColor colorWithHex:GloabalTintColor];
    // 设置超时界面
    BOOL isTimeout = (_startIndex >= self.progressView.timeLimit ||
                      self.suborder.orderState == CharterOrderStatusSuspend);
    if (!isTimeout) {
        [self startWaitTimer];
    }
    [self setupTimeout:isTimeout];
}
- (void)setupTimeout:(BOOL)flag{
    _progressView.progressLabel.hidden = flag;
    _btnTimeout.hidden = !flag;
    if (flag) {
        [self stopWaitTimer];
        self.progressView.elapsedTime = self.progressView.timeLimit;
    }
}
#pragma mark - HTTP Request Methods
- (void)requestSuborderDetail:(NSString *)suborderId withLoadingMsg:(NSString *)msg{
    if (!suborderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterSubOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId": suborderId};
    }];
}
- (void)requestSuborderContinueWithLoadingMsg:(NSString *)msg{
    if (!self.suborder || !self.suborder.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderContinue params:^(NetParams *params) {
        params.method = EMRequstMethod_PUT;
        params.data = @{@"subOrderId": self.suborder.subOrderId,
                        @"facai":      @"facai"};
    }];
    
    
}
#pragma mark - Timer progress
- (void)startWaitTimer{
    if (_waitTimer) {
        [self stopWaitTimer];
    }
    _waitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleWaitTimer:) userInfo:nil repeats:YES];
    [_waitTimer fire];
}
- (void)stopWaitTimer{
    [_waitTimer invalidate];
    _waitTimer = nil;
}

- (void)handleWaitTimer:(NSTimer *)timer{
    _startIndex ++;
    if (_startIndex < self.progressView.timeLimit) {
        self.progressView.elapsedTime = _startIndex;
    }else{
        // 超时, 根据推送判断订单超时
        
    }
}
#pragma mark - Actions
- (IBAction)actionBtnTimeout:(UIButton *)sender {
    [self requestSuborderContinueWithLoadingMsg:nil];
}

#pragma mark -

- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_CharterSubOrderDetail) {
        NSDictionary *order = resultData.data[@"order"];
        
        [self.suborder updateOrderInfo:order];
        if (self.suborder.orderState == CharterOrderStatusDriverGot) {
            NSMutableArray<UIViewController *> *vcs = [self.navigationController.viewControllers mutableCopy];;
            CharterTravelStateGrabbedViewController *waitPayStateVC = [CharterTravelStateGrabbedViewController instanceFromStoryboard];
            waitPayStateVC.suborder = self.suborder;
            [vcs replaceObjectAtIndex:vcs.count - 1 withObject:waitPayStateVC];
            [self.navigationController setViewControllers:[NSArray arrayWithArray:vcs] animated:YES];
        }else{
            [self setupUI];
        }
    }else if (type == FNUserRequestType_CharterOrderContinue){
        self.suborder.waitStartTime = resultData.data[@"waitStartTime"];
        self.suborder.orderState = CharterOrderStatusPrepare;
        [self setupUI];
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}


- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    FNPushProccessType type = [userInfo[kProccessType] integerValue];
    NSString *suborderId = userInfo[@"orderId"];
    
    if (type == FNPushProccessType_CharterOrderGrab) {
        [self requestSuborderDetail:self.suborder.subOrderId withLoadingMsg:nil];
    }else if (type == FNPushProccessType_CharterOrderTimeout){
        if ([suborderId isEqualToString:self.suborder.subOrderId]) {
            [self setupTimeout:YES];
        }
    }
}
- (void)applicationDidResume{
    [self requestSuborderDetail:self.suborder.subOrderId withLoadingMsg:nil];
}
@end

@implementation CharterTravelStateGrabbedViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyBoard instantiateViewControllerWithIdentifier:@"CharterTravelStateGrabbedViewController"];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"订单确认";
}

- (void)setupUI{
    [super setupUI];
    _startIndex = [[NSDate date] timeIntervalSinceDate:self.suborder.grapTime];
    self.lblTimer.text = [NSString stringWithFormat:@"%@:%@", @(_startIndex / 60), @(_startIndex % 60)];
    [self startTimer];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSegueWithIdentifier:@"ShowCharterPayTip" sender:self.suborder];
    
}
#pragma mark - Timer
- (void)startTimer{
    if (_timer) {
        [self stopTimer];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}
- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}
- (void)handleTimer:(NSTimer *)timer{
    if (_startIndex > 30 * 60) {
        [self stopTimer];
        //        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    _startIndex++;
    self.lblTimer.text = [NSString stringWithFormat:@"%02d:%02d", _startIndex / 60, _startIndex % 60];
    
}
#pragma mark - Actions
- (IBAction)actionPay:(UIButton *)sender {
    CharterPayViewController *payVC = [CharterPayViewController instanceFromStoryboard];
    payVC.suborderItem = self.suborder;
    [self.navigationController pushViewController:payVC animated:YES];
}

- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
    NSInteger proccessType = [userInfo[kProccessType] integerValue];
    if (proccessType == FNPushProccessType_CharterPayFeedback) {
        
    }else if(proccessType == FNPushProccessType_CharterOrderPayTimeout){
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowCharterPayTip"]) {
        ((CharterDetailPayTipsViewController *)segue.destinationViewController).suborder = self.suborder;
    }
}
@end





@implementation CharterTravelStateWaitForPayViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CharterTravelStateWaitForPayViewController"];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"付款中...";
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshItem:)];
    self.navigationItem.rightBarButtonItem = barItem;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestSuborderDetail];
}
#pragma mark - Request Methods
- (void)requestSuborderDetail{
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterSubOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId": self.suborder.subOrderId};
    }];
}
#pragma mark - Actions
- (void)actionRefreshItem:(UIBarButtonItem *)barItem{
    [self requestSuborderDetail];
}
- (IBAction)actionCall:(UIButton *)sender {
    NSString *s = [NSString stringWithFormat:@"tel://%@", [sender titleForState:UIControlStateNormal]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:s]];
}
#pragma mark - Callback

- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_CharterSubOrderDetail) {
        NSDictionary *order = resultData.data[@"order"];
        CharterSuborderItem *newOrder = [[CharterSuborderItem alloc]initWithDictionary:order];
        if ([self.suborder.subOrderId isEqualToString:newOrder.subOrderId]) {
            self.suborder = newOrder;
        }
        [self setupUI];
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

@end


@interface CharterTravelStateRefundViewController (){
    NSArray *_data;
}
@property (weak, nonatomic) IBOutlet UILabel *lblRefundTime;
@property (weak, nonatomic) IBOutlet UILabel *lblRefundCharge;
@property (weak, nonatomic) IBOutlet UILabel *lblRefundDesc;

@end
@implementation CharterTravelStateRefundViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CharterTravelStateRefundViewController"];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"已取消订单";
    [self updateUI];
}
- (void)updateUI{
    self.lblRefundTime.text = [self.suborder.refundTime timeStringByFormat:@"MM月dd日 HH:mm"];
    self.lblRefundCharge.text = [NSString stringWithFormat:@"%@元", @((self.suborder.realPay - self.suborder.refundTotal)/100)];
    self.lblRefundDesc.text = [NSString stringWithFormat:@"%@", self.suborder.refundDesc];
}
- (NSArray *)data{
    if (!_data) {

        NSMutableArray *temp = [NSMutableArray array];
        NSString *timeFormat = @"MM月dd日 HH:mm";
        [temp addObject:@{@"title":@"用车时间", @"content":[NSString stringWithFormat:@"%@-%@", [self.suborder.startingTime timeStringByFormat:timeFormat], [self.suborder.returnTime timeStringByFormat:timeFormat]]}];
        [temp addObject:@{@"title":@"车辆信息", @"content":[NSString stringWithFormat:@"%@", self.suborder.bus.description]}];
        [temp addObject:@{@"title":@"里程", @"content":[NSString stringWithFormat:@"%.02fKM", self.suborder.kilometers]}];
        [temp addObject:@{@"title":@"起始地", @"content":[NSString stringWithFormat:@"%@", self.suborder.starting.name]}];
        [temp addObject:@{@"title":@"目的地", @"content":[NSString stringWithFormat:@"%@", self.suborder.destination.name]}];
        [temp addObject:@{@"title":@"订单费用", @"content":[NSString stringWithFormat:@"%@元", @(self.suborder.price / 100)]}];
        _data = [NSArray arrayWithArray:temp];
    }
    return _data;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self data].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CharterCancelTravelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CharterCancelTravelCell"];
    if (cell == nil) {
        cell = [[CharterCancelTravelCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CharterCancelTravelCell"];
    }
    NSDictionary *dic = [self data][indexPath.row];
    cell.lblTitle.text = dic[@"title"];
    cell.lblDetail.text = dic[@"content"];
    return cell;
}
@end