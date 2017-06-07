//
//  CarOwnerVehicleMainViewCintroller.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/8.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerVehicleMainViewController.h"
#import "ProtocolCarOwner.h"
#import "CarOwnerVehicleModel.h"
#import "CarOwnerAddVehicleViewController.h"
#import "CarOwnerVehicleInforViewController.h"
#import <FNUIView/MJRefresh.h>

@interface CarOwnerVehicleMainViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CarOwnerVehicleInforViewControllerDelegate>
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addVehicleButtonItem;

@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation CarOwnerVehicleMainViewController

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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取数据
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
#pragma mark ---
-(void)setSeachBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    self.searchBar.barStyle     = UIBarStyleBlackTranslucent;
    self.searchBar.translucent  = YES;
    self.searchBar.placeholder = @"搜索车辆信息";
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

-(void) initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    //搜索数据初始化
    page = 0;
    pageNumber = onePageNumber;
    searchKey = @"";
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    //设置添加车辆按钮字体大小
    [_addVehicleButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
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
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    [tempDic setObject:[[NSNumber alloc] initWithInt:spik] forKey:@"spik"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:allPageNumber] forKey:@"rows"];
    [tempDic setObject:searchKey forKey:@"searchKey"];
    //请求数据
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:tempDic urlSuffix:Kurl_vehicle requestType:KRequestType_getvehicle];
}

- (IBAction)addVehicleClick:(id)sender {
    //获取对象
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Vehicle" bundle:nil];
    //编辑车辆，添加车辆，审核失败车辆控制器
    CarOwnerAddVehicleViewController *editVehicleControl = [storyboard instantiateViewControllerWithIdentifier:@"editVehicleControlIdent"];
    editVehicleControl.editorType = EditorTypeAdd;
    [self.navigationController pushViewController:editVehicleControl animated:YES];
}
//隐藏键盘
-(void)hideKeyboard
{
    [self.searchBar resignFirstResponder];
}
#pragma mark -- CarOwnerVehicleInforViewControllerDelegate

-(void)controllerReturnBack
{
    
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[[event allTouches] anyObject];
    if (touch.tapCount >=1) {
        [self hideKeyboard];
    }
}
#pragma mark -- <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //先让键盘消失
    [self.searchBar resignFirstResponder];
    //获取对象
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Vehicle" bundle:nil];
    CarOwnerVehicleModel *vehicleModel = [_dataSource objectAtIndex:indexPath.row];
    //根据车辆状态显示不同信息
    switch (vehicleModel.audit) {
        case 12:
        {
            //审核失败的车辆
            CarOwnerAddVehicleViewController *editVehicleControl = [storyboard instantiateViewControllerWithIdentifier:@"editVehicleControlIdent"];
            editVehicleControl.vehicleModel = vehicleModel;
            editVehicleControl.editorType = EditorTypeError;
            [self.navigationController pushViewController:editVehicleControl animated:YES];
        }
            break;
        case 11:
        {
            //审核通过的车辆
            CarOwnerVehicleInforViewController *vehicleInforControl = [storyboard instantiateViewControllerWithIdentifier:@"vehicleInforControlIdent"];
            vehicleInforControl.vehicleModel = vehicleModel;
            vehicleInforControl.delegate = self;
            [self.navigationController pushViewController:vehicleInforControl animated:YES];
        }
            break;
        default:
        {
            //审核中的车辆
            CarOwnerAddVehicleViewController *editVehicleControl = [storyboard instantiateViewControllerWithIdentifier:@"editVehicleControlIdent"];
            editVehicleControl.vehicleModel = vehicleModel;
            editVehicleControl.editorType = EditorTypeEditor;
            [self.navigationController pushViewController:editVehicleControl animated:YES];
        }
            break;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}
