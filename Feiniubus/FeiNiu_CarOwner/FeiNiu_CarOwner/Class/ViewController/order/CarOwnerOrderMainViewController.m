//
//  CarOwnerOrderMainViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerOrderMainViewController.h"
#import "ProtocolCarOwner.h"
#import "CarOwnerOrderModel.h"
#import "CarOwnerOrderDetailOneViewController.h"
#import "CarOwnerOrderDetailTwoViewController.h"
#import "CarOwnerPreferences.h"
#import <FNUIView/MJRefresh.h>
#import <FNCommon/DateUtils.h>
#import <FNNetInterface/PushConfiguration.h>

@interface CarOwnerOrderMainViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation CarOwnerOrderMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarSelf];
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //加载数据
    [self requestData];
}

-(void)dealloc
{
    //注销抢单通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_PushGrabOrder object:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark ----
//初始化界面
-(void)initInterface
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource  = self;
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    //注册抢单通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushGrabOrder:) name:KNotification_PushGrabOrder object:nil];
    //设置下拉刷新，上啦刷新功能
    _mainTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //获取抢单列表
        [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSMutableDictionary new] urlSuffix:Kurl_charterOrderGrab requestType:KRequestType_getCharterOrderGrab];
    }];
}

-(void)requestData
{
    //获取抢单列表
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSMutableDictionary new] urlSuffix:Kurl_charterOrderGrab requestType:KRequestType_getCharterOrderGrab];
}

