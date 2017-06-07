//
//  CarpoolListViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolListViewController.h"
#import "CarpoolOrderItem.h"
#import "TravelListCell.h"
#import "CarpoolTravelingViewController.h"
#import "UIColor+Hex.h"
#import "CarpoolTravelStateViewController.h"
#import "CarpoolTravelCancelingViewController.h"

#define StateRedColor 0xFF7043
#define StateYellowColor 0xFFB84D
#define StateGreenColor 0x1EC18E
#define StateGrayColor 0xB4B4B4


@interface CarpoolListViewController ()

@end

@implementation CarpoolListViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - RequestMethods
- (void)deleteAction
{
    NSArray *array = [NSArray arrayWithArray:[self.selectDict allValues]];
    if (array.count == 0) {
        return;
    }
    
    NSMutableString *ids = [[NSMutableString alloc] init];
    for (NSIndexPath *indexPath in array) {
        CarpoolOrderItem *orderItem = self.dataList[indexPath.row];
        [ids appendString:orderItem.orderId];
        [ids appendString:@","];
    }

    [NetManagerInstance sendRequstWithType:FNUserRequestType_HideOrder params:^(NetParams *params) {
        params.method = EMRequstMethod_PUT;
        params.data = @{@"ids": ids,           //订单id
                        @"orderType": @"2"};   //orderType: 包车1 拼车2 天府专车3
    }];
}

- (void)requestSelectedItem{
    if (!_selectedIndexPath || ![_selectedIndexPath isKindOfClass:[NSIndexPath class]]) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderListItemWithIndex params:^(NetParams *params) {
        params.data = @{@"spik": @(_selectedIndexPath.row),
                        @"rows": @(1)};
    }];
}

// 获取拼车历史列表
- (void)requestTravelList{
    
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderList params:^(NetParams *params) {
        params.data = @{@"spik": @(_page*_pageSize),
                        @"rows": @(_pageSize)};
    }];
}

