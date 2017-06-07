//
//  CarOwnerCompanySearchViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerDriverSearchViewController.h"
#import "ProtocolCarOwner.h"
#import "CarOwnerCompanySourceModel.h"

@interface CarOwnerDriverSearchViewController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    //原始数据
    NSMutableArray *originalDataSource;
    //筛选出来的数组
    NSMutableArray *filterDataSourceArray;
    //筛选出来的数据源
    NSMutableDictionary *filterDataSourceDic;
    //筛选出来的Keys值数据
    NSMutableArray *filterAllKeys;
    
    
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) UISearchBar *searchBar;

@end

@implementation CarOwnerDriverSearchViewController

@dynamic delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
    [self setSeachBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //界面显示的时候需要加载的数据
    [self initInterfaceWillAppear];
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
-(void) initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
}

-(void) initInterfaceWillAppear
{
    //请求获取所有获取数据
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:@"" forKey:@"name"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"spik"];
    [requestDic setObject:[[NSNumber alloc] initWithInt:999999] forKey:@"rows"];//设置足够大的数据
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_company requestType:KRequestType_company];
}

-(void)setSeachBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    self.searchBar.barStyle     = UIBarStyleBlackTranslucent;
    self.searchBar.translucent  = YES;
    self.searchBar.placeholder = @"搜索未配置的驾驶员";
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

//数据进行处理
-(void)processDataSource
{
    CarOwnerCompanySourceModel *tempMdel = [[CarOwnerCompanySourceModel alloc] initWithData:filterDataSourceArray];
    //筛选
    filterDataSourceDic = tempMdel.returnDic;
    filterAllKeys = (NSMutableArray*)[filterDataSourceDic allKeys];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    filterAllKeys = (NSMutableArray*)[filterAllKeys sortedArrayUsingComparator:sort];
    
}

#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideKeyboard];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@",searchText];
    filterDataSourceArray = (NSMutableArray*)[originalDataSource filteredArrayUsingPredicate:predicate];
    
    //对数据进行处理
    [self processDataSource];
    
    [_mainTableView reloadData];
}
#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    //选择的字典
    NSMutableArray *sectionArray = [filterDataSourceDic objectForKey:filterAllKeys[indexPath.section]];
    NSObject *selectObjet = sectionArray[indexPath.row];
    //返回选择的值
    if ([self.delegate respondsToSelector:@selector(seachSelected:)]) {
        [self.delegate seachSelected:selectObjet];
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

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    //    view.tintColor = UIColorFromRGB(0xF5F5F5);
    view.tintColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
#pragma mark --- UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return filterAllKeys[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return filterAllKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *sectionArray = (NSMutableArray*)[filterDataSourceDic objectForKey:filterAllKeys[section]];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell = [tableView dequeueReusableCellWithIdentifier:@"seachCompanyCellIdent"];
    
    NSMutableArray *cellArray = [filterDataSourceDic objectForKey:filterAllKeys[indexPath.section]];
    
    NSDictionary *cellDic = (NSDictionary*)cellArray[indexPath.row];
    
    if ([cellDic objectForKey:@"name"]) {
        tempCell.textLabel.text = [cellDic objectForKey:@"name"];
    }
    
    return tempCell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    tableView.sectionIndexColor = UIColorFromRGB(0xFF5A37);
    
    return filterAllKeys;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
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
        case KRequestType_company:
        {
            //如果返回存在此对象
            if ([resultParse.data objectForKey:@"list"]) {
                originalDataSource = [resultParse.data objectForKey:@"list"];
            }
            filterDataSourceArray = originalDataSource;
            //对数据进行处理
            [self processDataSource];
            
            [_mainTableView reloadData];
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
