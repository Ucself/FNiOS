//
//  DriverMainViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/8/12.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverMainViewController.h"
#import <FNUIView/REFrostedViewController.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>
#import <MAMapKit/MAMapView.h>
#import <FNUIView/MJRefresh.h>
#import "ProtocolDriver.h"
#import "DriverTaskModel.h"
#import "DriverTaskDetailViewController.h"
#import "DriverPackTaskDetailViewController.h"
#import "TopDatePickerView.h"
#import <FNUIView/CustomAlertView.h>
#import "DriverModel.h"
#import <FNCommon/DateUtils.h>
#import "DriverCarpoolingTaskModel.h"
#import "GetTaskAlertView.h"
#import "AppDelegate.h"
#import "DriverCombinationTaskModel.h"


@interface DriverMainViewController ()<UITableViewDelegate,UITableViewDataSource,TopDatePickerViewDelegate,GetTaskAlertViewDelegate>
{
    //第几页
    int page;
    //一页数量
    int pageNumber;
    //当前选择的时间类型
    int selectTimeType;
    //请求开始时间
    NSString *startTime;
    //请求结束时间
    NSString *endTime;
    //时间选择器
    TopDatePickerView *topDatePickerView;
    //请求对象
    NSMutableDictionary *requestDic;
    //请求类型 0代表累加数据刷新请求，1代表所有数据刷新的请求
    int pageRequestType;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

//包车的任务数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
//拼车的任务数据源
@property (nonatomic,strong) NSMutableArray *carpoolingDataSource;
//组合数据
@property (nonatomic,strong) NSMutableArray *combinationDataSource;

@property (nonatomic,strong) DriverModel *driverModel;

@end

@implementation DriverMainViewController

@dynamic delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self mapPathTest];
    //    [self mapUserLocationTest];
    //    [self mapPolylinePathTest];
    //基类执行过一次
//    [self setNavigationBarSelf];
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //所有数据刷新，请求所有数据
    pageRequestType = 1;
    //请求数据
    [self requestData];
}


//默认按钮点击
- (IBAction)defaultButtonClick:(id)sender {
    if (topDatePickerView) {
        [topDatePickerView cancelPicker:[[UIApplication sharedApplication] keyWindow]];
    }
    topDatePickerView = nil;
    //时间设置为默认
    [self setDefaultTime];
    page = 0 ;
    pageRequestType = 1;
    //在此请求数据
    [self requestData];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark ---

-(void)initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    //设置时间选择点击事件
    //搜索数据初始化
    page = 0;
    pageNumber = 5;
    
    //设置下拉刷新，上啦刷新功能
    _mainTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //头部数据
        page = 0;
        //所有数据刷新
        pageRequestType = 1;
        //请求数据
        [self requestData];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    _mainTableView.header.automaticallyChangeAlpha = YES;
    _mainTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //页数增加一页面
        page ++ ;
        //请求数据
        pageRequestType = 0;
        //请求数据
        [self requestData];
    }];
    //添加时间选择点击手势
    UITapGestureRecognizer *leftClickGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelectorClick:)];
    [_leftView addGestureRecognizer:leftClickGesture];
    [_leftView setTag:101];
    
    UITapGestureRecognizer *rightClickGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelectorClick:)];
    [_rightView addGestureRecognizer:rightClickGesture];
    [_rightView setTag:102];
    //设置一次起始时间和结束时间
    [self setDefaultTime];
    //请求司机个人信息
    [[ProtocolDriver sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_MemberInfo requestType:KRequestType_memberinfo];
}

//弹出选择时间
-(void)timeSelectorClick:(UITapGestureRecognizer *)sender
{
    //说明存在一个弹出框
    if (topDatePickerView) {
        return;
    }
    //设置点击的是当前哪一个时间
    selectTimeType = (int)sender.view.tag;
    topDatePickerView = [[TopDatePickerView alloc] initWithFrame:self.view.bounds];
    topDatePickerView.delegate = self;
    //设置最大时间，最小时间
    NSDate* minDate = [DateUtils stringToDate:@"2015-01-01 00:00:00"];
    NSDate* maxDate = [DateUtils stringToDate:@"2099-01-01 00:00:00"];
    topDatePickerView.datePicker.minimumDate = minDate;
    topDatePickerView.datePicker.maximumDate = maxDate;
    //设置当前选中时间
    switch (selectTimeType) {
        case 101:
        {
            if (startTime && ![startTime isEqualToString:@""]) {
                topDatePickerView.datePicker.date = [DateUtils stringToDate:[[NSString alloc] initWithFormat:@"%@ 00:00:00",startTime]];
            }
            else
            {
                topDatePickerView.datePicker.date = [NSDate new];
            }
            
        }
            break;
        case 102:
        {
            if (endTime && ![endTime isEqualToString:@""]) {
                topDatePickerView.datePicker.date = [DateUtils stringToDate:[[NSString alloc] initWithFormat:@"%@ 00:00:00",endTime]];
            }
            else
            {
                topDatePickerView.datePicker.date = [NSDate new];
            }
        }
            break;
        default:
            break;
    }
    
    [topDatePickerView showInView:_mainView];
}

