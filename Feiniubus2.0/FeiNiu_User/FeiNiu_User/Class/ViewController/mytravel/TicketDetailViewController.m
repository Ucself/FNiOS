//
//  TicketDetailViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "UserTicketsViewController.h"
#import "ShuttleStationViewCotroller.h"
#import "WebContentViewController.h"
#import "CreateOrderHeadView.h"
#import "CreateOrderFootView.h"
#import "UINavigationView.h"
#import "PayTicketsViewController.h"
#import "TicketRefundApplyViewController.h"
#import "TicketRefundProcessViewController.h"
#import "OrderTicket.h"
#import "Ticket.h"

@interface TicketDetailViewController () <CreateOrderFootViewDelegate, CreateOrderHeadViewDelegate, UserCustomAlertViewDelegate>
{
    BOOL needRefresh;
}
@property (weak, nonatomic) IBOutlet UINavigationView *navView;


@property (weak, nonatomic) IBOutlet UIView *payView;
@property (weak, nonatomic) IBOutlet UILabel *labelPayTips;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consPayViewHeight;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consBtmViewHeight;

@property (nonatomic,strong) CreateOrderHeadView *headView;
@property (nonatomic,strong) CreateOrderFootView *footView;


//可操作button
@property (nonatomic, strong) UIButton *btnPay;
@property (nonatomic, strong) UIButton *btnRefund;
@property (nonatomic, strong) UIButton *btnCallFeiniu;

@property (nonatomic, strong) NSTimer *timer;


@property (nonatomic, strong) OrderTicket *order;
@property (nonatomic, strong) NSArray     *arTickets;    //订单中车票数组
@end

@implementation TicketDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    self.tableView.hidden = YES;
    [self requestOrderDetail];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

-(void)dealloc
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (needRefresh) {
        needRefresh = NO;
        [self requestOrderDetail];
    }
}

#pragma mark -
- (void)initUI
{
    //tableView 头
    NSArray *headViewArray = [[NSBundle mainBundle] loadNibNamed:@"CreateOrderHeadView" owner:self options:nil];
    if (headViewArray.count >0) {
        _headView = headViewArray[0];
    }
    _headView.delegate = self;
    //日期
    NSDate *tickDatte = [NSDate date];//[DateUtils stringToDate:@"2016-08-11"];
    _headView.dateLabel.text = [DateUtils formatDate:tickDatte format:@"yyyy-MM-dd"];
    _headView.startCityLabel.text = @"";
    _headView.startSiteLabel.text = @"";
    _headView.typeLabel.text = @"滚动"; //_queryTicketResultModel.type == 3? @"滚动班" : @"定时班";   //2定时，3滚动
    NSDate *tempTime = [DateUtils stringToDate:@"00:00"];
    if (_order.type == 3) {
        _headView.timeLabel.text = [[NSString alloc] initWithFormat:@"%@前有效",[DateUtils formatDate:tempTime format:@"HH:ss"]];
    }
    else{
        _headView.timeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:tempTime format:@"HH:ss"]];
    }
    _headView.endCityLabel.text = @"";//_queryTicketResultModel.endCity;
    _headView.endSiteLabel.text = @"";//_queryTicketResultModel.endSite;
    _headView.priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元", 120.0];
    
    //tableView尾部
    NSArray *footViewArray = [[NSBundle mainBundle] loadNibNamed:@"CreateOrderFootView" owner:self options:nil];
    if (footViewArray.count >0) {
        _footView = footViewArray[0];
    }
    _footView.delegate = self;
    _footView.viewAddrBook.hidden = YES;
    _footView.phoneNumberLabel.userInteractionEnabled = NO;
}



-(void)requestOrderDetail
{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId":self.orderId};
    }];
}
//取车票列表
-(void)requestTickets
{
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderTickets params:^(NetParams *params) {
        params.data = @{@"orderId":self.orderId};
    }];
}

