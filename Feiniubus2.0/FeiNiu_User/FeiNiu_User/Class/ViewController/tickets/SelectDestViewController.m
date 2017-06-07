//
//  SelectDestViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "SelectDestViewController.h"
#import <FNUIView/NumberView.h>
#import <FNCommon/JsonUtils.h>
#import <FNUIView/MBProgressHUD.h>
#import "SelectDestModel.h"
#import "CachedataPreferences.h"
#import "WebContentViewController.h"
#import "MapViewManager.h"
#import "UINavigationView.h"
#import "CachedataPreferences.h"

#define StartPageID 0
#define EndPageID 1

#define CellColor [UIColor colorWithRed:254/255.0 green:113/255.0 blue:75/255.0 alpha:1]
#define CellColorNormal [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

#define positionHead @"当前城市"
#define positionName @"定位中"

@interface SelectDestViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MAMapViewDelegate,AMapSearchDelegate>
{
    //seacher最初数据源数组
    NSMutableArray *filterDataSourceArray;
    //筛选出来的数据源
    NSMutableDictionary *filterDataSourceDic;
    //定位的对象 由于缓存判断是否定位过不用此对象
    NSMutableDictionary *positionDic;
    //只定位一次
    BOOL isLocation;
}

@property (weak, nonatomic) IBOutlet UINavigationView *navigationView;

@property (weak, nonatomic) IBOutlet UITableView *selectTableView;   //修改为分组列表显示lbj添加功能代码，下面对应数据源协议也是 2015年12月09日15:53:34
//搜索输入框
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//筛选出来的Keys值数据
@property (nonatomic,copy) NSMutableArray *filterAllKeys;
//服务端返回的数据源
@property(nonatomic, strong) NSArray *array;

//地图
@property(nonatomic,strong) MAMapView *mapView;
@property(nonatomic,strong) AMapSearchAPI *searchAPI;

- (void)initUserInterfaceData;

@end

@implementation SelectDestViewController
@dynamic delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUserInterfaceData];
}

-(void)dealloc
{
    [[MapViewManager sharedInstance] clearMapView];
    [[MapViewManager sharedInstance] clearSearch];
}

#pragma mark ------

- (void)initUserInterfaceData{
    //设置委托 //修改为分组列表显示lbj添加功能代码，下面对应数据源协议也是 2015年12月09日15:53:34
    _selectTableView.delegate = self;
    _selectTableView.dataSource = self;
    _searchBar.delegate = self;
    _mapView = [[MapViewManager sharedInstance] getMapView];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    _searchAPI = [[MapViewManager sharedInstance] getSearch];
    _searchAPI.delegate = self;
    
    //初始化定位需要的数据
    positionDic = [[[CachedataPreferences sharedInstance] getLocationData] mutableCopy];
    if (!positionDic) {
        positionDic =[[NSMutableDictionary alloc] initWithDictionary: @{@"name":positionName,@"adcode":@"10000"}];
    }
    
    
    [self startWait];
    [self loadingCityName:self.pageId];
    
}


//loading city data
- (void)loadingCityName:(int)pageId{
    switch (pageId) {
        case 0:
        {
            self.navigationView.title = @"选择出发地";
            [NetManagerInstance sendRequstWithType:EmRequestType_StartCity params:^(NetParams *params) {
                params.method = EMRequstMethod_GET;
                params.data = nil;
            }];
        }
            break;
        case 1:
        {
            self.navigationView.title = @"选择目的地";
            [NetManagerInstance sendRequstWithType:EmRequestType_DestinationCity params:^(NetParams *params) {
                params.method = EMRequstMethod_GET;
                if (_adCodeId) {
                    params.data = @{@"startAdcode":_adCodeId};
                }
//                else{
//                    params.data = @{@"startAdcode":@"10000"};
//                }
                
            }];
        }
            break;
        default:
            break;
    }

}

//点击了申请开通路线
-(void)applyCourseClick
{
    //使用webView查看
//    WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
//    webViewController.vcTitle = @"申请开通路线";
//    webViewController.urlString = [[NSString alloc] initWithFormat:@"%@%@",KTopLevelDomainAddr,@"openingLine"];
//    [self.navigationController pushViewController:webViewController animated:YES];
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
    
    [_filterAllKeys insertObject:positionHead atIndex:0];
    //读取历史数据到字典
    [filterDataSourceDic setObject:@[positionDic] forKey:positionHead];
}