//设置导航栏目
-(void)setNavigationBarSelf
{
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xFFFFFF)];
    [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0x333333)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x333333)}];
    //iOS7 增加滑动手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark ---UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 147.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            //新订单
            //            [self performSegueWithIdentifier:@"toRobOrder" sender:self];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
            CarOwnerOrderDetailOneViewController *detailOneViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailOneViewControllerId"];
            
            detailOneViewController.orderModel = _subOrder[indexPath.row];
            
            [self.navigationController pushViewController:detailOneViewController animated:YES];
        }
            break;
        case 1:
        {
            //付款成功订单
            //            [self performSegueWithIdentifier:@"toWaitOrder" sender:self];
        }
            break;
        case 2:
        {
            //待付款订单
            
        }
            break;
        case 3:
        {
            //失败订单
        }
            break;
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark ---UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return _subOrder.count;
        }
            break;
        case 1:
        {
            return _paySuccessSubOrder.count;
        }
            break;
        case 2:
        {
            return _stayPaySuborder.count;
        }
            break;
        case 3:
        {
            return _failSubOrder.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell =nil;
    tempCell = [tableView dequeueReusableCellWithIdentifier:@"orderCellIdent"];
    //数据model
    CarOwnerOrderModel *orderModel;
    
    UILabel *priceLabel = (UILabel*)[tempCell viewWithTag:101];
    UIButton *clickButton = (UIButton*)[tempCell viewWithTag:102];
    UILabel *originLabel = (UILabel*)[tempCell viewWithTag:103];
    UILabel *timeLabel = (UILabel*)[tempCell viewWithTag:104];
    switch (indexPath.section) {
        case 0:
        {
            //新订单
            [clickButton setTitle:@"抢单" forState:UIControlStateNormal];
            [clickButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
            clickButton.layer.borderWidth = 1.f;
            clickButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
            clickButton.layer.cornerRadius = 3.f;
            //新订单的行数
            orderModel = (CarOwnerOrderModel*)_subOrder[indexPath.row];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",orderModel.price/100.f,@"元"];
            originLabel.text = [[NSString alloc] initWithFormat:@"%@---%@",orderModel.startName,orderModel.destinationName];
            //时间数据转化
            NSDate *startDate = [DateUtils stringToDate:orderModel.startTime];
            NSDate *endDate = [DateUtils stringToDate:orderModel.endTime];
            
            timeLabel.text = [[NSString alloc] initWithFormat:@"%@-%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"],[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
        }
            break;
        case 1:
        {
            [clickButton setTitle:@"等待付款" forState:UIControlStateNormal];
            [clickButton setTitleColor:UIColorFromRGB(0xFFB737) forState:UIControlStateNormal];
            clickButton.layer.borderWidth = 1.f;
            clickButton.layer.borderColor = UIColorFromRGB(0xFFB737).CGColor;
            clickButton.layer.cornerRadius = 3.f;
            //付款成功订单的行数
            orderModel = (CarOwnerOrderModel*)_paySuccessSubOrder[indexPath.row];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",orderModel.price,@"元"];
            originLabel.text = [[NSString alloc] initWithFormat:@"%@---%@",orderModel.startName,orderModel.destinationName];
            timeLabel.text = [[NSString alloc] initWithFormat:@"%@-%@",orderModel.startTime,orderModel.endTime];
        }
            break;
        case 2:
        {
            [clickButton setTitle:@"付款成功" forState:UIControlStateNormal];
            [clickButton setTitleColor:UIColorFromRGB(0x80CC5A) forState:UIControlStateNormal];
            clickButton.layer.borderWidth = 1.f;
            clickButton.layer.borderColor = UIColorFromRGB(0x80CC5A).CGColor;
            clickButton.layer.cornerRadius = 3.f;
            //待付款订单的行数
            orderModel = (CarOwnerOrderModel*)_stayPaySuborder[indexPath.row];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",orderModel.price,@"元"];
            originLabel.text = [[NSString alloc] initWithFormat:@"%@---%@",orderModel.startName,orderModel.destinationName];
            timeLabel.text = [[NSString alloc] initWithFormat:@"%@-%@",orderModel.startTime,orderModel.endTime];
        }
            break;
        case 3:
        {
            [clickButton setTitle:@"失败订单" forState:UIControlStateNormal];
            [clickButton setTitleColor:UIColorFromRGB(0x80CC5A) forState:UIControlStateNormal];
            clickButton.layer.borderWidth = 1.f;
            clickButton.layer.borderColor = UIColorFromRGB(0x80CC5A).CGColor;
            clickButton.layer.cornerRadius = 3.f;
            //失败订单的行数
            orderModel = (CarOwnerOrderModel*)_failSubOrder[indexPath.row];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",orderModel.price,@"元"];
            originLabel.text = [[NSString alloc] initWithFormat:@"%@---%@",orderModel.startName,orderModel.destinationName];
            timeLabel.text = [[NSString alloc] initWithFormat:@"%@-%@",orderModel.startTime,orderModel.endTime];
        }
            break;
        default:
            break;
    }
    
    return tempCell;
}
#pragma mark --
-(void)onApplicationBecomeActive
{
    [super onApplicationBecomeActive];
    [self requestData];
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_getCharterOrderGrab:
        {
            if (resultParse.resultCode == 0)
            {
                _subOrder = [[NSMutableArray alloc] init];
                //新订单
                if ([resultParse.data objectForKey:@"newSubOrder"]) {
                    NSMutableArray *tempSubOrder = [resultParse.data objectForKey:@"newSubOrder"];
                    for (NSDictionary *tempOrder in tempSubOrder) {
                        CarOwnerOrderModel *orderModel = [[CarOwnerOrderModel alloc] initWithDictionary:tempOrder];
                        [_subOrder addObject:orderModel];
                    }
                    //设置应用上的图标显示数字
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:tempSubOrder.count];
                    //向极光服务器设置
                    [[PushConfiguration sharedInstance] setBadge:tempSubOrder.count];
                }
                //付款订单
                _paySuccessSubOrder = [[NSMutableArray alloc] init];
                if ([resultParse.data objectForKey:@"paySuccessSubOrder"]) {
                    NSMutableArray *tempSubOrder = [resultParse.data objectForKey:@"paySuccessSubOrder"];
                    for (NSDictionary *tempOrder in tempSubOrder) {
                        CarOwnerOrderModel *orderModel = [[CarOwnerOrderModel alloc] initWithDictionary:tempOrder];
                        [_paySuccessSubOrder addObject:orderModel];
                    }
                }
                //未付款订单
                _stayPaySuborder = [[NSMutableArray alloc] init];
                if ([resultParse.data objectForKey:@"stayPaySuborder"]) {
                    NSMutableArray *tempSubOrder = [resultParse.data objectForKey:@"stayPaySuborder"];
                    for (NSDictionary *tempOrder in tempSubOrder) {
                        CarOwnerOrderModel *orderModel = [[CarOwnerOrderModel alloc] initWithDictionary:tempOrder];
                        [_stayPaySuborder addObject:orderModel];
                    }
                }
                //失败订单
                _failSubOrder = [[NSMutableArray alloc] init];
                if ([resultParse.data objectForKey:@"failSubOrder"]) {
                    NSMutableArray *tempSubOrder = [resultParse.data objectForKey:@"failSubOrder"];
                    for (NSDictionary *tempOrder in tempSubOrder) {
                        CarOwnerOrderModel *orderModel = [[CarOwnerOrderModel alloc] initWithDictionary:tempOrder];
                        [_failSubOrder addObject:orderModel];
                    }
                }
                //重刷数据
                [self.mainTableView reloadData];
                //清除刷新头部和底部
                [_mainTableView.header endRefreshing];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        default:
            break;
    }
    
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

#pragma mark --- KNotification_PushGrabOrder
//推送过来的通知
-(void)pushGrabOrder:(NSNotification*)notification
{
    //    NSMutableArray *pushOrders = [[CarOwnerPreferences sharedInstance] getOrderIdInfo];
    
    //重新加载一下界面数据
    [self requestData];
}

@end



















