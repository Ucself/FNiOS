//
//  SelectDestViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "SelectDestViewController.h"
#import <FNUIView/NumberView.h>
#import "CityNameCollectionViewCell.h"
#import <FNCommon/JsonUtils.h>
#import <FNUIView/MBProgressHUD.h>
#import "SelectDestModel.h"
#import "CachedataPreferences.h"
#import "RuleViewController.h"

#define StartPageID 0
#define EndPageID 1

#define CellColor [UIColor colorWithRed:254/255.0 green:113/255.0 blue:75/255.0 alpha:1]
#define CellColorNormal [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

@interface SelectDestViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    //筛选出来的数组
    NSMutableArray *filterDataSourceArray;
    //筛选出来的数据源
    NSMutableDictionary *filterDataSourceDic;
}

@property (weak, nonatomic) IBOutlet UICollectionView *selectCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *selectTableView;   //修改为分组列表显示lbj添加功能代码，下面对应数据源协议也是 2015年12月09日15:53:34
@property (nonatomic,strong) UICollectionView *historyCollectionView;
//搜索输入框
@property (nonatomic,strong) UISearchBar *searchBar;

//筛选出来的Keys值数据
@property (nonatomic,copy) NSMutableArray *filterAllKeys;


@property(nonatomic, strong) NSArray *array;

- (void)initUserInterfaceData;

@end

@implementation SelectDestViewController