//导航栏设置
-(void)setNavigationBarSelf
{
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xFC5338)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    //下一个control返回显示
    self.navigationItem.title = @"飞牛驾驶员";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    UIImage *image = [UIImage imageNamed:@"headButton"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(btnBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateSelected];
    //左边头像
    //    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"headButton"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //右边的按钮
    UIImage *rightImage = [UIImage imageNamed:@"iconGetTask"];
    CGRect rightButtonFrame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
    UIButton *rightButton = [[UIButton alloc] initWithFrame:rightButtonFrame];
    [rightButton addTarget:self action:@selector(btnRightClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:rightImage forState:UIControlStateNormal];
    [rightButton setImage:rightImage forState:UIControlStateSelected];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}
//点击头像
-(void)btnBackClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(PersonalCenterClick)]) {
        [self.delegate PersonalCenterClick];
    }
}
//点击领取任务
-(void)btnRightClick:(id)sender
{
    //    CustomAlertView *customAlertView = [[CustomAlertView alloc] initWithFrame:self.view.bounds alertName:@"领取任务" alertInputContent:@"" alertUnit:@"" keyboardType:UIKeyboardTypeDefault useType:0];
    //
    //    [customAlertView showInView:[[UIApplication sharedApplication] keyWindow]];
    GetTaskAlertView *getTaskView = [[GetTaskAlertView alloc] init];
    getTaskView.delegate = self;
    
    [getTaskView showInView:[[UIApplication sharedApplication] keyWindow]];
    
    return;
    UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"领取任务" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"领取", nil];
    inputAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    inputAlertView.tag = 1001;
    //车牌号的输入框
    if ([inputAlertView textFieldAtIndex:0]) {
        [inputAlertView textFieldAtIndex:0].placeholder = @"请输入车牌号";
        [inputAlertView textFieldAtIndex:0].secureTextEntry = NO;
    }
    //任务编号输入框
    if ([inputAlertView textFieldAtIndex:1]) {
        [inputAlertView textFieldAtIndex:1].placeholder = @"请输入任务编号";
        [inputAlertView textFieldAtIndex:1].secureTextEntry = NO;
    }
    [inputAlertView show];
    
}

//获取数据请求
-(void)requestData
{
    //起始行数
    int spik;
    int allPageNumber;
    //根据请求类型分辨请求行和行数
    switch (pageRequestType) {
        case 0:
        {
            spik = page * pageNumber;
            allPageNumber = pageNumber;
        }
            break;
        case 1:
        {
            spik = 0;
            allPageNumber = (page + 1) * pageNumber;
        }
            break;
        default:
            break;
    }
    //请求获取车辆信息
    requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:[[NSNumber alloc] initWithInt:spik] forKey:@"spik"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:allPageNumber] forKey:@"rows"];
    [requestDic setObject:[[EnvPreferences sharedInstance] getUserId] ? [[EnvPreferences sharedInstance] getUserId] :@"" forKey:@"driverId"];
    if (startTime && ![startTime isEqualToString:@""]) {
        [requestDic setObject:[[NSString alloc] initWithFormat:@"%@ 00:00:00",startTime] forKey:@"startingTime"];
    }
    if (endTime && ![endTime isEqualToString:@""]) {
        [requestDic setObject:[[NSString alloc] initWithFormat:@"%@ 23:59:59",endTime] forKey:@"endTime"];
    }
    
    //请求数据
    [self startWait];
    //获取包车数据
    [[ProtocolDriver sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_charterOrderDriverTask requestType:KRequestType_charterOrderDriverTask];
}