-(void)resetOrderStatus
{
    switch (self.order.orderState) {
        case EmOrderTicketStatus_Refunding:
        {
            [self.navView setTitle:@"退票中"];
            [self.navView setRightTitle:nil];
            
            self.consPayViewHeight.constant = 0;
            self.consBtmViewHeight.constant = 0;
        }
            break;
        case EmOrderTicketStatus_RefundFinished:
        {
            [self.navView setTitle:@"已退票"];
            [self.navView setRightTitle:nil];
            
            self.consPayViewHeight.constant = 0;
            self.consBtmViewHeight.constant = 0;
        }
            break;
        case EmOrderTicketStatus_Cancelled:
        {
            [self.navView setTitle:@"订单取消"];
            [self.navView setRightTitle:nil];
            
            self.consPayViewHeight.constant = 0;
            self.consBtmViewHeight.constant = 0;
        }
            break;
        case EmOrderTicketStatus_Finished:
        {
            [self.navView setTitle:@"订单详情"];
            [self.navView setRightTitle:nil];
            
            self.consPayViewHeight.constant = 0;
            
            
            //{ 判断是否显示退票申请
            BOOL showRefund = YES;
            __block int count = 0;
            [self.arTickets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Ticket *ticket = (Ticket*)obj;
                if (ticket.ticketState == EmTicketStatus_Redunnd || ticket.ticketState == EmTicketStatus_refunding) {
                    count++;
                }
            }];
            
            if (self.arTickets.count == count) {
                showRefund = NO;
            }
            //}
            
            
            if (showRefund) {
//                self.consBtmViewHeight.constant = 110;
//                
//                UIButton *btn = self.btnCallFeiniu;
//                [self.bottomView addSubview:btn];
//                [btn makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(self.bottomView.left).offset(10);
//                    make.top.equalTo(self.bottomView.top).offset(10);
//                    make.right.equalTo(self.bottomView.right).offset(-10);
//                    make.height.equalTo(40);
//                }];
                
                self.consBtmViewHeight.constant = 60;
                UIButton *btn = self.btnRefund;
                [self.bottomView addSubview:btn];
                [btn makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.bottomView.left).offset(10);
                    make.top.equalTo(self.bottomView.top).offset(10);
                    make.right.equalTo(self.bottomView.right).offset(-10);
                    make.height.equalTo(40);
                }];
            }
//            else {
//                self.consBtmViewHeight.constant = 60;
//                
//                UIButton *btn = self.btnCallFeiniu;
//                [self.bottomView addSubview:btn];
//                [btn makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(self.bottomView.left).offset(10);
//                    make.top.equalTo(self.bottomView.top).offset(10);
//                    make.right.equalTo(self.bottomView.right).offset(-10);
//                    make.height.equalTo(40);
//                }];
//            }
            
        }
            break;
        case EmOrderTicketStatus_WaitPay:
        {
            [self.navView setTitle:@"等待支付"];
            [self.navView setRightTitle:@"取消订单"];
            
            self.consPayViewHeight.constant = 20;
            //elf.labelPayTips.text = @"请在12:33之前支付订单, 总计100元, 超时将自动取消订单";
            self.consBtmViewHeight.constant = 60;
            

            NSDate *deadline = [DateUtils addDate:[DateUtils stringToDate:self.order.createTime] interval:30*60];
            NSString *strDeadline = [DateUtils formatDate:deadline format:@"HH:mm"];
            NSString *strTips = [NSString stringWithFormat:@"请在%@之前支付订单, 总计%.2f元, 超时将自动取消订单", strDeadline, self.order.totalAmount/100];
            
            MyRange *range1 = [[MyRange alloc] init];
            range1.location = 2;
            range1.length   = 5;
            
            MyRange *range2  = [[MyRange alloc] init];
            range2.location = 17;
            range2.length   = [strTips rangeOfString:@"元"].location - range2.location +1;
            
            NSAttributedString *attribute  = [NSString hintMainString:strTips
                                                        rangs:[@[range1, range2] mutableCopy]
                                                 defaultColor:[UIColor whiteColor]
                                                  changeColor:UIColor_DefOrange];
            self.labelPayTips.attributedText = attribute;
            
            UIButton *btn = self.btnPay;
            [self.bottomView addSubview:btn];
            [btn makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bottomView.left).offset(10);
                make.top.equalTo(self.bottomView.top).offset(10);
                make.right.equalTo(self.bottomView.right).offset(-10);
                make.height.equalTo(40);
            }];
        }
            break;
            
        default:
            break;
    }
}

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

}