#pragma mark -- view cycle life
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置委托 //修改为分组列表显示lbj添加功能代码，下面对应数据源协议也是 2015年12月09日15:53:34
    _selectTableView.delegate = self;
    _selectTableView.dataSource = self;
    
    //如果是出发地则显示Colltion在上
    if (_pageId == StartPageID)
    {
        [self.view bringSubviewToFront:_selectCollectionView];
    }
    else if (_pageId == EndPageID)
    {
        //目的地特殊按钮
        [self endPageControlsInit];
    }
    
    [self initUserInterfaceData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated
{

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -- initilized UI data

- (void)initUserInterfaceData{
    
    [self startWait];
        
    [self loadingCityName:self.pageId];
}


- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    int type = resultData.requestType;
    
    if (type == FNUserRequestType_CarpoolStartingCitys) {
        
        self.array = resultData.data[@"list"];
        
        [self.selectCollectionView reloadData];
        
        //修改为列表对数据进行分词 2015年12月09日15:53:29
        filterDataSourceArray = (NSMutableArray*)self.array;
        [self processDataSource];
        [_selectTableView reloadData];

    }
    else if (type == FNUserRequestType_CarpoolDestinationCitys){
    
        self.array = resultData.data[@"list"];
        [self.selectCollectionView reloadData];
        
        //修改为列表对数据进行分词 2015年12月09日15:53:29
        filterDataSourceArray = (NSMutableArray*)self.array;
        [self processDataSource];
        [_selectTableView reloadData];
    }
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
}

//loading city data
- (void)loadingCityName:(int)pageId{
    
    if (pageId == StartPageID) {
        
        self.navigationItem.title = @"请选择出发地";
        [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolStartingCitys params:nil];
        
    }else if(pageId == EndPageID){
        
        self.navigationItem.title = @"请选择目的地";       
        [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolDestinationCitys params:^(NetParams *params) {
            params.data = @{@"adCode":self.adCodeId};
        }];
    }
}

//目的地单独显示的界面控件
-(void) endPageControlsInit
{
    //添加右边的申请路线按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"申请路线" style:UIBarButtonItemStyleBordered target:self action:@selector(applyCourseClick)];
    self.navigationItem.rightBarButtonItems  = @[rightItem];
    //添加搜索目的地
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 29)];
//    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.barStyle     = UIBarStyleBlackTranslucent;
    self.searchBar.translucent  = YES;
    self.searchBar.placeholder  = @"搜索目的地";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.alpha        = 0.5f;
    self.searchBar.backgroundColor= [UIColor clearColor];
    self.searchBar.enablesReturnKeyAutomatically = NO;
    //设置输入框背景色
    UIView *searchTextField = nil;
    self.searchBar.barTintColor = [UIColor whiteColor];
    searchTextField = [[[self.searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.backgroundColor = UIColorFromRGB(0xF6F6F6);
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
}
//点击了申请开通路线
-(void)applyCourseClick
{
    //使用webView查看
    RuleViewController *ruleViewController = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    ruleViewController.vcTitle = @"申请开通路线";
    ruleViewController.urlString = [[NSString alloc] initWithFormat:@"%@%@",KTopLevelDomainAddr,@"openingLine"];
    [self.navigationController pushViewController:ruleViewController animated:YES];
}

//数据进行处理
-(void)processDataSource
{
    SelectDestModel *tempMdel = [[SelectDestModel alloc] initWithData:filterDataSourceArray];
    //筛选
    filterDataSourceDic = tempMdel.returnDic;
    _filterAllKeys = [[filterDataSourceDic allKeys] mutableCopy];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    //重新排序
    _filterAllKeys = [[_filterAllKeys sortedArrayUsingComparator:sort]mutableCopy];
    
    //缓存选中的历史目的地
    NSMutableArray *historyDestination = [[CachedataPreferences sharedInstance] getHistoryDestination];
    if (historyDestination.count>0) {
        //添加历史
        [_filterAllKeys insertObject:@"历史" atIndex:0];
        //读取历史数据到字典
        [filterDataSourceDic setObject:historyDestination forKey:@"历史"];
    }
}



#pragma mark -- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _defaultName = nil;
    NSArray *collectionViewDataSource;
    //数据源
    if ([collectionView isEqual:_historyCollectionView])
    {
        collectionViewDataSource = [filterDataSourceDic objectForKey:@"历史"];
    }
    else
    {
        collectionViewDataSource = self.array;
    }
    
    //start place
    if (self.pageId == 0) {
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cityname" object:[NSNumber numberWithInt:self.pageId] userInfo:@{@"name":collectionViewDataSource[indexPath.row][@"name"],@"adcodeId":collectionViewDataSource[indexPath.row][@"adCode"]}];
    }
    
    //end place
    if (self.pageId == 1) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cityname" object:[NSNumber numberWithInt:self.pageId] userInfo:@{@"name":collectionViewDataSource[indexPath.row][@"name"],@"pathId":collectionViewDataSource[indexPath.row][@"id"],@"adCode":collectionViewDataSource[indexPath.row][@"adCode"]}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if ([collectionView isEqual:_historyCollectionView]) {
        NSMutableArray *cellArray = [filterDataSourceDic objectForKey:@"历史"];
        return cellArray.count;
    }
    
    return [self.array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CityNameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"citynamecell" forIndexPath:indexPath];
    NSArray *collectionViewDataSource;
    //数据源
    if ([collectionView isEqual:_historyCollectionView])
    {
        collectionViewDataSource = [filterDataSourceDic objectForKey:@"历史"];
    }
    else
    {
        collectionViewDataSource = self.array;
    }
    
    [cell.cityNameLabel setText:collectionViewDataSource[indexPath.row][@"name"]];
    [cell.cityNameLabel.layer setMasksToBounds:YES];
    [cell.cityNameLabel.layer setCornerRadius:5.0];
    [cell.cityNameLabel.layer setBorderWidth:0.6];
    [cell.cityNameLabel setBackgroundColor:[UIColor whiteColor]];
    [cell.cityNameLabel setTextColor:CellColorNormal];

//    [cell.cityNameLabel.layer setBorderColor:CellColorNormal.CGColor];
    [cell.cityNameLabel.layer setBorderColor:[UIColor colorWithWhite:.7 alpha:1].CGColor];

    if (_defaultName && [_defaultName isEqualToString:collectionViewDataSource[indexPath.row][@"name"]]) {
        [cell.cityNameLabel setTextColor:CellColor];
        [cell.cityNameLabel.layer setBorderColor:CellColor.CGColor];
    }
    return cell;
}

#pragma mark -- UICollectionViewFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

