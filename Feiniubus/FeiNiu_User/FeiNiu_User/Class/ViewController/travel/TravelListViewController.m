//
//  TravelListViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/29.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TravelListViewController.h"
#import "TravelListCell.h"


@interface TravelListViewController ()<UITableViewDataSource, UITableViewDelegate>


@end
@implementation TravelListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _page = 0;
    _pageSize = 10;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 0;
        [self requestTravelList];
    }];
    self.tableView.header.automaticallyChangeAlpha = YES;
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _page++;
        [self requestTravelList];
    }];
    
    _selectDict = [[NSMutableDictionary alloc]init];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_selectedIndexPath && _isRefresh) {
        [self requestSelectedItem];
    }
}
#pragma mark - Public Methods
- (void)refresh{
    [self.tableView.header beginRefreshing];
}
- (void)setEditMode:(BOOL)edit
{
    [self.tableView setEditing:edit animated:YES];
}
- (void)deleteAction
{
    
}

- (void)deleteSelectItems
{
    NSArray *array = [NSArray arrayWithArray:[self.selectDict allValues]];

    NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
    [self.dataList enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        for (int i=0; i<array.count; i++) {
            NSIndexPath *indexPath = array[i];
            if (idx == indexPath.row) {
                //[self.dataList removeObjectAtIndex:idx];
                [indexSets addIndex:idx];
            }
        }
    }];
    
    [self.dataList removeObjectsAtIndexes:indexSets];
    
    [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    [self.selectDict removeAllObjects];
}

- (void)requestTravelList{
    // Not implement ,need override this method
}
- (void)requestSelectedItem{
    // Not implement ,need override this method
}

- (void)updateSelectedRowWithItem:(id)item{
    if (_selectedIndexPath && [_selectedIndexPath isKindOfClass:[NSIndexPath class]]) {
        if (!item) {
            self.dataList = [[self.dataList subarrayWithRange:NSMakeRange(0, _selectedIndexPath.row)] mutableCopy];
            [self.tableView reloadData];
        }else{
            @try {
                [self.dataList replaceObjectAtIndex:_selectedIndexPath.row withObject:item];
                [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
    }
    _selectedIndexPath = nil;
}



#pragma mark - uitableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TravelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CharterItemCell"];
//    CharterOrderItem *orderItem = _charterOrderList[indexPath.row];
//    cell.lblCreateDate.text = [orderItem.createTime timeStringByDefault];
//    cell.lblStartName.text = orderItem.startingName;
//    cell.lblEndName.text = orderItem.destinationName;
//    NSString *state = orderItem.status == 0 ? @"未完成" : @"已完成";
//    cell.lblState.text = state;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndexPath = indexPath;
    self.isRefresh = NO;
//    CharteredTravelingViewController *charterVC = [CharteredTravelingViewController instanceFromStoryboard];
//    
//    charterVC.orderId = (_charterOrderList[indexPath.row]).orderId;
//    [self.navigationController pushViewController:charterVC animated:YES];
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        [_selectDict setObject:indexPath forKey:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.isEditing) {
        [_selectDict removeObjectForKey:indexPath];
    }
    
}
@end