#pragma mark- buttons
-(UIButton *)btnPay
{
    if (!_btnPay) {
        _btnPay = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnPay setTitle:@"去支付" forState:UIControlStateNormal];
        [_btnPay setBackgroundColor:UIColor_DefOrange];
        _btnPay.layer.cornerRadius = 5;
        [_btnPay addTarget:self action:@selector(btnPayClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPay;
}

-(UIButton *)btnRefund
{
    if (!_btnRefund) {
        _btnRefund = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnRefund setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnRefund setTitle:@"申请退票" forState:UIControlStateNormal];
        [_btnRefund setBackgroundColor:UIColor_DefOrange];
        _btnRefund.layer.cornerRadius = 5;
        [_btnRefund addTarget:self action:@selector(btnRefundClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRefund;
}

-(UIButton *)btnCallFeiniu
{
    if (!_btnCallFeiniu) {
        _btnCallFeiniu = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnCallFeiniu setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnCallFeiniu setTitle:@"呼叫飞牛" forState:UIControlStateNormal];
        [_btnCallFeiniu setBackgroundColor:UIColor_DefOrange];
        _btnCallFeiniu.layer.cornerRadius = 5;
        [_btnCallFeiniu addTarget:self action:@selector(btnCallFeiniuClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCallFeiniu;
}

-(void)btnPayClick
{
    PayTicketsViewController *c = [PayTicketsViewController instanceWithStoryboardName:@"Tickets"];
    c.orderTicket = self.order;
    [self.navigationController pushViewController:c animated:YES];
}

-(void)btnRefundClick
{
    //[self performSegueWithIdentifier:@"toRefundApply" sender:nil];
    TicketRefundApplyViewController *controller = [TicketRefundApplyViewController instanceWithStoryboardName:@"TicketsOrder"];
    controller.arTickets = self.arTickets;
    controller.orderTicket = self.order;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)btnCallFeiniuClick
{
    ShuttleStationViewCotroller *c = [ShuttleStationViewCotroller instanceWithStoryboardName:@"Bus"];
    c.shuttleStation = ShuttleStationTypeBus;
//    LocationObj *location = [[LocationObj alloc] init];
//    location.name = self.order.startSite;
//    c.defaultLocation = location;
    [self.navigationController pushViewController:c animated:YES];
    
}

//显示车票二维码
-(void)headViewQRCodeClickView
{
    UserTicketsViewController *ticketsVC = [UserTicketsViewController instanceWithStoryboardName:@"TicketsOrder"];
    ticketsVC.tickets = self.arTickets;
    [ticketsVC showInViewController:self.navigationController];
}

-(void)ticketsInstructionsClick
{
    //此处进入取票说明页面
    WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
    webViewController.vcTitle = @"取票退票说明";
    webViewController.urlString = HTMLAddr_CharterRefundRule;
    [self.navigationController pushViewController:webViewController animated:YES];
}

//
-(void)navigationViewRightClick
{
    UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"确定取消订单吗?" message:@"" delegate:self buttons:@[@"不取消",@"确定取消"]];
    //[UserCustomAlertView alertViewWithTitle:@"取消订单" message:@"您确定取消订单吗?" delegate:self];
    if ([alert viewWithTag:1001]) {
        UILabel *titleLabel = [alert viewWithTag:1001];
        titleLabel.numberOfLines = 0;
        [titleLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
        }];
    }
    alert.tag = 101;
    [alert showInView:self.view];
}

- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    if (alertView.tag == 101) {
        if (btnIndex == 1) {
            [self startWait];
            [NetManagerInstance sendRequstWithType:EmRequestType_TicketCancel params:^(NetParams *params) {
                params.method = EMRequstMethod_POST;
                params.data = @{@"orderId": self.order.orderId};
            }];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    UIViewController *dest = [segue destinationViewController];
    if ([dest isKindOfClass:[TicketRefundApplyViewController class]]) {
        TicketRefundApplyViewController *controller = (TicketRefundApplyViewController*)dest;
        controller.arTickets = self.arTickets;
        controller.orderTicket = self.order;
        controller.delegate = self;
    }
    else if ([dest isKindOfClass:[TicketRefundProcessViewController class]]) {
        TicketRefundProcessViewController *controller = (TicketRefundProcessViewController*)dest;
        controller.ticket = sender;
    }
}

//退款后刷新页面
-(void) ticketRefundApplyRefresh
{
    needRefresh = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
}


#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.order.orderState == EmOrderTicketStatus_Cancelled) {
        return 140;
    }
    return 172;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 410;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.order.orderState == EmOrderTicketStatus_Cancelled) {
        return 0;
    }
    return self.arTickets.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headView;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _footView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.order.orderState == EmOrderTicketStatus_WaitPay) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"contactPeopleCell"];
        UIView *contentView = [cell viewWithTag:100];
        UILabel *labelName = [contentView viewWithTag:101];
        UILabel *labelIdcard = [contentView viewWithTag:102];
        UILabel *labelType = [contentView viewWithTag:103];
        
        Ticket *ticket = self.arTickets[indexPath.row];
        labelName.text = ticket.userName;
        labelIdcard.text = ticket.userIdCardNumber;
        
        if (ticket.ticketType == EmTicketType_Half) {
            labelType.text = @"儿童/军残半价票";
        }
        else {
            labelType.text = @"";
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ticketCell"];
        UIView *contentView = [cell viewWithTag:100];
        UILabel *labelName = [contentView viewWithTag:101];
        UILabel *labelIdcard = [contentView viewWithTag:102];
        UILabel *labelType = [contentView viewWithTag:103];
        UILabel *labelState = [contentView viewWithTag:104];
        UIView *arror = [contentView viewWithTag:105];
        
        Ticket *ticket = self.arTickets[indexPath.row];
        labelName.text = ticket.userName;
        labelIdcard.text = ticket.serialNumber;
        
        switch (ticket.ticketState) {
            case EmTicketStatus_HasTake:
            {
                labelState.text = @"已取票";
                labelState.textColor = [UIColor grayColor];
                arror.hidden = YES;
            }
                break;
            case EmTicketStatus_NotTake:
            {
                labelState.text = @"未取票";
                labelState.textColor = UIColor_DefGreen;
                arror.hidden = YES;
            }
                break;
            case EmTicketStatus_Redunnd:
            {
                labelState.text = @"已退款";
                labelState.textColor = [UIColor grayColor];
                arror.hidden = YES;
            }
                break;
            case EmTicketStatus_refunding:
            {
                labelState.text = @"退款中";
                labelState.textColor = UIColor_DefOrange;
                arror.hidden = NO;
            }
                break;
            case EmTicketStatus_Invalid:
            {
                labelState.text = @"未生效";
                labelState.textColor = [UIColor redColor];
                arror.hidden = YES;
            }
                break;
                
            default:
                break;
        }
        
        if (ticket.ticketType == EmTicketType_Half) {
            labelType.text = @"儿童/军残半价票";
        }
        else {
            labelType.text = @"";
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.order.orderState != EmOrderTicketStatus_WaitPay) {
        Ticket *ticket = self.arTickets[indexPath.row];
        if (ticket.ticketState == EmTicketStatus_refunding || ticket.ticketState == EmTicketStatus_Redunnd) {
            [self performSegueWithIdentifier:@"toRefunding" sender:ticket];
        }
        else if (ticket.ticketState != EmTicketStatus_Invalid) {
            UserTicketsViewController *ticketsVC = [UserTicketsViewController instanceWithStoryboardName:@"TicketsOrder"];
            ticketsVC.tickets = self.arTickets;
            ticketsVC.selcetIndex = indexPath.row;
            [ticketsVC showInViewController:self.navigationController];
        }
    }
}


#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    
    [super httpRequestFinished:notification];
    ResultDataModel *result = (ResultDataModel *)notification.object;
    
    if (result.type == EmRequestType_TicketOrderDetail) {
        //订单详情
        self.order = [OrderTicket mj_objectWithKeyValues:result.data[@"order"]];
        
        //取车票
        [self requestTickets];
        
        self.tableView.hidden = NO;
        
    }
    else if (result.type == EmRequestType_TicketOrderTickets) {
        //客票列表
        [self stopWait];
        self.arTickets = [Ticket mj_objectArrayWithKeyValuesArray:result.data];
        [self.tableView reloadData];
        
        [self resetOrderStatus];
        [self.headView setOrderInfo:self.order];
        [self.footView setOrderInfo:self.order];
    }
    else if (result.type == EmRequestType_TicketCancel) {
        //取消订单
        [self stopWait];
        
        [self showTip:@"订单取消成功" WithType:FNTipTypeSuccess hideDelay:2];
        [self.navView setRightTitle:nil];
        self.consBtmViewHeight.constant = 0;
        self.consPayViewHeight.constant = 0;
        self.labelPayTips.attributedText = nil;
        [self.navView setTitle:@"订单详情"];
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
        //弹出上一级
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification{
    return [super httpRequestFailed:notification];
}
@end