-(CGFloat )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //历史地址
    if ([collectionView isEqual:_historyCollectionView]) {
        return CGSizeMake(collectionView.frame.size.width/3.F - 5, 40);
    }
    
    return CGSizeMake(self.view.frame.size.width/3.F - 5, 50);
}

#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *sectionArray = (NSMutableArray*)[filterDataSourceDic objectForKey:_filterAllKeys[section]];
    //历史只用一行
    if([_filterAllKeys[section] isEqualToString:@"历史"])
    {
        return 1;
    }
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;
    //如果是历史选择的地址
    if([_filterAllKeys[indexPath.section] isEqualToString:@"历史"])
    {
        tempCell = [tableView dequeueReusableCellWithIdentifier:@"historyCellIdent" forIndexPath:indexPath];
        _historyCollectionView = [tempCell viewWithTag:1001];
        _historyCollectionView.delegate = self;
        _historyCollectionView.dataSource = self;
    }
    else
    {
        tempCell = [tableView dequeueReusableCellWithIdentifier:@"selectCellIdent" forIndexPath:indexPath];
        NSMutableArray *cellArray = [filterDataSourceDic objectForKey:_filterAllKeys[indexPath.section]];
        
        UILabel *thisText = [tempCell viewWithTag:1001];
        
        NSDictionary *cellDic = (NSDictionary*)cellArray[indexPath.row];
        
        if ([cellDic objectForKey:@"name"]) {
            thisText.text = [cellDic objectForKey:@"name"];
        }
        [thisText setTextColor:CellColorNormal];
        //设置选中的地区
        //选择的字典
        NSMutableArray *sectionArray = [filterDataSourceDic objectForKey:_filterAllKeys[indexPath.section]];
        NSDictionary *selectObjet = sectionArray[indexPath.row];
        if (_defaultName && [_defaultName isEqualToString:selectObjet[@"name"]]) {
            [thisText setTextColor:CellColor];
        }
    }
    return tempCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _filterAllKeys.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _filterAllKeys[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    tableView.sectionIndexColor = UIColorFromRGB(0xFF5A37);
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    return _filterAllKeys;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_filterAllKeys[indexPath.section] isEqualToString:@"历史"])
    {
        return 80;
    }
    else
    {
        return 45;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果是历史地点，不返回点击
    if([_filterAllKeys[indexPath.section] isEqualToString:@"历史"])
    {
        return;
    }
    _defaultName = nil;
    //选择的字典
    NSMutableArray *sectionArray = [filterDataSourceDic objectForKey:_filterAllKeys[indexPath.section]];
    NSDictionary *selectObjet = sectionArray[indexPath.row];
    //start place
    if (self.pageId == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cityname" object:[NSNumber numberWithInt:self.pageId] userInfo:@{@"name":selectObjet[@"name"],@"adcodeId":selectObjet[@"adCode"]}];
    }
    //end place
    if (self.pageId == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cityname" object:[NSNumber numberWithInt:self.pageId] userInfo:@{@"name":selectObjet[@"name"],@"pathId":selectObjet[@"id"],@"adCode":selectObjet[@"adCode"]}];
    }
    //缓存选中的历史目的地
    NSMutableArray *historyDestination = [[CachedataPreferences sharedInstance] getHistoryDestination];
    //判断是否存储了
    for (NSDictionary *tempDic in historyDestination) {
        //如果换成过就直接退出
        if ([tempDic[@"name"] isEqualToString:selectObjet[@"name"]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    if (!historyDestination) {
        historyDestination = [[NSMutableArray alloc] init];
    }
    //没有相同的则缓存数据，只保留6个数组多余的删除
    [historyDestination insertObject:selectObjet atIndex:0];
    if (historyDestination.count > 6) {
        [historyDestination removeLastObject];
    }
    //进行保存
    [[CachedataPreferences sharedInstance] setHistoryDestination:historyDestination];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@",searchText];
        filterDataSourceArray = (NSMutableArray*)[self.array filteredArrayUsingPredicate:predicate];
    }
    else
    {
        filterDataSourceArray = (NSMutableArray*)self.array;
    }
    //对数据进行处理
    [self processDataSource];
    [_selectTableView reloadData];
}

@end
