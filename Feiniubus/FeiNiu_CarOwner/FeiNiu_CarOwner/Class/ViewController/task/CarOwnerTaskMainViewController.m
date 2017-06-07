//
//  CarOwnerTaskMainViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerTaskMainViewController.h"
#import "TaskFilterView.h"
#import "ProtocolCarOwner.h"
#import <FNUIView/MJRefresh.h>
#import "CarOwnerTaskModel.h"
#import "CarOwnerTaskDetailViewController.h"
#import "CarOwnerOrderDetailTwoViewController.h"
#import <FNCommon/DateUtils.h>
#import <MAMapKit/MAMapKit.h>

@interface CarOwnerTaskMainViewController ()<UITableViewDelegate,UITableViewDataSource,TaskFilterViewDelegate,UISearchBarDelegate>
{
    //第几页
    int page;
    //一页数量
    int pageNumber;
    //请求类型 0代表累加数据刷新请求，1代表所有数据刷新的请求
    int pageRequestType;
    //搜索关键字
    NSString *searchKey;
    //最小价格 存储的是分
    int minPrice;
    //最大价格 存储的是分
    int maxPrice;
    //订单时间类型
    FilterTimeType dateType;
    //任务状态类型
    FilterTaskType taskType;
    
    //通知刷新还是页面刷新 0为页面刷新 1为支付完成通知刷新
    int refreshType;
}

@property (nonatomic,strong) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTaskButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
//数据源
@property (nonatomic,strong) NSMutableArray *dataSource;


@end

