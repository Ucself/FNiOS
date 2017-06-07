//
//  CarOwnerDriverMainViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerDriverMainViewController.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import <FNUIView/RatingBar.h>
#import "ProtocolCarOwner.h"
#import "CarOwnerDriverModel.h"
#import "CarOwnerEditorDriverViewController.h"
#import <FNUIView/MJRefresh.h>
#import "CarOwnerDriverInforViewController.h"

@interface CarOwnerDriverMainViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    //第几页
    int page;
    //一页数量
    int pageNumber;
    //请求类型 0代表累加数据刷新请求，1代表所有数据刷新的请求
    int pageRequestType;
    //搜索关键字
    NSString *searchKey;
}


@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addDriverButtonItem;
@property (nonatomic,strong) NSMutableArray *dataSourceArray;



@end

@implementation CarOwnerDriverMainViewController

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
    //请求数据
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


- (IBAction)addDriverClick:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Driver" bundle:nil];
    //登录相关控制器
    CarOwnerEditorDriverViewController *tempEditorDriver = [storyboard instantiateViewControllerWithIdentifier:@"EditorDriverViewIdent"];
    tempEditorDriver.controllerType = ControllerTypeAddDriver;
    //添加驾驶员
    [self hideKeyboard];
    [self.navigationController pushViewController:tempEditorDriver animated:YES];
}
#pragma mark ---

-(void)initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    //初始化分页值
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
    //设置添加车辆按钮字体大小
    [_addDriverButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
}
//即将显示加载数据
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
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    //    [tempDic setObject:@"0" forKey:@"driverStatus"];
    [tempDic setObject:searchKey forKey:@"name"];
    //    [tempDic setObject:@"0" forKey:@"score"];
    //    [tempDic setObject:@"0" forKey:@"ageMax"];
    //    [tempDic setObject:@"0" forKey:@"ageMin"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:spik] forKey:@"spik"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:allRows] forKey:@"rows"];
    //请求服务器数据
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:tempDic urlSuffix:Kurl_driver requestType:KRequestType_getDriver];
    
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

