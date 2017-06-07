//
//  CarOwnerCompanySearchViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerSearchViewController.h"
#import "ProtocolCarOwner.h"

@interface CarOwnerSearchViewController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) UISearchBar *searchBar;
//数据源
@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation CarOwnerSearchViewController

@dynamic delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
//    [self setSeachBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //请求数据
     NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:self.startTime forKey:@"startTime"];
    [requestDic setObject:self.endTime forKey:@"endTime"];
    
    switch (self.requestType) {
        case RequestDataTypeVehicle:
        {
            //加载等待符号
            [self startWait];
            [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_vehiclefree requestType:KRequestType_getvehiclefree];
            
        }
            break;
        case RequestDataTypeDriver:
        {
            [self startWait];
            [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_driverfree requestType:KRequestType_getdriverfree];
        }
            break;
            
        default:
            break;
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
//初始化界面
-(void) initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    //根据类型设置展示界面
    switch (self.requestType) {
        case RequestDataTypeVehicle:
        {
            self.navigationItem.title = @"请选择车辆";
        }
            break;
        case RequestDataTypeDriver:
        {
            self.navigationItem.title = @"请选择驾驶员";
        }
            break;
        default:
            break;
    }
}

-(void)setSeachBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    self.searchBar.barStyle     = UIBarStyleBlackTranslucent;
    self.searchBar.translucent  = YES;
    //    self.searchBar.delegate     = self;
    self.searchBar.placeholder = @"搜索公司";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.alpha = 0.5f;
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
#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.f;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20.f;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.1f;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    if ([self.delegate respondsToSelector:@selector(seachSelected:requestType:)]) {
        [self.delegate  seachSelected:_dataSource[indexPath.row] requestType:_requestType];
    }
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [UIView new];
//}

#pragma mark --- UITableViewDataSource

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//        case 0:
//            return @"A";
//            break;
//        case 1:
//            return @"D";
//            break;
//        case 2:
//            return @"E";
//            break;
//        default:
//            break;
//    }
//    return @"C";
//}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 3;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell = [tableView dequeueReusableCellWithIdentifier:@"seachCellIdent"];
    
    if ([self.dataSource isKindOfClass:[NSMutableArray class]]) {
        //一行数据为字典
        NSDictionary *tempDic = (NSDictionary *)self.dataSource[indexPath.row];
        
        switch (_requestType) {
            case RequestDataTypeVehicle:
            {
                //车辆数据加载
                tempCell.textLabel.text = [tempDic objectForKey:@"licensePlate"] ? [tempDic objectForKey:@"licensePlate"] : @"";
                tempCell.detailTextLabel.text =  @"";
            }
                break;
            case RequestDataTypeDriver:
            {
                //驾驶员数据加载
                tempCell.textLabel.text = [tempDic objectForKey:@"name"] ? [tempDic objectForKey:@"name"] : @"";
                tempCell.detailTextLabel.text = [tempDic objectForKey:@"phone"] ? [tempDic objectForKey:@"phone"] : @"";
            }
                break;
            default:
                break;
        }
    }
    
    return tempCell;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    tableView.sectionIndexColor = UIColorFromRGB(0xFF5A37);
//    
//    return [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E", nil];
//}

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
        case KRequestType_getvehiclefree:
        {
            if (resultParse.resultCode == 0) {
                self.dataSource = [[NSMutableArray alloc] init];
                //设置数据源
                self.dataSource = (NSMutableArray*)[resultParse.data objectForKey:@"data"];
                //重新加载数据
                [_mainTableView reloadData];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        case KRequestType_getdriverfree:
        {
            if (resultParse.resultCode == 0)
            {
                //设置数据源
                self.dataSource = (NSMutableArray*)[resultParse.data objectForKey:@"data"];
                //重新加载数据
                [_mainTableView reloadData];
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


@end
