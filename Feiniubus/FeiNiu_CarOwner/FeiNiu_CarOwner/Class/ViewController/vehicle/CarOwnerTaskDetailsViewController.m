//
//  CarOwnerTaskDetailsViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/26.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerTaskDetailsViewController.h"
#import "ProtocolCarOwner.h"
#import "CarOwnerTaskModel.h"
#import <FNUIView/MJRefresh.h>

@interface CarOwnerTaskDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    //第几页
    int page;
    //一页数量
    int pageNumber;
    //请求类型 0代表累加数据刷新请求，1代表所有数据刷新的请求
    int pageRequestType;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation CarOwnerTaskDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    pageRequestType = 1;
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

-(void)initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    //初始化分页值
    page = 0;
    pageNumber = onePageNumber;
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
    //设置错误布局
    [_mainTableView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(46);
    }];
    
}
//请求数据
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
    [requestDic setObject:_vehicleId forKey:@"vehicleId"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:spik] forKey:@"spik"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:allRows] forKey:@"rows"];
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_charterOrderVehicleTask requestType:KRequestType_charterOrderVehicleTask];
}
#pragma mark ---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell = nil;
    CarOwnerTaskModel *taskModel = _dataSource[indexPath.section];
    switch (indexPath.row) {
        case 0:
        {
            tempCell= [tableView dequeueReusableCellWithIdentifier:@"taskTimeCellIdent"];
            //任务开始时间
            UILabel *startTimeLabel = (UILabel*)[tempCell viewWithTag:101];
            startTimeLabel.text = taskModel.startTime;
            //任务结束时间
            UILabel *endTimeLabel = (UILabel*)[tempCell viewWithTag:102];
            endTimeLabel.text = taskModel.endTime;
            //任务价格
            UILabel *priceLabel = (UILabel*)[tempCell viewWithTag:103];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元",taskModel.price/100.f];
            
        }
            break;
        case 1:
        {
            tempCell= [tableView dequeueReusableCellWithIdentifier:@"taskAddressCellIdent"];
            //起始地
            UILabel *startNameLabel = (UILabel*)[tempCell viewWithTag:101];
            startNameLabel.text = taskModel.startName;
            //目的地
            UILabel *destinationNameLabel = (UILabel*)[tempCell viewWithTag:102];
            destinationNameLabel.text = taskModel.destinationName;
        }
            break;
        case 2:
        {
            tempCell= [tableView dequeueReusableCellWithIdentifier:@"taskInforCellldent"];
            //行驶距离
            UILabel *mileageLabel = (UILabel*)[tempCell viewWithTag:101];
            mileageLabel.text = [[NSString alloc] initWithFormat:@"%.2fkm",taskModel.mileage];
            //驾驶员
            UILabel *driverNameLabel = (UILabel*)[tempCell viewWithTag:102];
            driverNameLabel.text = taskModel.driverName;
        }
            break;
        default:
            break;
    }
    return tempCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}


#pragma makr ---UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 45;
            break;
        case 1:
            return 97;
            break;
        case 2:
            return 60;
            break;
        default:
            break;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
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

    //请求类型
    switch (resultParse.requestType) {
        case KRequestType_charterOrderVehicleTask:
        {
            if (resultParse.resultCode == 0)
            {
                //清空数据
                if (pageRequestType == 1 || !_dataSource) {
                    _dataSource = [[NSMutableArray alloc] init];
                }
                NSMutableArray *tempArray = (NSMutableArray*)[resultParse.data objectForKey:@"list"];
                for (NSDictionary *tempDic in tempArray) {
                    CarOwnerTaskModel *taskModel = [[CarOwnerTaskModel alloc] initWithDictionary:tempDic];
                    [_dataSource addObject:taskModel];
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
    //清除刷新头部和底部
    [_mainTableView.header endRefreshing];
    [_mainTableView.footer endRefreshing];
}

@end