#pragma mark -- <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //数据源
    CarOwnerVehicleModel *vehicleModel = [_dataSource objectAtIndex:indexPath.row];
    UITableViewCell *tempCell;
    if (vehicleModel.audit == 11)
    {
        tempCell = [tableView dequeueReusableCellWithIdentifier:@"throughVehicleCellIdent"];
    }
    else
    {
        tempCell = [tableView dequeueReusableCellWithIdentifier:@"vehicleCellIdent"];
    }
    //获取对象
    UIImageView *headImage = (UIImageView*)[tempCell viewWithTag:101];
    UILabel *licensePlateLabel = (UILabel*)[tempCell viewWithTag:102];
    UILabel *seatsLabel = (UILabel*)[tempCell viewWithTag:103];
    UILabel *ageLabel = (UILabel*)[tempCell viewWithTag:104];
    UILabel *fuelTypeLabel = (UILabel*)[tempCell viewWithTag:105];
    UILabel *LevelTypeLabel = (UILabel*)[tempCell viewWithTag:106];
    UIImageView *auditImage = (UIImageView*)[tempCell viewWithTag:107];
    UILabel *auditLabel = (UILabel*)[tempCell viewWithTag:108];
    UILabel *businessOrLastQuotationLabel = (UILabel*)[tempCell viewWithTag:109];
    //    [headImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://b.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=db4a2ba0b07eca80125031e3a413bbeb/4d086e061d950a7b6b53c3470ad162d9f3d3c9cb.jpg"]]];
    //设置默认头像defaultVehicle
    [headImage setImage:[UIImage imageNamed:@"defaultVehicle"]];
    //相关数据展示到页面
    if ([vehicleModel.extension objectForKey:VehiclePhoto])
    {
        CarOwnerVehiclePhotoModel *vehiclePhotoModel = (CarOwnerVehiclePhotoModel*)[vehicleModel.extension objectForKey:VehiclePhoto];
        [headImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,vehiclePhotoModel.sideUrl]]];
        
    }
    licensePlateLabel.text = vehicleModel.licensePlate;
    seatsLabel.text = [[NSString alloc] initWithFormat:@"%d%@",vehicleModel.seats,@"座"];
    //计算车龄
    NSTimeInterval late1=[[DateUtils stringToDate:vehicleModel.registerTime] timeIntervalSince1970]*1;
    NSTimeInterval late2=[[NSDate date] timeIntervalSince1970]*1;
    NSTimeInterval cha=late2-late1;
    
    ageLabel.text = [[NSString alloc] initWithFormat:@"%.1f%@",cha/(60.0*60.0*24.0*365.0),@"年"];
    fuelTypeLabel.text = vehicleModel.fuelTypeName;
    LevelTypeLabel.text = [[NSString alloc] initWithFormat:@"%@%@",vehicleModel.levelName,vehicleModel.typeName];
    //根据车辆状态显示不同信息
    switch (vehicleModel.audit) {
        case 10:
        {
            auditLabel.text = @"审核中";
            [auditImage setImage:[UIImage imageNamed:@"reviewIngIcon"]];
            businessOrLastQuotationLabel.text = vehicleModel.businessScopeName;
        }
            break;
        case 11:
        {
            if (vehicleModel.state == 1)
            {
                //在线
                auditLabel.text = @"在线";
                [auditImage setImage:[UIImage imageNamed:@"reviewOnlineIcon"]];
                businessOrLastQuotationLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",vehicleModel.lastQuotation/100.f,@"元"];
            }
            else
            {
                //离线
                auditLabel.text = @"离线";
                [auditImage setImage:[UIImage imageNamed:@"reviewOutlineIcon"]];
                businessOrLastQuotationLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",vehicleModel.lastQuotation/100.f,@"元"];
            }
        }
            break;
        case 12:
        {
            auditLabel.text = @"未通过";
            [auditImage setImage:[UIImage imageNamed:@"reviewFailureIcon"]];
            businessOrLastQuotationLabel.text = vehicleModel.businessScopeName;
        }
            break;
        default:
        {
            auditLabel.text = @"审核中";
            [auditImage setImage:[UIImage imageNamed:@"reviewIngIcon"]];
            businessOrLastQuotationLabel.text = vehicleModel.businessScopeName;
        }
            break;
    }
    
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
    
    switch (resultParse.requestType) {
        case KRequestType_getvehicle:
        {
            //更新驾驶员数据
            if (resultParse.resultCode == 0)
            {
                //清空数据
                if (pageRequestType == 1 || !_dataSource) {
                    _dataSource = [[NSMutableArray alloc] init];
                }
                
                //结构体
                NSArray *resultDic = [resultParse.data objectForKey:@"list"];
                for (NSDictionary *temp in resultDic) {
                    CarOwnerVehicleModel *vehicleModel = [[CarOwnerVehicleModel alloc] initWithDictionary:temp];
                    [_dataSource addObject:vehicleModel];
                }
                //重新刷新数据
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


#pragma mark ----


@end
