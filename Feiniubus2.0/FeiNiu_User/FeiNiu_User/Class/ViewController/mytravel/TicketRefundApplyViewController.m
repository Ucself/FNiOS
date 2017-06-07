//
//  TicketRefundApplytViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/28.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "TicketRefundApplyViewController.h"
#import "RefundApplyViewCell.h"
#import "RefundTipsView.h"
#import "PushNotificationAdapter.h"
#import "Ticket.h"


@interface TicketRefundApplyViewController () <UserCustomAlertViewDelegate>
{
    NSString *channel;     //退款渠道
    float counterFee;      //每张手续费
    float refundAmount;    //每张票可退金额
    
    BOOL bHasApplyNotify;  //是否收到申请推送
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *labelCounterFee;
@property (weak, nonatomic) IBOutlet UILabel *labelCounterFeeTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelRefundTotal;
@end

@implementation TicketRefundApplyViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self requestRefundRule];
    //[self handleTickets];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refundApplyNotification:) name:FNPushType_BusTicketsRefundApply object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - notification method
-(void)refundApplyNotification:(NSNotification*)notification
{
    if (!bHasApplyNotify) {
        bHasApplyNotify = YES;
        int success = [[notification.object objectForKey:@"success"] intValue];
        if (success == 1) {
            //退款申请成功
            [self refundApplySuccessHandle];
            
        }
        else {
            [self showTipsView:@"退款申请提交失败，请重试"];
        }
        
        [self stopWait];
    }
}

#pragma mark -
-(void)resetUI
{
    __block int validCount = 0;  //已选票数据
    __block int halfCount = 0;   //已选半价票数量
    [self.arTickets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Ticket *ticket = (Ticket*)obj;
        if (ticket.flag) {
            validCount++;
            if (ticket.ticketType == EmTicketType_Half) {
                halfCount++;
            }
        }
        
    }];
    
    NSString *strDate = [_orderTicket.date stringByReplacingOccurrencesOfString:@"00:00:00" withString:_orderTicket.time];
    NSDate *now = [NSDate date];
    NSDate *ticketDate = [DateUtils dateFromString:strDate format:@"yyyy-MM-dd HH:mm"];

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comp1 = [calendar components:NSCalendarUnitDay fromDate:now];
    NSDateComponents* comp2 = [calendar components:NSCalendarUnitDay fromDate:ticketDate];
    
    float feeTotal = 0.0;
    float reRdfundtotal = 0.0;
    if ([comp1 day] == [comp2 day]) {
        NSTimeInterval interval = [ticketDate timeIntervalSinceDate:now];
        if (interval <= 7200) {
            //两小时以内正常价
            feeTotal = validCount*counterFee;
            reRdfundtotal = validCount*refundAmount - halfCount*((refundAmount+counterFee)/2);
        }
        else {
            //距开车两小时以外, 半票退款手续费减半
            feeTotal = validCount*counterFee - halfCount*counterFee/2;
            reRdfundtotal = validCount*refundAmount - halfCount*((refundAmount+counterFee)/2) + halfCount*counterFee/2;
        }
    }
    else {
        //距开车两小时以外, 半票退款手续费减半
        feeTotal = validCount*counterFee - halfCount*counterFee/2;
        reRdfundtotal = validCount*refundAmount - halfCount*((refundAmount+counterFee)/2) + halfCount*counterFee/2;
    }
    
    
    self.labelCounterFee.text = [NSString stringWithFormat:@"%.2f元/人", counterFee];
    self.labelCounterFeeTotal.text = [NSString stringWithFormat:@"%.2f元", feeTotal];
    self.labelRefundTotal.text = [NSString stringWithFormat:@"%.2f元", reRdfundtotal];
}

//处理车票
-(void)handleTickets
{
    [self.arTickets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Ticket *ticket = (Ticket*)obj;
        if (ticket.ticketState == EmTicketStatus_NotTake) {    //未取票
            ticket.flag = NO;
        }
    }];
}

-(void)requestRefundRule
{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketRefundRule params:^(NetParams *params) {
        params.data = @{@"orderId": self.orderTicket.orderId};
    }];
}

