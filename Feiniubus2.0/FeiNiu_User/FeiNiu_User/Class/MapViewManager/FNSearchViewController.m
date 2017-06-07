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
#import <MAMapKit/MAMapKit.h>
#import "CachedataPreferences.h"
#import "FNSearchMapViewController.h"
#import "CityInfoCache.h"
#import "FeiNiu_User-Swift.h"

#define KMapAppKey    @"865e5c2f1b534c9673eeaab91144185b"

@interface FNSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, AMapSearchDelegate,MAMapViewDelegate>
{
    AMapSearchAPI *_search;
    FNLocation  *_userLocation;
    
    __weak IBOutlet UIButton *cityButton;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UILabel *navTitleLab;
    
    __weak IBOutlet NSLayoutConstraint *tableViewBtmCons;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) MAMapView *mapView;
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
    
    self.view.backgroundColor  = UIColor_Background;
    navTitleLab.text = _navTitle;
    [searchTextField becomeFirstResponder];
    
    
    [searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.tableView.tableFooterView = [UIView new];
    //刷新
    [self refreshUI];
    //判断缓存
    [self initMapView];
    
    [self loadHirstoryPlaceInfo];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citySelectedChange:) name:KChangeCityNotification object:nil];
    
    //键盘调起通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)btnBack:(id)sender {
    [self popViewController];
}

//选择城市
- (IBAction)clickSeletedCItyAction:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShuttleBus" bundle:nil];
    ShuttleBusSelectCityViewController *selectCityViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShuttleBusSelectCityViewController"];
    selectCityViewController.isShuttleBus = self.isShuttleBus;
    [self.navigationController pushViewController:selectCityViewController animated:YES];
}

-(void)dealloc
{
    [[MapViewManager sharedInstance] clearSearch];
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KChangeCityNotification object:nil];
}


-(void)KeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //获取高度
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    DBG_MSG(@"键盘高度：%f", keyboardSize.height);
    
    tableViewBtmCons.constant = keyboardSize.height;
}

#pragma mark -- init user interface

-(void)refreshUI{
    NSString *cityName;
    if (_isShuttleBus) {
        cityName = [CityInfoCache sharedInstance].shuttleCurCity.city_name;
    }
    else {
        cityName = [CityInfoCache sharedInstance].commuteCurCity.city_name;
    }
    [cityButton setTitle:cityName forState:UIControlStateNormal];
}

- (void)initMapView{
    
    _mapView = [[MAMapView alloc] init];
    [_mapView setShowsUserLocation:YES];
    [_mapView setUserTrackingMode:1];
    [_mapView setDelegate:self];
    [self.view addSubview:_mapView];
}

#pragma mark- function
-(void)searchTipsWithKey:(NSString*)key
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.requireExtension = YES;
    if (_isShuttleBus) {
        request.city = [CityInfoCache sharedInstance].shuttleCurCity.adcode;
    }
    else {
        request.city = [CityInfoCache sharedInstance].commuteCurCity.adcode;
    }
    
    request.cityLimit = YES;
    
    //    request.searchType = AMapSearchType_PlaceKeyword;
    request.keywords = key;
    
    if (self.city.length > 0)
    {
        //        requesdt.city = @[self.city];
        request.city = self.city;
    }
    
    [[MapViewManager sharedInstance] getSearch].delegate = self;
    [[[MapViewManager sharedInstance] getSearch] AMapPOIKeywordsSearch:request];
}

#pragma mark- Notification

-(void)citySelectedChange:(NSNotification* )sender{
    [self refreshUI];
}

#pragma mark - UITextFieldChange
- (void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"%@",textField.text);
    if (textField.text && textField.text.length > 0) {
        [self searchTipsWithKey:textField.text];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadHirstoryPlaceInfo];
        });
    }
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
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
        location.latitude = obj.location.latitude;
        location.longitude = obj.location.longitude;
        [self.locations addObject:location];
    }];
    
    [self.tableView reloadData];
}

#pragma mark- uitableviewdelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.locations.count > 1) {
        [_mapView setShowsUserLocation:NO];
    }
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    UILabel *titleLabel = [cell viewWithTag:101];
    UILabel *detailLabel = [cell viewWithTag:102];
    
//    cell.backgroundColor = UIColor_Background;
    FNLocation *location = self.locations[indexPath.row];
    
    titleLabel.text = location.name;
    detailLabel.text = location.address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FNLocation *location = self.locations[indexPath.row];
    [self saveHistoryPlaceWith:location];
    
    //如果从地图页进来
    if (_searchMapViewDelegate) {
        
        NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isMemberOfClass:[FNSearchMapViewController class]]) {
                [controllers removeObject:controller];
            }
        }
        self.navigationController.viewControllers = controllers;
        
        if (_searchMapViewDelegate && [_searchMapViewDelegate respondsToSelector:@selector(searchMapViewController:didSelectLocation:)])
        {
            [_searchMapViewDelegate searchMapViewController:nil didSelectLocation:location];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        if (_fnSearchDelegate && [_fnSearchDelegate respondsToSelector:@selector(searchViewController:didSelectLocation:)])
        {
            [_fnSearchDelegate searchViewController:self didSelectLocation:location];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark help

- (void)saveHistoryPlaceWith:(FNLocation *)location
{
    NSMutableArray *historyArr = [self getHirstoryPlace];
    if (location) {
        
        //相同的先删除
        [historyArr enumerateObjectsUsingBlock:^(FNLocation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.name isEqualToString:location.name]) {
                [historyArr removeObject:obj];
            }
        }];
        
        if (historyArr.count < 10) {
            [historyArr insertObject:location atIndex:0];
        }else{
            [historyArr replaceObjectAtIndex:0 withObject:location];
        }
        [[CachedataPreferences sharedInstance] setHirstoryPlaceInfor:historyArr];
    }
}

- (NSMutableArray *)getHirstoryPlace
{
    return [NSMutableArray arrayWithArray:[[CachedataPreferences sharedInstance] getHirstoryPlaceInfor]];
}


//加载历史
- (void)loadHirstoryPlaceInfo
{
    NSMutableArray *datas = [self getHirstoryPlace];
    if (datas && datas.count > 0) {
        self.locations = datas;
        [self.tableView reloadData];
    }
}

@end
