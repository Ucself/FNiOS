//
//  CharterCancelViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/29.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterCancelViewController.h"
#import "CharterOrderItem.h"
#import "CharterCancelTravelCell.h"
#import "UserWebviewController.h"

@interface CharterCancelViewController ()<UITableViewDataSource, UITableViewDelegate>{
    NSArray *_data;
}
@property (weak, nonatomic) IBOutlet UILabel *lblRefund;
@property (nonatomic, assign) NSInteger refundPrice;
@end
@implementation CharterCancelViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CharterCancelViewController"];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"取消订单";
    [self requestRefund];
}
- (NSArray *)data{
    if (!_data) {
        NSMutableArray *temp = [NSMutableArray array];
        NSString *timeFormat = @"MM月dd日 HH:mm";
        [temp addObject:@{@"title":@"用车时间", @"content":[NSString stringWithFormat:@"%@-%@", [self.charterOrder.startingTime timeStringByFormat:timeFormat], [self.charterOrder.returnTime timeStringByFormat:timeFormat]]}];
        [temp addObject:@{@"title":@"车辆信息", @"content":[NSString stringWithFormat:@"%@", self.charterOrder.bus.description]}];
        [temp addObject:@{@"title":@"里程", @"content":[NSString stringWithFormat:@"%.02fKM", self.charterOrder.kilometers]}];
        [temp addObject:@{@"title":@"起始地", @"content":[NSString stringWithFormat:@"%@", self.charterOrder.starting.name]}];
        [temp addObject:@{@"title":@"目的地", @"content":[NSString stringWithFormat:@"%@", self.charterOrder.destination.name]}];
        [temp addObject:@{@"title":@"订单费用", @"content":[NSString stringWithFormat:@"%@元", @(self.charterOrder.price / 100)]}];
        _data = [NSArray arrayWithArray:temp];
    }
    return _data;
}
- (IBAction)actionViewRule:(UIButton *)sender {
    UserWebviewController *webVC = [[UserWebviewController alloc]initWithUrl:HTMLAddr_CharterRefundRule];
    [self.navigationController pushViewController:webVC animated:YES];
}
- (IBAction)actionSubmit:(UIButton *)sender {
    [self requestCancelCharterSubOrder];
}

- (void)setRefundPrice:(NSInteger)refundPrice{
    _refundPrice = refundPrice;
    self.lblRefund.text = [NSString stringWithFormat:@"%@元", @(refundPrice / 100)];
}
#pragma mark - RequestMethods
- (void)requestRefund{
    if (!self.charterOrder || !self.charterOrder.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderRefundPrice params:^(NetParams *params) {
        params.data = @{@"subOrderId":self.charterOrder.subOrderId};
    }];
}
- (void)requestCancelCharterSubOrder{
    if (!self.charterOrder || !self.charterOrder.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderCancel params:^(NetParams *params) {
        params.method = EMRequstMethod_DELETE;
        params.data = @{@"subOrderId":self.charterOrder.subOrderId};
    }];
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

#pragma mark - HTTP
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_CharterOrderRefundPrice) {
        self.refundPrice = [resultData.data[@"price"] integerValue];
    }else if (type == FNUserRequestType_CharterOrderCancel) {
        // 取消订单，返回上一级界面
        if (resultData.resultCode == 0) {
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
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        //        [self showTip:@"成功取消订单" WithType:FNTipTypeSuccess];
    }
}
@end