-(void)refundApplySuccessHandle
{
    //重取车票
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderTickets params:^(NetParams *params) {
        params.data = @{@"orderId":self.orderTicket.orderId};
    }];
    
    //通知上页刷新
    if ([self.delegate respondsToSelector:@selector(ticketRefundApplyRefresh)]) {
        [self.delegate ticketRefundApplyRefresh];
    }
    
    [RefundTipsView showInfoView:self.view tips:@"您的车票已申请成功!" done:^(){
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arTickets.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Ticket *ticket = self.arTickets[indexPath.row];
    if (ticket.ticketState == EmTicketStatus_NotTake) {    //未取票
        RefundApplyViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.isSelect = !cell.isSelect;
        ticket.flag = cell.isSelect;
    }
    
    [self resetUI];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RefundApplyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ticketCellIdent"];
    
    Ticket *ticket = self.arTickets[indexPath.row];
    cell.labelName.text = ticket.userName;
    cell.labelIdCard.text = [NSString stringWithFormat:@"身份证:%@", ticket.userIdCardNumber];
    
    cell.isSelect = ticket.flag;
    
    if (ticket.ticketType == EmTicketType_Half) {
        cell.labelType.text = @"儿童/军残半价票";
    }
    else {
        cell.labelType.text = @"";
    }
    
    switch (ticket.ticketState) {
        case EmTicketStatus_HasTake:
        {
            cell.labelState.text = @"已取票";
            cell.labelState.textColor = [UIColor grayColor];
            cell.img.hidden = YES;
        }
            break;
        case EmTicketStatus_NotTake:
        {
            cell.labelState.text = @"未取票";
            cell.labelState.textColor = UIColor_DefGreen;
            cell.img.hidden = NO;
        }
            break;
        case EmTicketStatus_Redunnd:
        {
            cell.labelState.text = @"已退款";
            cell.labelState.textColor = [UIColor grayColor];
            cell.img.hidden = YES;
        }
            break;
        case EmTicketStatus_refunding:
        {
            cell.labelState.text = @"退款中";
            cell.labelState.textColor = UIColor_DefOrange;
            cell.img.hidden = YES;
        }
            break;
        case EmTicketStatus_Invalid:
        {
            cell.labelState.text = @"未生效";
            cell.labelState.textColor = [UIColor redColor];
            cell.img.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark-
- (IBAction)btnCommitClick:(id)sender {
    UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"退款申请" message:@"您确定需要退款吗?" delegate:self buttons:@[ @"取消",@"确定"]];
    [alertView showInView:self.view];
}

- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    if (btnIndex == 1) {
        NSMutableArray *tickets = [[NSMutableArray alloc] init];
        [self.arTickets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Ticket *ticket = (Ticket*)obj;
            if (ticket.flag) {
                [tickets addObject:ticket.ticketId];
            }
        }];
        
        if (tickets.count == 0) {
            [self showTipsView:@"请选择要退款的客票"];
            return;
        }
        
        bHasApplyNotify = NO;
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_TicketRefund params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            params.data = @{@"orderId": self.orderTicket.orderId,
                            @"tickets": tickets};
        }];
    }
}

#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    
    [super httpRequestFinished:notification];
    ResultDataModel *result = (ResultDataModel *)notification.object;
    
    if (result.type == EmRequestType_TicketRefundRule) {
        [self stopWait];
        
        counterFee = [result.data[@"counterFee"] intValue]/100.0;
        refundAmount = [result.data[@"refundAmount"] intValue]/100.0;
        channel = result.data[@"channel"];
        [self resetUI];

    }
    else if (result.type == EmRequestType_TicketRefund) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!bHasApplyNotify) {
                //未收到推送, 查询退款信息
                bHasApplyNotify = YES;
                [self.arTickets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    Ticket *ticket = (Ticket*)obj;
                    if (ticket.flag) {
                        [NetManagerInstance sendRequstWithType:EmRequestType_TicketRefundPace params:^(NetParams *params) {
                            params.data = @{@"ticketId": ticket.ticketId};
                        }];
                    }
                }];
            }
        });
    }
    else if (result.type == EmRequestType_TicketOrderTickets) {
        [self stopWait];
        self.arTickets = [Ticket mj_objectArrayWithKeyValuesArray:result.data];
        [self.tableView reloadData];
        [self resetUI];
    }
    else if (result.type == EmRequestType_TicketRefundPace) {
        
        [self refundApplySuccessHandle];
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification{
    return [super httpRequestFailed:notification];
}
@end