#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *sectionArray = (NSMutableArray*)[filterDataSourceDic objectForKey:_filterAllKeys[section]];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;

    tempCell = [tableView dequeueReusableCellWithIdentifier:@"selectCellIdent" forIndexPath:indexPath];
    NSMutableArray *cellArray = [filterDataSourceDic objectForKey:_filterAllKeys[indexPath.section]];

    UILabel *thisText = [tempCell viewWithTag:1001];
    thisText.font = [UIFont systemFontOfSize:14];
    NSDictionary *cellDic = (NSDictionary*)cellArray[indexPath.row];

    if ([cellDic objectForKey:@"name"]) {
        thisText.text = [cellDic objectForKey:@"name"];
    }
    [thisText setTextColor:UITextColor_Black];
    //设置选中的地区
    //选择的字典
    NSMutableArray *sectionArray = [filterDataSourceDic objectForKey:_filterAllKeys[indexPath.section]];
    NSDictionary *selectObjet = sectionArray[indexPath.row];
    if (_defaultName && [_defaultName isEqualToString:selectObjet[@"name"]]) {
        [thisText setTextColor:CellColor];
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc]init];
    myView.backgroundColor = UIColorFromRGB(0xe9e9e9);
    UILabel *titleLabel = [[UILabel alloc]init];
    [myView addSubview:titleLabel];
    titleLabel.textColor=UITextColor_DarkGray;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=_filterAllKeys[section];
    titleLabel.font = [UIFont systemFontOfSize:14];
    
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(myView).offset(13);
        make.top.equalTo(myView);
        make.bottom.equalTo(myView);
        make.right.equalTo(myView);
    }];
    
    return myView;
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
//继承scrollView 协议
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _defaultName = nil;
    //选择的字典
    NSMutableArray *sectionArray = [filterDataSourceDic objectForKey:_filterAllKeys[indexPath.section]];
    NSDictionary *selectObjet = sectionArray[indexPath.row];
    
    //如果点击的正在定位则不返回
    if ([[selectObjet objectForKey:@"name"] isEqualToString:positionName]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(chooseAddressClick:selectInfor:)]) {
        [self.delegate chooseAddressClick:self.pageId  selectInfor:selectObjet];
    }
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or searchName contains[cd] %@ or searchSimpleName contains[cd] %@",searchText,searchText,searchText];
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

#pragma mark --- MAMapViewDelegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation && !isLocation)
    {
        //取出当前位置的坐标
//        DBG_MSG(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        AMapReGeocodeSearchRequest *_regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];;
        _regeoRequest.location = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        _regeoRequest.requireExtension = YES;
        isLocation = YES;
        _searchAPI.delegate = self;
        [_searchAPI AMapReGoecodeSearch:_regeoRequest];
    }
}

#pragma mark --- AMapSearchDelegate
/**
 *  搜索错误回调
 *
 *  @param request
 *  @param error
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    DBG_MSG(@"AMapSearchRequest:error-->:%@",error);
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{

    if (positionDic) {
        DBG_MSG(@"_city==%@,_adcode=%@",response.regeocode.addressComponent.city,response.regeocode.addressComponent.adcode);
        //如果处于定位中则，获取后更换定位
        [positionDic setObject:response.regeocode.addressComponent.city forKey:@"name"];
        NSString *tempAdcode = response.regeocode.addressComponent.adcode;
        [positionDic setObject:[tempAdcode stringByReplacingCharactersInRange:NSMakeRange(tempAdcode.length-2,2) withString:@"00"] forKey:@"adcode"]; //根据高德地图转换为市的adCode
        //缓存定位数据
        [[CachedataPreferences sharedInstance] setLocationData:positionDic];
        [_selectTableView reloadData];
    }
}

#pragma mark ----
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    switch (resultData.type) {
        case EmRequestType_StartCity:
        {
            self.array = resultData.data;
            //修改为列表对数据进行分词 2015年12月09日15:53:29
            filterDataSourceArray = (NSMutableArray*)self.array;
            [self processDataSource];
            [_selectTableView reloadData];
        }
            break;
        case EmRequestType_DestinationCity:
        {
            self.array = resultData.data;
            //修改为列表对数据进行分词 2015年12月09日15:53:29
            filterDataSourceArray = (NSMutableArray*)self.array;
            [self processDataSource];
            [_selectTableView reloadData];
        }
            break;
        default:
            break;
    }
    
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
}

@end
