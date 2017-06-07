//
//  CarpoolRefundOrderDetailViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolRefundOrderDetailViewController.h"
#import "UIColor+Hex.h"
#import "CarpoolOrderItem.h"
#import "CharterCancelTravelCell.h"

@interface CarpoolRefundOrderDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *data;

@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblDestinationName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnKefu;
@property (weak, nonatomic) IBOutlet UIButton *btnRefund;
@property (weak, nonatomic) IBOutlet UILabel *lblTips;

@end

@implementation CarpoolRefundOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCarpoolOrderItem:(CarpoolOrderItem *)carpoolOrderItem{
    _carpoolOrderItem = carpoolOrderItem;
    if (carpoolOrderItem.payStatus < CarpoolOrderPayStatusRefundDone) {
        self.btnRefund.hidden = YES;
        self.lblTips.text = @"尊敬的乘客，您申请的退款已经提交，最多7个工作日就将退款返回到您的账户！";
        self.btnKefu.hidden = NO;
        self.btnRefund.hidden = YES;
    }else{
        self.btnRefund.hidden = YES;
        self.lblTips.text = @"尊敬的乘客，您申请的退款已经退到您的账户上。如有疑问请联系客服人员。";
        self.btnKefu.hidden = YES;
        self.btnRefund.hidden = NO;
    }

    self.lblStartName.text = carpoolOrderItem.startName;
    self.lblDestinationName.text = carpoolOrderItem.destinationName;
    [self loadData];
}
#pragma mark -
- (NSString *)keyTitle{
    return @"title";
}
- (NSString *)keyTitleColor{
    return @"titleColor";
}
- (NSString *)keyDetail{
    return @"detail";
}
- (void)loadData{
    NSString *startTime = @"";
    if (self.carpoolOrderItem.type == CarpoolBusTypeGundong ||
        self.carpoolOrderItem.type == CarpoolBusTypeGundong2) {
        startTime = [NSString stringWithFormat:@"%@ %@-%@", [self.carpoolOrderItem.departure timeStringByFormat:@"yyyy-MM-dd"], self.carpoolOrderItem.startTime, self.carpoolOrderItem.endTime];
    }else{
        startTime = [NSString stringWithFormat:@"%@ %@", [self.carpoolOrderItem.departure timeStringByFormat:@"yyyy-MM-dd"], self.carpoolOrderItem.departureTime];
    }
    _data =
    @[
      @{[self keyTitle]:@"发车时间", [self keyTitleColor]:@(0xB4B4B4), [self keyDetail]:startTime},
      @{[self keyTitle]:@"发车地点", [self keyTitleColor]:@(0xB4B4B4), [self keyDetail]:self.carpoolOrderItem.station},
      @{[self keyTitle]:@"取消票数", [self keyTitleColor]:@(0xB4B4B4), [self keyDetail]:[NSString stringWithFormat:@"%@张",@(self.carpoolOrderItem.tickets.count)]},
      @{[self keyTitle]:@"退票时间", [self keyTitleColor]:@(0xB4B4B4), [self keyDetail]:self.carpoolOrderItem.refundTime},
      @{[self keyTitle]:@"目的地", [self keyTitleColor]:@(0xB4B4B4), [self keyDetail]:self.carpoolOrderItem.destinationName},
      @{[self keyTitle]:@"违约费", [self keyTitleColor]:@(0xB4B4B4), [self keyDetail]:[NSString stringWithFormat:@"%.1f元", (self.carpoolOrderItem.price - self.carpoolOrderItem.refundPrice) / 100.f]},
      @{[self keyTitle]:@"实际退费", [self keyTitleColor]:@(0x666666), [self keyDetail]:[NSString stringWithFormat:@"%.1f元", self.carpoolOrderItem.refundPrice / 100.f]},
      
      ];
    [self.tableView reloadData];
}
- (IBAction)actionRefund:(UIButton *)sender {
    [self takeAPhoneCallTo:HOTLINE];
}
- (IBAction)actionHotLine:(UIButton *)sender {
    [self takeAPhoneCallTo:HOTLINE];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    CharterCancelTravelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarpoolCancelTravelCell"];
    NSDictionary *dic = _data[indexPath.row];
    cell.lblTitle.text = dic[[self keyTitle]];
    cell.lblTitle.textColor = [UIColor colorWithHex:[dic[[self keyTitleColor]] integerValue]];
    
    if (![dic[[self keyDetail]] isKindOfClass:[NSNull class]]) {
       cell.lblDetail.text = dic[[self keyDetail]];
    }
    
    
    if (indexPath.row == _data.count - 1) {
        cell.lblDetail.textColor = [UIColor colorWithHex:GloabalTintColor];
    }else{
        cell.lblDetail.textColor = [UIColor colorWithHex:0x333333];
    }
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