@implementation CarOwnerTaskMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
    [self setNavigationBarSelf];
    [self setSeachBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //请求服务器数据
    pageRequestType = 1;
    [self requestData];
}
-(void)dealloc
{
    //注销抢单通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_OrderPayResult object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_DriverStartTask object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_DriverEndTask object:nil];
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
    //设置添加车辆按钮字体大小
    [_addTaskButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    //ios 7下出现未到底部
    [_mainTableView remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom);
    }];
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    //搜索数据初始化
    page = 0;
    pageNumber = onePageNumber;
    searchKey = @"";
    
    //设置下拉刷新，上啦刷新功能
    _mainTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //头部数据
        page = 0;
        //请求数据
        pageRequestType = 1;
        [self requestData];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    _mainTableView.header.automaticallyChangeAlpha = YES;
    _mainTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //页数增加一页面
        page ++ ;
        //请求数据
        pageRequestType = 0;
        [self requestData];
    }];
    //注册客户端支付完成后的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushOrderPayResult:) name:KNotification_OrderPayResult object:nil];
    //注册司机任务开始任务通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushOrderPayResult:) name:KNotification_DriverStartTask object:nil];
    //注册司机任务结束任务通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushOrderPayResult:) name:KNotification_DriverEndTask object:nil];
}
//执行通知
-(void)pushOrderPayResult:(NSNotification*)notification
{
    //请求数据
    pageRequestType = 1;
    refreshType = 1;
    [self requestData];
}
//页面即将显示请求数据
-(void)requestData
{
    //起始行数
    int spik;
    int allRows;
    //根据请求类型分辨请求行和行数
    switch (pageRequestType) {
        case 0:
        {
            spik = page * pageNumber;
            allRows = pageNumber;
        }
            break;
        case 1:
        {
            spik = 0;
            allRows = (page + 1) * pageNumber;
        }
            break;
        default:
            break;
    }
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:[[NSNumber alloc] initWithInt:spik] forKey:@"spik"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:allRows] forKey:@"rows"];
    [requestDic setObject:searchKey forKey:@"searchKey"];
    //最小价格
    [requestDic setObject:[[NSNumber alloc] initWithInt:minPrice] forKey:@"minPrice"];
    //最大价格
    if (maxPrice > 0) {
        [requestDic setObject:[[NSNumber alloc] initWithInt:maxPrice] forKey:@"maxPrice"];
    }
    //开始时间与结束时间
    if (dateType) {
        //设置开始时间结束时间
        NSString *startTime = [DateUtils now];
        NSString *endTime = [DateUtils now];
        switch (dateType) {
            case FilterTimeTypeDay:
            {
                endTime = [DateUtils afterDays:1 date:startTime];
            }
                break;
            case FilterTimeTypeWeek:
            {
                startTime = [DateUtils beforeDays:7 date:endTime];
            }
                break;
            case FilterTimeTypeMonth:
            {
                startTime = [DateUtils beforeDays:30 date:endTime];
            }
                break;
            default:
                break;
        }
        [requestDic setObject:startTime forKey:@"startTime"];
        [requestDic setObject:endTime forKey:@"endTime"];
    }
    //任务状态
    if (taskType) {
        int orderState;
        switch (taskType) {
            case FilterTaskTypeCurrent:
                orderState = FilterTaskTypeCurrent;
                break;
            case FilterTaskTypeComplete:
                orderState = FilterTaskTypeComplete;
                break;
            default:
                break;
        }
        [requestDic setObject:[[NSNumber alloc] initWithInt:orderState] forKey:@"orderState"];
    }
    //是否显示刷新等待符号
    if (!refreshType) {
        [self startWait];
    }
    refreshType = 0;
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_charterOrderOwnersTask requestType:KRequestType_charterOrderOwnersTask];
    
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
//搜索框
-(void)setSeachBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    self.searchBar.barStyle     = UIBarStyleBlackTranslucent;
    self.searchBar.translucent  = YES;
    //    self.searchBar.delegate     = self;
    self.searchBar.placeholder = @"搜索任务";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.alpha = 0.5f;
    self.searchBar.backgroundColor=[UIColor clearColor];
    self.searchBar.enablesReturnKeyAutomatically = NO;
    //设置输入框背景色
    UIView *searchTextField = nil;
    self.searchBar.barTintColor = [UIColor whiteColor];
    searchTextField = [[[self.searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.backgroundColor = UIColorFromRGB(0xF6F6F6);
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
}

//任务筛选点击
- (IBAction)taskFilterClick:(id)sender {
    
    [self hideKeyboard];
    
    TaskFilterView *filterView =  (TaskFilterView*)[[NSBundle mainBundle] loadNibNamed:@"TaskFilterView" owner:nil options:nil][0];
    filterView.delegate = self;
    //转换成单位元
    filterView.startPrice = minPrice/100.0;
    filterView.endPrice = maxPrice/100.0;
    filterView.dateType = dateType;
    filterView.taskType = taskType;
    //设置值显示
    [filterView setViewValue];
    
    [filterView showInView:[[UIApplication sharedApplication] keyWindow]];
    
}

//隐藏键盘
-(void)hideKeyboard
{
    [self.searchBar resignFirstResponder];
}

#pragma mark -- UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideKeyboard];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchKey = self.searchBar.text;
    page = 0;
    //再次请求数据
    pageRequestType = 1;
    [self requestData];
}

#pragma mark --- TaskFilterViewDelegate
- (void)taskFilterViewViewReset
{
    page = 0;
    //点击了重置
    minPrice = 0;
    maxPrice = 0;
    dateType = 0;
    taskType = 0;
    //重新请求数据
    pageRequestType = 1;
    [self requestData];
}
- (void)taskFilterViewOK:(float)selectStartPrice selectEndPrice:(float)selectEndPrice selectFilterTimeType:(FilterTimeType)selectFilterTimeType selectFilterTaskType:(FilterTaskType)selectFilterTaskType
{
    page = 0;
    minPrice = selectStartPrice*100;
    maxPrice = selectEndPrice*100;
    dateType = selectFilterTimeType;
    taskType = selectFilterTaskType;
    //重新请求数据
    pageRequestType = 1;
    [self requestData];
}

#pragma mark ---UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 198.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self hideKeyboard];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CarOwnerTaskModel *tempModel = _dataSource[indexPath.row];
    
    if (tempModel.orderState == 2) {
        //等待付款
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
        CarOwnerOrderDetailTwoViewController *detailTwoViewController = [storyboard instantiateViewControllerWithIdentifier:@"OrderDetailTwoViewControllerId"];
        detailTwoViewController.taskModel = tempModel;
        [self.navigationController pushViewController:detailTwoViewController animated:YES];
    }
    else{
        //其他任务
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Task" bundle:nil];
        CarOwnerTaskDetailViewController *taskDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewControllerId"];
        taskDetailViewController.taskModel = tempModel;
        taskDetailViewController.mapView = [MAMapView new];
        [self.navigationController pushViewController:taskDetailViewController animated:YES];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

#pragma mark ---UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell =nil;
    
    CarOwnerTaskModel *tempModel = _dataSource[indexPath.row];
    
    tempCell = [tableView dequeueReusableCellWithIdentifier:@"taskCellIdent"];
    
    UIButton *clickButton = (UIButton*)[tempCell viewWithTag:102];
    [clickButton setTitle:@"未知状态" forState:UIControlStateNormal];
    [clickButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    clickButton.layer.borderWidth = 1.f;
    clickButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    clickButton.layer.cornerRadius = 3.f;
    if (tempModel.orderState == 2)
    {
        [clickButton setTitle:@"等待付款" forState:UIControlStateNormal];
        [clickButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
        clickButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    }
    else if (tempModel.orderState == 3)
    {
        [clickButton setTitle:@"等待开始" forState:UIControlStateNormal];
        [clickButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
        clickButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    }
    else if (tempModel.orderState == 4)
    {
        [clickButton setTitle:@"当前任务" forState:UIControlStateNormal];
        [clickButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
        clickButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    }
    else if (tempModel.orderState == 5)
    {
        [clickButton setTitle:@"历史任务" forState:UIControlStateNormal];
        [clickButton setTitleColor:UIColorFromRGB(0xB4B4B4) forState:UIControlStateNormal];
        clickButton.layer.borderColor = UIColorFromRGB(0xB4B4B4).CGColor;
    }
    else if (tempModel.orderState == 6)
    {
        [clickButton setTitle:@"任务终止" forState:UIControlStateNormal];
        [clickButton setTitleColor:UIColorFromRGB(0xB4B4B4) forState:UIControlStateNormal];
        clickButton.layer.borderColor = UIColorFromRGB(0xB4B4B4).CGColor;
    }
    else if (tempModel.orderState == 7)
    {
        [clickButton setTitle:@"任务取消" forState:UIControlStateNormal];
        [clickButton setTitleColor:UIColorFromRGB(0xB4B4B4) forState:UIControlStateNormal];
        clickButton.layer.borderColor = UIColorFromRGB(0xB4B4B4).CGColor;
    }
    
    
    UILabel *priceLabel = (UILabel*)[tempCell viewWithTag:101];
    UILabel *phoneLabel = (UILabel*)[tempCell viewWithTag:103];
    UILabel *licenseLabel = (UILabel*)[tempCell viewWithTag:104];
    UILabel *startTimeLabel = (UILabel*)[tempCell viewWithTag:105];
    UILabel *endTimeLabel = (UILabel*)[tempCell viewWithTag:106];
    UILabel *tripLabel = (UILabel*)[tempCell viewWithTag:107];
    
    priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元",tempModel.price/100.f];
    phoneLabel.text = [[NSString alloc] initWithFormat:@"%@",tempModel.driverPhone];
    licenseLabel.text = [[NSString alloc] initWithFormat:@"%@",tempModel.licensePlate];
    //时间数据转化
    NSDate *startDate = [DateUtils stringToDate:tempModel.startTime];
    NSDate *endDate = [DateUtils stringToDate:tempModel.endTime];
    startTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"]];
    endTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
    
    tripLabel.text = [[NSString alloc] initWithFormat:@"%@--%@",tempModel.startName,tempModel.destinationName];
    
    return tempCell;
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
    
    if (resultParse.requestType == KRequestType_charterOrderOwnersTask)
    {
        if (resultParse.resultCode == 0) {
            
            //清空数据
            if (pageRequestType == 1 || !_dataSource) {
                _dataSource = [[NSMutableArray alloc] init];
            }
            
            NSDictionary *returnDic = [resultParse.data objectForKey:@"list"];
            for (NSDictionary *tempDic in returnDic) {
                CarOwnerTaskModel *tempModel = [[CarOwnerTaskModel alloc] initWithDictionary:tempDic];
                [_dataSource addObject:tempModel];
            }
            
            [_mainTableView reloadData];
            
        }
        else
        {
            [self showTipsView:@"与服务器数据交互失败"];
        }
        //清除刷新头部和底部
        [_mainTableView.header endRefreshing];
        [_mainTableView.footer endRefreshing];
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
    //清除刷新头部和底部
    [_mainTableView.header endRefreshing];
    [_mainTableView.footer endRefreshing];
}

@end