#pragma mark-
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TravelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarpoolItemCell"];
    CarpoolOrderItem *orderItem = self.dataList[indexPath.row];
    
    cell.tintColor = UIColor_DefOrange;
    cell.multipleSelectionBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height-10)];
    cell.multipleSelectionBackgroundView.backgroundColor = [UIColor colorWithRed:.91 green:.94 blue:.98 alpha:1.0];
    
    cell.lblCreateDate.text = [orderItem.createTime timeStringByDefault];
    cell.lblStartName.text = orderItem.startName;
    cell.lblEndName.text = orderItem.destinationName;
    
    UIColor *stateColor = [UIColor colorWithHex:StateRedColor];
    NSString *state;
    switch (orderItem.orderStatus) {
        case CarpoolOrderStatusWaitingForBus:
        case CarpoolOrderStatusReserveSuccess:
        case CarpoolOrderStatusPrepare:{
            state = @"未完成";
            stateColor = [UIColor colorWithHex:StateYellowColor];
            break;
        }
        case CarpoolOrderStatusTravelling:
        case CarpoolOrderStatusTravelEnd:{
            state = @"已完成";
            stateColor = [UIColor colorWithHex:StateGreenColor];
            break;
        }
        case CarpoolOrderStatusReserveFail:{
            state = @"已关闭";
            stateColor = [UIColor colorWithHex:StateGrayColor];
            break;
        }
        case CarpoolOrderStatusCancel:{
            if (orderItem.payStatus == CarpoolOrderPayStatusNON) {
                state = @"已关闭";
                stateColor = [UIColor colorWithHex:StateGrayColor];
            }else{
                state = @"已取消";
                stateColor = [UIColor colorWithHex:StateRedColor];
            }
            break;
        }
        default:
            break;
    }
    cell.lblState.text = state;
    cell.lblState.textColor = stateColor;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([NetManagerInstance reach] == 0) {
        [self showTip:@"似乎已断开与互联网的连接" WithType:FNTipTypeWarning];
        return nil;
    }
    [super tableView:tableView willSelectRowAtIndexPath:indexPath];
    
    CarpoolOrderItem *orderItem = self.dataList[indexPath.row];
    
    if (tableView.isEditing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (orderItem.orderStatus == CarpoolOrderStatusTravelEnd ||
            orderItem.orderStatus == CarpoolOrderStatusReserveFail ||
            (orderItem.orderStatus == CarpoolOrderStatusCancel &&
             (orderItem.payStatus == CarpoolOrderPayStatusNON || orderItem.payStatus == CarpoolOrderPayStatusRefundDone))) {
            //这里是可以删除的订单, 已完成/已取消未支付/已取消退款成功的/
        }
        else {
            [self showTipsView:@"未完成订单不能删除!"];
            [cell setSelected:NO];
            return nil;
        }
    }
    else {
        
        if (orderItem.orderStatus == CarpoolOrderStatusCancel) {
            if (orderItem.payStatus < CarpoolOrderPayStatusApplyForRefund) {
                CarpoolTravelCancelViewController *cancelVC = [CarpoolTravelCancelViewController instanceFromStoryboard];
                cancelVC.carpoolOrder = orderItem;
                [self.navigationController pushViewController:cancelVC animated:YES];
            }else{
                CarpoolTravelCancelingViewController *cancelingVC = [CarpoolTravelCancelingViewController instanceFromStoryboard];
                cancelingVC.carpoolOrderItem = orderItem;
                [self.navigationController pushViewController:cancelingVC animated:YES];
            }
            return nil;
        }
        
        CarpoolTravelingViewController *carpoolVC = [CarpoolTravelingViewController instanceFromStoryboard];
        carpoolVC.carpoolOrder = orderItem;
        [self.navigationController pushViewController:carpoolVC animated:YES];
        self.isRefresh = YES;
        
        return nil;
    }
    
    return indexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    switch (type) {
        case FNUserRequestType_CarpoolOrderList:{
            if (_page == 0 || !self.dataList) {
                self.dataList = [NSMutableArray array];
                [self.tableView.footer resetNoMoreData];
            }
            NSArray *jsonList = resultData.data[@"list"];
            if (!jsonList || jsonList.count == 0) {
                [self.tableView.footer noticeNoMoreData];
            }else{
                [jsonList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CarpoolOrderItem *item = [[CarpoolOrderItem alloc]initWithDictionary:obj];
                    if (item) {
                        [self.dataList addObject:item];
                    }
                }];
                if (jsonList.count < _pageSize) {
                    [self.tableView.footer noticeNoMoreData];
                }else{
                    [self.tableView.footer endRefreshing];
                }
            }
            [self.tableView.header endRefreshing];
            [self.tableView reloadData];

            break;
        }
        case FNUserRequestType_CarpoolOrderListItemWithIndex:{
            NSArray *jsonList = resultData.data[@"list"];
            NSDictionary *obj = [jsonList firstObject];
            CarpoolOrderItem *item = nil;
            if (obj) {
                item = [[CarpoolOrderItem alloc]initWithDictionary:[jsonList firstObject]];
            }
            [self updateSelectedRowWithItem:item];
            break;
        }
        case FNUserRequestType_HideOrder:
        {
            if (resultData.resultCode == 0) {
                [self deleteSelectItems];
            }
            
        }
            break;
        default:
            break;
    }
}

-(void)httpRequestFailed:(NSNotification *)notification{
    @try {
        [(NSMutableDictionary *)(notification.object) setObject:@(NO) forKey:NeedToHomeKey];
    }
    @catch (NSException *exception) {
        
    }
    @finally {

    }
    
    [super httpRequestFailed:notification];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
//    NSError *error = [notification.object objectForKey:@"error"];
//    [self showTip:error.localizedDescription WithType:FNTipTypeFailure hideDelay:1.5];
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
