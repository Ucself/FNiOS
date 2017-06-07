//
//  TicketRefundViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "TicketRefundProcessViewController.h"

@interface TicketRefundProcessViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelRefundAmount;
@property (weak, nonatomic) IBOutlet UIImageView *imgState;
@property (weak, nonatomic) IBOutlet UILabel *labelHanding;
@property (weak, nonatomic) IBOutlet UILabel *labelSuccess;


@property (strong, nonatomic) NSDictionary *dict;
@end

@implementation TicketRefundProcessViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketRefundPace params:^(NetParams *params) {
        params.data = @{@"ticketId": self.ticket.ticketId};
    }];
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

-(void)resetUI
{
    _labelRefundAmount.text = [NSString stringWithFormat:@"%.2f元", [_dict[@"refundAmount"]intValue]/100.0];
    _labelHanding.text = [NSString stringWithFormat:@"飞牛巴士已将您的退款提交至%@", _dict[@"channel"]];
    _labelSuccess.text = [NSString stringWithFormat:@"飞牛巴士已将您的退款提交至%@", _dict[@"channel"]];
    switch ([_dict[@"state"] intValue]) {
        case 1:        //已申请
        {
            [_imgState setImage:[UIImage imageNamed:@"refundprocess1"]];
        }
            break;
        case 2:        //飞牛巴士处理成功
        {
             [_imgState setImage:[UIImage imageNamed:@"refundprocess2"]];
        }
            break;
        case 3:        //退款成功
        {
             [_imgState setImage:[UIImage imageNamed:@"refundprocess3"]];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)btnNoReciveClick:(id)sender {
    UserCustomAlertView *view = [UserCustomAlertView alertViewWithTitle:@"联系客服" message:@"400-0820-112" delegate:self buttons:@[@"取消",@"呼叫"]];
    [view showInView:self.view];
}

#pragma mark - UserAlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (btnIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://400-0820-112"]];
    }
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"refundTicketCell"];
    UIView *contentView = [cell viewWithTag:100];
    UILabel *lableName = [contentView viewWithTag:101];
    UILabel *lableIdCard = [contentView viewWithTag:102];
    
    if (_dict) {

        lableName.text = _dict[@"name"];
        lableIdCard.text = _dict[@"idCard"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.type == EmRequestType_TicketRefundPace) {
        self.dict = result.data;
        [self resetUI];
        [self.tableView reloadData];
    }

}

- (void)httpRequestFailed:(NSNotification *)notification{
    return [super httpRequestFailed:notification];
}
@end
