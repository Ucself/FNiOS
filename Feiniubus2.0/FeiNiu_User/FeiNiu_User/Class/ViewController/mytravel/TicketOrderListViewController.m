//
//  TicketOrderListViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "TicketOrderListViewController.h"
#import "TicketDetailViewController.h"
#import "TicketRefundProcessViewController.h"
#import "ContainerViewController.h"
#import "MainViewController.h"
#import "OrderTableViewCell.h"
#import "OrderTicket.h"
#import "AppDelegate.h"
#import "AuthorizeCache.h"
#import <FNUIView/MJRefresh.h>


@interface TicketOrderListViewController () <SWTableViewCellDelegate>
{
    OrderTableViewCell *prevCell;
    
    
    int spik;     //分页索引
    int rows;     //分页行数
    NSIndexPath *deleteIndex;     //删除的索引
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arOrders;
@property (weak, nonatomic) IBOutlet UIView *noContentView;

@property (nonatomic, assign)BOOL needRefresh;
@end

@implementation TicketOrderListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arOrders = [[NSMutableArray alloc] init];
    _needRefresh = YES;
    
    [self initTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderRefreshNotification) name:KOrderRefreshNotification object:nil];
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
    
    if (_needRefresh) {
        _needRefresh = NO;
        spik = 0;
        
        if ([[AuthorizeCache sharedInstance] getAccessToken] && [[[AuthorizeCache sharedInstance] getAccessToken] length] !=0) {
            [self startWait];
            [self requestList];
        }
    }
}

-(void)initTableView
{
    spik = 0;
    rows = 20;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        spik = 0;
        [self requestList];
    }];
    self.tableView.header.automaticallyChangeAlpha = YES;
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        spik++;
        [self requestList];
    }];
}

-(void)requestList
{
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderList params:^(NetParams *params) {
        params.data = @{@"spik": @(spik * rows),
                        @"rows": @(rows)};
    }];
}

- (void)refresh
{
    spik = 0;
    [self.tableView.header beginRefreshing];
}
- (IBAction)btnTicketClick:(id)sender {    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.mainController.selectedIndex = 1;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[TicketDetailViewController class]]) {
    }
}

-(void)orderRefreshNotification
{
    _needRefresh = YES;
}


#pragma mark - uitableview delegate mothed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arOrders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdent = @"feiniuorderCell";
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderTableViewCell" owner:self options:0] firstObject];
        
        cell.delegate = self;
        cell.height = 115;
        cell.containingTableView = self.tableView;
        cell.cellType = EmCellType_Tickets;
        cell.offsetMargin = 10; //边距
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = UIColor_DefOrange;
        btn.layer.cornerRadius = 5;
        [btn setImage:[UIImage imageNamed:@"ico_recycle"] forState:UIControlStateNormal];
        //[btn setTitle:@"delete" forState:UIControlStateNormal];
        
        NSArray *btns = @[btn];
        [cell setButtonsLeft:nil right:btns];
    }
    
    OrderTicket *order = self.arOrders[indexPath.row];
    [cell setTicketOrderInfo:order];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (prevCell) {
        [prevCell hideUtilityButtonsAnimated:NO];
    }
    
    OrderTicket *order = self.arOrders[indexPath.row];
    TicketDetailViewController *c = [TicketDetailViewController instanceWithStoryboardName:@"TicketsOrder"];
    c.delegate = self;
    c.orderId = order.orderId;
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark - SWTableViewDelegate
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            deleteIndex = [self.tableView indexPathForCell:cell];
            OrderTicket *order = self.arOrders[deleteIndex.row];
            if (order) {
                if (order.orderState == EmOrderTicketStatus_Cancelled || order.orderState == EmOrderTicketStatus_RefundFinished) {
                    [self startWait];
                    [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderRemove params:^(NetParams *params) {
                        params.method = EMRequstMethod_DELETE;
                        params.data = @{@"orderId": order.orderId,
                                        @"orderType": @(5)};       //专车4, 客票5
                    }];
                }
                else {
                    [self showTipsView:@"未完成订单不能删除"];
                }
                 
            }

            break;
        }
            
        default:
            break;
    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    if (prevCell && prevCell != cell) {
        [prevCell hideUtilityButtonsAnimated:YES];
    }
    
    prevCell = (OrderTableViewCell*)cell;
}


#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *result = (ResultDataModel *)notification.object;
    
    if (result.type == EmRequestType_TicketOrderList) {

        if (spik == 0) {
            self.arOrders = [OrderTicket mj_objectArrayWithKeyValuesArray:result.data];
            [self.tableView.header endRefreshing];
            
            if (!self.arOrders || self.arOrders.count == 0) {
                _noContentView.hidden = NO;
            }
            else {
                _noContentView.hidden = YES;
            }
        }
        else {
            NSArray *array = [OrderTicket mj_objectArrayWithKeyValuesArray:result.data];
            [self.arOrders addObjectsFromArray:array];
            //[self.tableView.footer endRefreshing];
            if (array.count < rows) {
                [self.tableView.footer noticeNoMoreData];
            }else{
                [self.tableView.footer endRefreshing];
            }
        }
        
        [self.tableView reloadData];
    }
    else if (result.type == EmRequestType_TicketOrderRemove) {
        //删除数据
        [self.arOrders removeObjectAtIndex:deleteIndex.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:UITableViewRowAnimationLeft];
        
        if (!self.arOrders || self.arOrders.count == 0) {
            _noContentView.hidden = NO;
        }
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    return [super httpRequestFailed:notification];
}
@end
