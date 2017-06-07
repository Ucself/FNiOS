//
//  UnionPayViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UnionPayViewController.h"
#import "PingPPayUtil.h"
#import "CharterTravelStateViewController.h"
#import "CharterOrderItem.h"

@interface UnionPayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;

@end
@implementation UnionPayCell



@end


@interface UnionPayViewController ()<UITableViewDataSource, UITableViewDelegate>{
    NSArray *_data;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
@implementation UnionPayViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"对公转账";
}
- (NSArray *)data{
    if (!_data) {
        _data = @[@{@"icon":@"pay_icon_boc", @"title":@"中国银行", @"number":@"648508423052305823"},
                  @{@"icon":@"pay_icon_cmbc", @"title":@"招商银行", @"number":@"648508423052305823"},
                  @{@"icon":@"pay_icon_ccb", @"title":@"建设银行", @"number":@"648508423052305823"},
                  @{@"icon":@"pay_icon_bocom", @"title":@"交通银行", @"number":@"648508423052305823"},
                  @{@"icon":@"pay_icon_icbc", @"title":@"工商银行", @"number":@"648508423052305823"},
                  ];
    }
    return _data;
}
#pragma mark - Actions
- (IBAction)actionPay:(UIButton *)sender {
    if (!self.orderId || self.orderId.length <= 0) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_PayOfflineTransfer params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        
        NSString *coupon = self.couponId ? self.couponId : @"0";
        params.data = @{@"chargeType":  @(self.chargeType),
                        @"OrderNo":     self.orderId,
                        @"CouponId":    coupon};
    }];
}

#pragma mark - HTTP Response
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    
    if (resultData.requestType == FNUserRequestType_PayOfflineTransfer) {
        if (0 == resultData.resultCode) {
            CharterTravelStateWaitForPayViewController *vc = [CharterTravelStateWaitForPayViewController instanceFromStoryboard];
            CharterSuborderItem *item = [[CharterSuborderItem alloc]init];
            item.subOrderId = self.orderId;

            vc.suborder = item;
            NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
            [vcs removeLastObject];
            [vcs removeLastObject];
            [vcs addObject:vc];
            [self.navigationController setViewControllers:vcs animated:YES];
        }else{
            [self showTip:resultData.message WithType:FNTipTypeFailure];
        }
    }
}

#pragma mark - UITableViewDelegate & datasoruce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self data].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"UnionPayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSDictionary *dic = [self data][indexPath.row];
    cell.textLabel.text = dic[@"title"];
    cell.detailTextLabel.text = dic[@"number"];
    cell.imageView.image = [UIImage imageNamed:dic[@"icon"]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}
@end