-(void)setSeachBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    self.searchBar.barStyle     = UIBarStyleBlackTranslucent;
    self.searchBar.translucent  = YES;
    //    self.searchBar.delegate     = self;
    self.searchBar.placeholder = @"搜索驾驶员";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.alpha = 0.5f;
    self.searchBar.enablesReturnKeyAutomatically = NO;
    
    self.searchBar.backgroundColor=[UIColor clearColor];
    //设置输入框背景色
    UIView *searchTextField = nil;
    self.searchBar.barTintColor = [UIColor whiteColor];
    searchTextField = [[[self.searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.backgroundColor = UIColorFromRGB(0xF6F6F6);
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
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

#pragma mark ---UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CarOwnerDriverModel *driverModel = (CarOwnerDriverModel*)[_dataSourceArray objectAtIndex:indexPath.row];
    
    UITableViewCell *tempCell = nil;
    tempCell = [tableView dequeueReusableCellWithIdentifier:@"throughDriverCellIdent"];
    //头像
    UIImageView *headImageVIew = (UIImageView*)[tempCell viewWithTag:101];
    //名称
    UILabel *nameLable = (UILabel*)[tempCell viewWithTag:102];
    //电话号码
    UILabel *phoneLable = (UILabel*)[tempCell viewWithTag:103];
    //星级评分
    UILabel *ratingLable = (UILabel*)[tempCell viewWithTag:104];
    //星级显示
    RatingBar *tempRatingBar = (RatingBar*)[tempCell viewWithTag:107];
    //里程数据
    UILabel *mileageLable = (UILabel*)[tempCell viewWithTag:105];
    //状态显示
    UIImageView *auditImageVIew = (UIImageView*)[tempCell viewWithTag:106];
    UILabel *auditLable = (UILabel*)[tempCell viewWithTag:108];
    
    //设置默认头像defaultDriver
    [headImageVIew setImage:[UIImage imageNamed:@"defaultDriver"]];
    [headImageVIew setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,driverModel.driverHead]]];
    
    nameLable.text = driverModel.driverName;
    
    phoneLable.text = driverModel.driverPhone;
    
    ratingLable.text = [[NSString alloc] initWithFormat:@"%.1f分",driverModel.driverRating];
    
    tempRatingBar.interval = 2;
    [tempRatingBar setImageDeselected:@"small_star_nor" halfSelected:@"small_star_half" fullSelected:@"small_star_press" andDelegate:nil];
    [tempRatingBar setIsIndicator:YES];
    [tempRatingBar displayRating:driverModel.driverRating];
    
    mileageLable.text = [[NSString alloc] initWithFormat:@"%.2fkm",driverModel.driverMileage];
    
    //图片 名称 reviewIngIcon(审核中) reviewFailureIcon(未通过)  reviewOnlineIcon(通过)
    //审核状态
    switch (driverModel.driverAudit) {
        case 2:
        {
            //reviewOnlineIcon
            auditLable.text = @"已通过";
            [auditImageVIew setImage:[UIImage imageNamed:@"reviewOnlineIcon"]];
        }
            break;
        case 3:
        {
            //reviewOnlineIcon
            auditLable.text = @"未通过";
            [auditImageVIew setImage:[UIImage imageNamed:@"reviewFailureIcon"]];
        }
            break;
        default:
        {
            auditLable.text = @"审核中";
            [auditImageVIew setImage:[UIImage imageNamed:@"reviewIngIcon"]];
        }
            break;
    }
    
    return tempCell;
    
}
#pragma mark ---UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Driver" bundle:nil];
    //登录相关控制器
    CarOwnerEditorDriverViewController *tempEditorDriver = [storyboard instantiateViewControllerWithIdentifier:@"EditorDriverViewIdent"];
    CarOwnerDriverModel *driverModel = (CarOwnerDriverModel*)[_dataSourceArray objectAtIndex:indexPath.row];
    switch (driverModel.driverAudit) {
        case 2:
        {
            //审核通过
//            [self performSegueWithIdentifier:@"toDriverInfor" sender:self];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Driver" bundle:nil];
            CarOwnerDriverInforViewController *driverInforViewController = [storyboard instantiateViewControllerWithIdentifier:@"DriverInforViewControllerId"];
            driverInforViewController.driverModel = (CarOwnerDriverModel*)[_dataSourceArray objectAtIndex:indexPath.row];
            
            [self.navigationController pushViewController:driverInforViewController animated:YES];
        }
            break;
        case 3:
        {
            //审核失败
            tempEditorDriver.controllerType = ControllerTypeErrorDriver;
            tempEditorDriver.driverId = driverModel.driverId;
            [self.navigationController pushViewController:tempEditorDriver animated:YES];
        }
            break;
        default:
        {
            //0 或者 1的时候
            //审核中
            tempEditorDriver.controllerType = ControllerTypeEditorDriver;
            tempEditorDriver.driverId = driverModel.driverId;
            [self.navigationController pushViewController:tempEditorDriver animated:YES];
        }
            break;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
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
        case KRequestType_getDriver:
        {
            //更新驾驶员数据
            if (resultParse.resultCode == 0)
            {
                //清空数据
                if (pageRequestType == 1 || !_dataSourceArray) {
                    _dataSourceArray = [[NSMutableArray alloc] init];
                }
                for (NSDictionary *tempDic in (NSArray*)[resultParse.data objectForKey:@"list"])
                {
                    CarOwnerDriverModel *tempModel = [[CarOwnerDriverModel alloc] initWithDictionary:tempDic];
                    //加入数据源
                    [_dataSourceArray addObject:tempModel];
                }
                
                [_mainTableView reloadData];
                
            }
            else
            {
                [self showTipsView:@"数据拉取失败"];
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