//默认这是起始时间与结束时间
-(void)setDefaultTime
{
    if (_driverModel)
    {
        //时间对象
        NSDate *startDate = [DateUtils stringToDate:_driverModel.createTime];
        startTime = [DateUtils formatDate:startDate format:@"yyyy-MM-dd"];
    }
    else
    {
        //获取年份
        NSString *yearString =[DateUtils formatDate:[NSDate new] format:@"yyyy"];
        startTime = [[NSString alloc] initWithFormat:@"%@-01-01",yearString];
    }
    
    //获取时间Time
    NSDate *now = [NSDate new];
    //加days天
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([now timeIntervalSinceReferenceDate] + 24*3600*7)];
    endTime = [DateUtils formatDate:newDate format:@"yyyy-MM-dd"];
    _leftTime.text = startTime;
    _rightTime.text = endTime;
}
#pragma mark --- GetTaskAlertViewDelegate
- (void)getTaskAlertViewCancel
{

}
- (void)getTaskAlertViewOK:(NSString*)firstContent  secondContent:(NSString*)secondContent
{
    if ([firstContent isEqualToString:@""] || [secondContent isEqualToString:@""])
    {
        [self showTipsView:@"请填写车牌号或任务编号"];
        return;
    }
    NSString *urlSuffixString = [[[NSString alloc] initWithFormat:@"%@?LicensePlate=%@&Schedule=%@&action=%d",Kurl_carpoolOrderDriverTask,firstContent,secondContent,1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self startWait];
    [[ProtocolDriver sharedInstance] putInforWithNSDictionary:nil urlSuffix:urlSuffixString requestType:KRequestType_driverGetCarpoolingTask];
}
#pragma mark --- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1001:
        {
            //点击了领取任务确定
            if (buttonIndex == 1)
            {
                //车牌号
                UITextField *licensePlateField = [alertView textFieldAtIndex:0];
                [licensePlateField resignFirstResponder];
                //任务编号
                UITextField *scheduleField = [alertView textFieldAtIndex:1];
                [scheduleField resignFirstResponder];
                
                if ([licensePlateField.text isEqualToString:@""] || [scheduleField.text isEqualToString:@""])
                {
                    [self showTipsView:@"请填写车牌号或任务编号"];
                    return;
                }
                //请求数据
                //请求字符串
                NSString *urlSuffixString = [[[NSString alloc] initWithFormat:@"%@?LicensePlate=%@&Schedule=%@&action=%d",Kurl_carpoolOrderDriverTask,licensePlateField.text,scheduleField.text,1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [self startWait];
                [[ProtocolDriver sharedInstance] putInforWithNSDictionary:nil urlSuffix:urlSuffixString requestType:KRequestType_driverGetCarpoolingTask];
            }
            else if (buttonIndex == 0)
            {
                //车牌号
                UITextField *licensePlateField = [alertView textFieldAtIndex:0];
                [licensePlateField resignFirstResponder];
                //任务编号
                UITextField *scheduleField = [alertView textFieldAtIndex:1];
                [scheduleField resignFirstResponder];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark --- TopDatePickerViewDelegate
- (void)pickerViewCancel
{
    //消除时间弹出框
    if (topDatePickerView) {
        [topDatePickerView cancelPicker:[[UIApplication sharedApplication] keyWindow]];
    }
    
    topDatePickerView = nil;
}
- (void)pickerViewOK:(NSString*)date
{
    topDatePickerView = nil;
    switch (selectTimeType) {
        case 101:
        {
            //修改的为开始时间
            startTime = date;
            _leftTime.text = startTime;
        }
            break;
        case 102:
        {
            //修改的为结束时间
            endTime = date;
            _rightTime.text = endTime;
        }
            break;
        default:
            break;
    }
    //重新请求数据从第一页开始
    page = 0;
    //请求数据
    pageRequestType = 1;
    [self requestData];
}

#pragma mark --- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _combinationDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;
    
    tempCell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCellId"];
    //类型图标
    UIImageView *taskTypeImage = (UIImageView*)[tempCell viewWithTag:111];
    //类型名称
    UILabel *taskTypeName = (UILabel*)[tempCell viewWithTag:112];
    //任务状态
    UIImageView *taskStatus = (UIImageView*)[tempCell viewWithTag:101];
    //出发地
    UILabel *originName = (UILabel*)[tempCell viewWithTag:102];
    //到达地
    UILabel *destinationName = (UILabel*)[tempCell viewWithTag:103];
    //出发时间
    UILabel *startTimeLabel = (UILabel*)[tempCell viewWithTag:104];
    //回程名称
    UILabel *endNameLabel = (UILabel*)[tempCell viewWithTag:125];
    //回程时间
    UILabel *endTimeLabel = (UILabel*)[tempCell viewWithTag:105];
    
    DriverCombinationTaskModel *combinationTaskModel = _combinationDataSource[indexPath.row];
    
    if (combinationTaskModel.taskType == 1)
    {
        //包车
        DriverTaskModel *taskModel = (DriverTaskModel*)combinationTaskModel.taskObject;
        taskTypeImage.image = [UIImage imageNamed:@"charteredBusIcon"];
        taskTypeName.text = @"包车";
        taskTypeName.textColor =  UIColorFromRGB(0xFF5A37);
        if (taskModel.orderState >= 5)
        {
            //完成任务
            [taskStatus setImage:[UIImage imageNamed:@"taskStatusNowOld"]];
        }
        else
        {
            //当前任务
            [taskStatus setImage:[UIImage imageNamed:@"taskStatusNowIcon"]];
        }
        
        originName.text = taskModel.startName;
        destinationName.text = taskModel.destinationName;
        
        //时间数据转化
        NSDate *startDate = [DateUtils stringToDate:taskModel.startTime];
        NSDate *endDate = [DateUtils stringToDate:taskModel.endTime];
        startTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"]];
        endTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
        endNameLabel.text = @"回程时间";
    }
    else if (combinationTaskModel.taskType == 2)
    {
        taskTypeImage.image = [UIImage imageNamed:@"carpoolingBusIcon"];
        taskTypeName.text = @"拼车";
        taskTypeName.textColor =  UIColorFromRGB(0x06C1AE);
        //拼车
        DriverCarpoolingTaskModel *taskModel = (DriverCarpoolingTaskModel*)combinationTaskModel.taskObject;
        if (taskModel.orderStatus >= 3)
        {
            //完成任务
            [taskStatus setImage:[UIImage imageNamed:@"taskStatusNowOld"]];
        }
        else
        {
            //当前任务
            [taskStatus setImage:[UIImage imageNamed:@"taskStatusNowIcon"]];
        }
        originName.text = taskModel.startingName;
        destinationName.text = taskModel.destinationName;
        //时间数据转化
        NSDate *startDate = [DateUtils stringToDate:taskModel.startingDate];
        NSString *bigTime = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd"]];
        NSString *littleTime = @"00:00";
        if (littleTime.length >= 5) {
            littleTime = [taskModel.startingTime substringToIndex:5];
        }
        startTimeLabel.text = [[NSString alloc] initWithFormat:@"%@ %@",bigTime,littleTime];
        endTimeLabel.text = @"";
        endNameLabel.text = @"";
    }
    
    return tempCell;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DriverCombinationTaskModel *combinationTaskModel = _combinationDataSource[indexPath.row];
    if (combinationTaskModel.taskType == 1)
    {
        return 204.f;
    }
    else
    {
        return 177.f;
    }
    return 204.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *taskDetailViewController ;
    DriverCombinationTaskModel *combinationTaskModel = _combinationDataSource[indexPath.row];
    if (combinationTaskModel.taskType == 1) {
        //包车
        //跳入包车页面
        taskDetailViewController = (DriverPackTaskDetailViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"TaskPackDetailViewControllerId"];
        DriverTaskModel *tempModel = (DriverTaskModel*)combinationTaskModel.taskObject;
        ((DriverPackTaskDetailViewController*)taskDetailViewController).taskModel = tempModel;
        ((DriverPackTaskDetailViewController*)taskDetailViewController).mapView = [MAMapView new];
    }
    else if (combinationTaskModel.taskType == 2)
    {
        //拼车
        //跳入拼车页面
        taskDetailViewController = (DriverTaskDetailViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"TaskDetailViewControllerId"];
        DriverCarpoolingTaskModel *tempModel = (DriverCarpoolingTaskModel*)combinationTaskModel.taskObject;
        ((DriverTaskDetailViewController*)taskDetailViewController).taskModel = tempModel;
        ((DriverTaskDetailViewController*)taskDetailViewController).mapView = [MAMapView new];
    }
    [self.navigationController pushViewController:taskDetailViewController animated:YES];
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
    
    ResultDataModel *resultParse = (ResultDataModel *)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_charterOrderDriverTask:
        {
            //返回结果
            if (resultParse.resultCode == 0) {
                //清空数据
                if (pageRequestType == 1 || !_combinationDataSource) {
                    _combinationDataSource = [[NSMutableArray alloc] init];
                }
                
                NSMutableArray *tempArray = [resultParse.data objectForKey:@"list"];
                //数据解析
                for (NSDictionary *tempDic in tempArray) {
                    DriverTaskModel *taskModel = [[DriverTaskModel alloc] initWithDictionary:tempDic];
                    //拼装的数据模型
                    DriverCombinationTaskModel *combinationTaskModel = [[DriverCombinationTaskModel alloc] init];
                    combinationTaskModel.taskType = 1;
                    if (taskModel.orderState <= 3) {
                        combinationTaskModel.taskState = 1;
                    }
                    else if (taskModel.orderState == 4){
                        combinationTaskModel.taskState = 2;
                    }
                    else if (taskModel.orderState >= 5){
                        combinationTaskModel.taskState = 3;
                    }
                    combinationTaskModel.taskStartDate = [DateUtils stringToDate:taskModel.startTime];
                    combinationTaskModel.taskObject = taskModel;
                    //包车数据
                    [_combinationDataSource addObject:combinationTaskModel];
                }
                //对数据进行排序
                _combinationDataSource = (NSMutableArray*)[self sortArray:_combinationDataSource];
                //重新刷新数据
                [_mainTableView reloadData];
                //清除刷新头部和底部
                [_mainTableView.header endRefreshing];
                [_mainTableView.footer endRefreshing];
            }
            //获取拼车任务列表
            [[ProtocolDriver sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_carpoolOrderDriverTask requestType:KRequestType_driverCarpoolingTask];
        }
            break;
        case KRequestType_memberinfo:
        {
            if (resultParse.resultCode == 0)
            {
                //返回的司机数据
                if ([resultParse.data objectForKey:@"driver"] && [[resultParse.data objectForKey:@"driver"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *driverDic = [resultParse.data objectForKey:@"driver"];
                    _driverModel = [[DriverModel alloc] initWithDictionary:driverDic];
                }
            }
            //设置按钮显示时间
            [self setDefaultTime];
        }
            break;
        case KRequestType_driverGetCarpoolingTask:
        {
            //获取任务列表请求
            if (resultParse.resultCode == 0)
            {
                //重新请求数据加载包车
                [self showTipsView:@"任务领取成功"];
            }
            else
            {
                [self showTipsView:@"无此拼车任务领取"];
            }
        }
            break;
        case KRequestType_driverCarpoolingTask:
        {
            if (resultParse.resultCode == 0)
            {
                //对返回对数据进行处理
                if (!_combinationDataSource) {
                    _combinationDataSource = [[NSMutableArray alloc] init];
                }
                
                NSMutableArray *tempArray = [resultParse.data objectForKey:@"list"];
                //数据解析
                for (NSDictionary *tempDic in tempArray) {
                    DriverCarpoolingTaskModel *taskModel = [[DriverCarpoolingTaskModel alloc] initWithDictionary:tempDic];
                    //拼装的数据模型
                    DriverCombinationTaskModel *combinationTaskModel = [[DriverCombinationTaskModel alloc] init];
                    combinationTaskModel.taskType = 2;
                    combinationTaskModel.taskState = taskModel.orderStatus;
                    combinationTaskModel.taskStartDate = [DateUtils stringToDate:taskModel.startingDate];
                    combinationTaskModel.taskObject = taskModel;
                    //包车数据
                    [_combinationDataSource addObject:combinationTaskModel];
                }
                
                _combinationDataSource = (NSMutableArray*)[self sortArray:_combinationDataSource];
                //重新刷新数据
                [_mainTableView reloadData];
                //清除刷新头部和底部
                [_mainTableView.header endRefreshing];
                [_mainTableView.footer endRefreshing];
            }
            else
            {
                [self showTipsView:@"无此拼车任务领取"];
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

#pragma mark --- 数组排序

-(NSMutableArray *)sortArray:(NSMutableArray *)array
{
    NSSortDescriptor *taskStateDesc = [NSSortDescriptor sortDescriptorWithKey:@"taskState" ascending:YES];
    NSSortDescriptor *taskStartDateDesc = [NSSortDescriptor sortDescriptorWithKey:@"taskStartDate" ascending:YES];
//    NSSortDescriptor *personAgeDesc = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    //把排序描述器放进数组里，放入的顺序就是你想要排序的顺序
    //NSMutableArray这里是：首先按照年龄排序，然后是车的名字，最后是按照人的名字
    NSMutableArray *descriptorArray = [NSMutableArray arrayWithObjects:taskStateDesc,taskStartDateDesc, nil];
    
    [array sortUsingDescriptors: descriptorArray];
//    DBG_MSG(@"%@",array);
    return array;
}


#pragma mark---

- (IBAction)menuclick:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
