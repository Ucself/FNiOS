//
//  CharterListViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterListViewController.h"
#import "TravelListCell.h"
#import "CharteredTravelingViewController.h"

@interface CharterListViewController ()

@end

@implementation CharterListViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.tableView.header beginRefreshing];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Public Methods
- (void)deleteAction
{

}

- (void)requestSelectedItem{
    if (!_selectedIndexPath || ![_selectedIndexPath isKindOfClass:[NSIndexPath class]]) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderListItemWithIndex params:^(NetParams *params) {
        params.data = @{@"spik": @(_selectedIndexPath.row),
                        @"rows": @(1)};
    }];
}

- (void)requestTravelList{

    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderMain params:^(NetParams *params) {
        params.data = @{@"spik": @(_page*_pageSize),
                        @"rows": @(_pageSize)};
    }];
}
#pragma mark - RequestMethods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TravelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CharterItemCell"];
    CharterOrderItem *orderItem = self.dataList[indexPath.row];
    cell.lblCreateDate.text = [orderItem.createTime timeStringByDefault];
    cell.lblStartName.text = orderItem.startingName;
    cell.lblEndName.text = orderItem.destinationName;
    NSString *state = orderItem.status == 0 ? @"未完成" : @"已完成";
    cell.lblState.text = state;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CharteredTravelingViewController *charterVC = [CharteredTravelingViewController instanceFromStoryboard];
    CharterOrderItem *orderItem = self.dataList[indexPath.row];
    charterVC.orderId = orderItem.orderId;
    [self.navigationController pushViewController:charterVC animated:YES];
    return nil;
}


#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    switch (type) {
        case FNUserRequestType_CharterOrderMain:{
            if (_page == 0 || !self.dataList) {
                self.dataList = [NSMutableArray array];
                [self.tableView.footer resetNoMoreData];
                
            }
            NSArray *jsonList = resultData.data[@"list"];
            if (!jsonList || jsonList.count == 0) {
                [self.tableView.footer noticeNoMoreData];
            }else{
                [jsonList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CharterOrderItem *item = [[CharterOrderItem alloc]initWithDictionary:obj];
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
        case FNUserRequestType_CharterOrderListItemWithIndex:{
            NSArray *jsonList = resultData.data[@"list"];
            CharterOrderItem *item = [[CharterOrderItem alloc]initWithDictionary:[jsonList firstObject]];
            [self updateSelectedRowWithItem:item];
            break;
        }
        default:
            break;
    }
}


-(void)httpRequestFailed:(NSNotification *)notification{
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
