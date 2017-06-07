//
//  FNInputLocationViewController.m
//  FNMap
//
//  Created by 易达飞牛 on 15/8/6.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "FNSearchViewController.h"
#import "MapViewManager.h"
#import "FNLocation.h"
#import "CustomSearchDisplayController.h"
#import <MAMapKit/MAMapKit.h>

#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"

@interface FNSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, AMapSearchDelegate, UISearchBarDelegate,MAMapViewDelegate>
{
    AMapSearchAPI *_search;
    FNLocation  *_userLocation;
}
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) CustomSearchDisplayController *displayController;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *topTableView;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *placeSearch;

@end

@implementation FNSearchViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _text = @"";
        _city = @"028";
        _locations = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initUI];
}

-(void)dealloc
{
    [[MapViewManager sharedInstance] clearSearch];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isShowTopTableView == YES) {
       
//        [self initTopTableView];
        [self initMapView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_searchBar becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark -- init user interface

- (void)initMapView{
    
    _mapView = [[MAMapView alloc] init];
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setUserTrackingMode:1];
    [_mapView setDelegate:self];
    [self.view addSubview:_mapView];
    
    _placeSearch = [[AMapPOIKeywordsSearchRequest alloc] init];
    _placeSearch.requireExtension = YES;
//    _placeSearch.searchType = AMapSearchType_PlaceAround;
//    _placeSearch.city = @[@"0816"];
//    _placeSearch.radius = 1000;
    
//    _search = [[AMapSearchAPI alloc] initWithSearchKey:KMapAppKey Delegate:self];
}

- (void)initTopTableView{
    
    _topTableView = [[UITableView alloc]init];
    [_topTableView setTag:101];
    [_topTableView setDelegate:self];
    [_topTableView setDataSource:self];
    [_topTableView setTableFooterView:[[UIView alloc] init]];
//    [self.view addSubview:_topTableView];
    
    [_topTableView makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.top).offset(50);
        make.width.equalTo(self.view.width);
        make.height.equalTo(self.view.height);
        
    }];  
}

-(void)initUI
{
    self.title = @"地址信息";
//    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
//    self.searchBar.barStyle     = UIBarStyleBlack;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder = @"请输入地点,如成都天府广场";
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundImage = [UIImage new];
    
    UIView *view = [[[self.searchBar.subviews firstObject] subviews] lastObject];
    view.backgroundColor = UIColorFromRGB(0xF6F6F6);
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0,CGRectGetHeight(self.searchBar.frame)-0.5, CGRectGetWidth(self.searchBar.frame), 0.5)];
    imageview.backgroundColor = self.tableView.separatorColor;
    [self.searchBar addSubview:imageview];
    
    
    //self.searchBar.text = self.text;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.displayController = [[CustomSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [self.displayController setActive:NO animated:NO];
    self.displayController.delegate                = self;
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchResultsDelegate   = self;
//    self.displayController.displaysSearchBarInNavigationBar = YES;

}

#pragma mark- function
-(void)searchTipsWithKey:(NSString*)key
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.requireExtension = YES;
//    request.searchType = AMapSearchType_PlaceKeyword;
    request.keywords = key;
    
    if (self.city.length > 0)
    {
//        request.city = @[self.city];
        request.city = self.city;
    }
    
    [[MapViewManager sharedInstance] getSearch].delegate = self;
    [[[MapViewManager sharedInstance] getSearch] AMapPOIKeywordsSearch: request];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.text = searchBar.text;
//    [self searchTipsWithKey:self.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{

    _isShowTopTableView = NO;
    return YES;
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.text = searchString;
    [self searchTipsWithKey:self.text];
    
    return YES;
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (request == _placeSearch && self.locations.count > 0) {
        return;
    }
    [self stopWait];
    
    [self.locations removeAllObjects];
    self.locations = [NSMutableArray array];
    
    AMapPOISearchResponse *aResponse = (AMapPOISearchResponse *)response;
    [aResponse.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop){
        FNLocation *location = [[FNLocation alloc] init];
        location.name = obj.name;
        location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        location.address = obj.address;
        location.cityCode = obj.citycode;
        location.adCode = obj.adcode;
        [self.locations addObject:location];
    }];
    
    FNLocation *firstLocatin = [self.locations firstObject];
    if (request == _placeSearch && firstLocatin) {
        [self.tableView reloadData];
    }else{
        [self.displayController.searchResultsTableView reloadData];
    }
}

//- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
//{
//    if (request == _placeSearch && self.locations.count > 0) {
//        return;
//    }
//    [self stopWait];
//    
//    [self.locations removeAllObjects];
//    self.locations = [NSMutableArray array];
//    
//    AMapPlaceSearchResponse *aResponse = (AMapPlaceSearchResponse *)response;
//    [aResponse.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop){
//        FNLocation *location = [[FNLocation alloc] init];
//        location.name = obj.name;
//        location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
//        location.address = obj.address;
//        location.cityCode = obj.citycode;
//        location.adCode = obj.adcode;
//        [self.locations addObject:location];
//    }];
//    
//    FNLocation *firstLocatin = [self.locations firstObject];
//    if (request == _placeSearch && firstLocatin) {
//        [self.tableView reloadData];
//    }else{
//        [self.displayController.searchResultsTableView reloadData];
//    }
//
//    if (_isShowTopTableView == YES) {
//        
//        [self.locations removeAllObjects];
//        self.locations = [NSMutableArray array];
//        
//        AMapPlaceSearchResponse *aResponse = (AMapPlaceSearchResponse *)response;
//        [aResponse.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop){
//            FNLocation *location = [[FNLocation alloc] init];
//            location.name = obj.name;
//            location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
//            location.address = obj.address;
//            location.cityCode = obj.citycode;
//            location.adCode = obj.adcode;
//            [self.locations addObject:location];
//        }];
//        
//        [_topTableView reloadData];
//        
////        [_mapView setShowsUserLocation:NO];
//        
//        return;
//    }
//    
//    [self stopWait];
//    
//    [self.locations removeAllObjects];
//    
//    AMapPlaceSearchResponse *aResponse = (AMapPlaceSearchResponse *)response;
//    [aResponse.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop)
//     {
//         FNLocation *location = [[FNLocation alloc] init];
//         location.name = obj.name;
//         location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
//         location.address = obj.address;
//         location.cityCode = obj.citycode;
//         location.adCode = obj.adcode;
//         [self.locations addObject:location];
//     }];
//    
//    [self.displayController.searchResultsTableView reloadData];
//}

#pragma mark -- mapView delegate

//- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
//    
//    [self searchPlaceWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
//
//}

//- (void)searchPlaceWithLatitude:(CGFloat)_latitude longitude:(CGFloat)_longitude{
//    
//    NSLog(@"_latitude=%f _longitude=%f",_latitude,_longitude);
//    
//    _placeSearch.location = [AMapGeoPoint locationWithLatitude:_latitude longitude:_longitude];
//    
//    [_search AMapPlaceSearch:_placeSearch];
//}


#pragma mark- uitableviewdelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (tableView.tag == 101) {
//        
//        return 3;
//    }
    
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.locations.count > 1) {
        [_mapView setShowsUserLocation:NO];
    }
    
    if (tableView.tag == 101) {
        
        static NSString *cellIdentifier = @"cellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        if (self.locations.count >= 1) {
            
            FNLocation *location = self.locations[indexPath.row];
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"[当前位置]";
            }else{
                cell.textLabel.text = location.name;
            }
            
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.detailTextLabel.text = location.address;
            cell.detailTextLabel.textColor = UIColorFromRGB(0xb4b4b4);
        }
        
        return cell;
    }
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    FNLocation *location = self.locations[indexPath.row];
    if (tableView == self.tableView && indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"[当前位置]%@", location.name];
    }else{
        cell.textLabel.text = location.name;
    }
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    cell.detailTextLabel.text = location.address;
    cell.detailTextLabel.textColor = UIColorFromRGB(0xb4b4b4);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_searchBar resignFirstResponder];
    FNLocation *location = self.locations[indexPath.row];
    if (_fnSearchDelegate && [_fnSearchDelegate respondsToSelector:@selector(searchViewController:didSelectLocation:)])
    {
        [_fnSearchDelegate searchViewController:self didSelectLocation:location];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
