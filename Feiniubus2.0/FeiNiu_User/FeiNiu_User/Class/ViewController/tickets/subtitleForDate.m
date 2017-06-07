//
//  TicketsMainViewController.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/10.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "TicketsMainViewController.h"
#import "CachedataPreferences.h"
#import "SelectDestViewController.h"
#import "QueryResultsViewController.h"
#import "WebContentViewController.h"
#import "MapViewManager.h"
#import <FNUIView/BannerView.h>

#define Origin          @"Origin"
#define Destination     @"Destination"

@interface TicketsMainViewController ()<BannerViewDelegate,SelectDestViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,MAMapViewDelegate,AMapSearchDelegate>
{
    int pageType;
    //出发地的数据
    NSDictionary *originData;
    //目的地的数据
    NSDictionary *destinationData;
    //出发时间
    NSDate *setOutDate;
    //缓存的目的地出发地
    NSMutableArray *cacheOriginDestination;
    
    
    //临时使用superView;
    UIView *superView;
    //FSCalender开始时间和结束时间
    NSDate *calenderStartData;
    NSDate *calenderEndDate;
    
    //是否需要定位数据
    BOOL isNeedPositionData;
}

//banner
@property (weak, nonatomic) IBOutlet BannerView *banner;
//最近搜索的tableView
@property (weak, nonatomic) IBOutlet UITableView *seachTableView;
//出发地
@property (weak, nonatomic) IBOutlet UIView *originView;
@property (weak, nonatomic) IBOutlet UILabel *originLabel;

@property (weak, nonatomic) IBOutlet UIImageView *exchangImageView;
@property (weak, nonatomic) IBOutlet UIButton *exchangButton;

//目的地
@property (weak, nonatomic) IBOutlet UIView *destinationView;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;

//时间选择
@property (weak, nonatomic) IBOutlet UIView *timeSelectView;
@property (weak, nonatomic) IBOutlet UILabel *timeSelectLabel;

//banner数据
@property (strong,nonatomic) NSMutableArray *bannerInfor;

//地图
@property(nonatomic,strong) MAMapView *mapView;
@property(nonatomic,strong) AMapSearchAPI *searchAPI;
@end

@implementation TicketsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //绘制界面
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //日历控件初始化
    [self initFSCalendar];
    //最近搜索
    [_seachTableView reloadData];
    [self.banner startTimer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.banner stopTimer];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *destinationViewController = segue.destinationViewController;
    //班次列表
    if ([destinationViewController isKindOfClass:[QueryResultsViewController class]]) {
        QueryResultsViewController *viewController = (QueryResultsViewController*)destinationViewController;
        viewController.originData = originData;
        viewController.destinationData = destinationData;
        viewController.setOutDate = setOutDate;
        viewController.calenderStartData = [calenderStartData dateByAddingTimeInterval:3600*24];
        viewController.calenderEndDate = [calenderEndDate dateByAddingTimeInterval:-100];
    }
}


#pragma mark ---
/**
 *  初始化界面控件
 */
-(void) initUI
{
    //开始设置需要定位数据
    isNeedPositionData = YES;
//----- 设置banner ------
    self.banner.autoTurning = YES;
    self.banner.placeholderImage = @"banner";
    self.banner.delegate = self;
    _bannerInfor = [[CachedataPreferences sharedInstance] getBannerInfor];
    //获取图片地址
    NSMutableArray *imageInfor = [[NSMutableArray alloc] init];
    for (NSDictionary *tempDic in _bannerInfor) {
        if ([tempDic objectForKey:@"image"]) {
            [imageInfor addObject:[tempDic objectForKey:@"image"]];
        }
    }
    //有缓存数据读取缓存
    if (imageInfor.count > 0) {
        [self.banner loadImagesUrl:imageInfor];
        [self.banner addTimer];
    }
    else
    {
        //没有缓存数据读取默认默认一个
        [self.banner loadImagesUrl:@[@""]];
        [self.banner addTimer];
    }
    [_exchangButton setImage:[UIImage imageNamed:@"addressExchange"] forState:UIControlStateNormal];
    [_exchangButton setImage:[UIImage imageNamed:@"addressExchangeH"] forState:UIControlStateHighlighted];
//----- 设置seachTableView ------
    self.seachTableView.delegate = self;
    self.seachTableView.dataSource = self;
//----- 设置 设置出发地 目的地点击交互 ------
    UITapGestureRecognizer *originViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressSelectClick:)];
    [self.originView addGestureRecognizer:originViewTap];
    self.originView.userInteractionEnabled = YES;
    self.originView.tag = 1001;
    UITapGestureRecognizer *destinationViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressSelectClick:)];
    [self.destinationView addGestureRecognizer:destinationViewTap];
    self.destinationView.userInteractionEnabled = YES;
    self.destinationView.tag = 1002;
    UITapGestureRecognizer *exchangeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressSelectClick:)];
    [self.exchangImageView addGestureRecognizer:exchangeTap];
    self.exchangImageView.userInteractionEnabled = YES;
    self.exchangImageView.tag = 1003;
    
//----- 设置 时间选择 ------
    UITapGestureRecognizer *timeSelectViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelectClick:)];
    [self.timeSelectView addGestureRecognizer:timeSelectViewTap];
    self.timeSelectView.userInteractionEnabled = YES;
//    setOutDate = [[NSDate new] dateByAddingTimeInterval:60*60*24*1];
    setOutDate = [NSDate new];
    _timeSelectLabel.text = [[NSString alloc] initWithFormat:@"%@，%@",[DateUtils formatDate:setOutDate format:@"yyyy-MM-dd"],[DateUtils weekFromDate:setOutDate]] ;
    //读取出发地目的地缓存数据
    cacheOriginDestination = [[CachedataPreferences sharedInstance] getOriginDestination];
    if (cacheOriginDestination.count > 0) {
        originData = [cacheOriginDestination[0] objectForKey:Origin];
        destinationData = [cacheOriginDestination[0] objectForKey:Destination];
        //重置显示
        [self resetOriginDestination];
    }
    
    
    //请求服务器banner
    [NetManagerInstance sendRequstWithType:EmRequestType_CarouselIndex params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
    
    //地图数据
    _mapView = [[MapViewManager sharedInstance] getMapView];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    _searchAPI = [[MapViewManager sharedInstance] getSearch];
    _searchAPI.delegate = self;
}
/**
 *  初始化日历
 */
-(void)initFSCalendar
{
    _mainCalendar = [[FSCalendar alloc] init];
//    [_mainCalendar setUserInteractionEnabled:YES];
    [_mainCalendar setBackgroundColor:[UIColor whiteColor]];
    _mainCalendar.delegate = self;
    _mainCalendar.dataSource = self;
    [_mainCalendar setToday:[NSDate new]];
    
    _mainCalendar.scrollDirection = FSCalendarScrollDirectionVertical;
    _mainCalendar.headerHeight = 44.f;
    _mainCalendar.weekdayHeight = 20.f;
    
    _mainCalendar.appearance.headerTitleColor = UIColorFromRGB(0xFF7043);
    _mainCalendar.appearance.headerDateFormat = @"yyyy年M月";
    
    _mainCalendar.appearance.weekdayTextColor = UIColorFromRGB(0x333333);
    _mainCalendar.appearance.selectionColor = UIColorFromRGB(0xFF7043);
    
    //获取订票时间范围
    [NetManagerInstance sendRequstWithType:EmRequestType_DateRange params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
    
   
}

/**
 *  显示日历
 */
-(void)displayFSCalendar:(UIView*)parentView
{
    superView = parentView;
    UIView *coverView = [[UIView alloc] init];
    [coverView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    coverView.tag = 10001;
    if ([parentView viewWithTag:10001]) {
        return;
    }
    
    [parentView addSubview:coverView];
    [coverView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    [parentView layoutIfNeeded];
    [coverView addSubview:_mainCalendar];
    
    [_mainCalendar makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(coverView);
        make.width.equalTo(coverView);
        make.bottom.equalTo(250);
        make.height.equalTo(250);
    }];
    [_mainCalendar layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        
        [_mainCalendar remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(coverView);
            make.width.equalTo(coverView);
            make.bottom.equalTo(coverView);
            make.height.equalTo(250);
        }];
        
        [_mainCalendar layoutIfNeeded];
    }];
    
    //处理bug 增加手势视图，增加消失功能
    UITapGestureRecognizer *deDisplay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deDisplayFSCalendar)];
    UIView  *gestureView = [[UIView alloc] init];
    [coverView addSubview:gestureView];
    [gestureView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(coverView);
        make.right.equalTo(coverView);
        make.top.equalTo(coverView);
        make.bottom.equalTo(_mainCalendar.top);
    }];
    [gestureView layoutIfNeeded];
    [gestureView setUserInteractionEnabled:YES];
    [gestureView addGestureRecognizer:deDisplay];
}
/**
 *  隐藏日历
 */
-(void)deDisplayFSCalendar
{
    if (!superView) {
        return;
    }
    
    if (![superView viewWithTag:10001]) {
        return;
    }
    
    UIView *coverView = [superView viewWithTag:10001];
    [UIView animateWithDuration:0.4 animations:^{
        [_mainCalendar remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(coverView);
            make.width.equalTo(coverView);
            make.bottom.equalTo(250);
            make.height.equalTo(250);
        }];
        [_mainCalendar layoutIfNeeded];
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
        superView = nil;
    }];
}

/**
 *  根据数据重置显示的出发地和目的地
 */
-(void)resetOriginDestination
{
    //出发地
    if (originData && [originData objectForKey:@"name"]) {
        _originLabel.text = [originData objectForKey:@"name"];
        //有缓存数据不需要定位数据
        isNeedPositionData = NO;
    }
    else{
        _originLabel.text = @"请选择";
    }
    //目的地
    if (destinationData && [destinationData objectForKey:@"name"]) {
        _destinationLabel.text = [destinationData objectForKey:@"name"];
    }
    else{
        _destinationLabel.text = @"请选择";
    }
}
/**
 *  点击交换出发地目的地
 *
 *  @param sender
 */
- (IBAction)exchangAddress:(id)sender {
    NSDictionary *tempData = originData;
    originData = destinationData;
    destinationData = tempData;
    //刷新一次出发地和目的地
    [self resetOriginDestination];
}

/**
 *  地址选择点击事件
 *
 *  @param recognizer recognizer description
 */
-(void)addressSelectClick:(UITapGestureRecognizer *)recognizer
{
    DBG_MSG(@"你点击了view的tag是%ld",recognizer.view.tag);
    //推送到地理位置选择器
    UIStoryboard* ticketsStoryboard = [UIStoryboard storyboardWithName:@"Tickets" bundle:nil];
    SelectDestViewController *selecAddressController = (SelectDestViewController*)[ticketsStoryboard instantiateViewControllerWithIdentifier:@"selecAddressController"];
    selecAddressController.delegate = self;
    
//    [self performSegueWithIdentifier:@"toSelectDest" sender:recognizer];
    
    switch (recognizer.view.tag) {
        case 1001:
        {
            selecAddressController.pageId = 0;
            selecAddressController.defaultName = _originLabel.text;
            [self.navigationController pushViewController:selecAddressController animated:YES];
        }
            break;
        case 1002:
        {
            selecAddressController.pageId = 1;
            selecAddressController.defaultName = _destinationLabel.text;
            if (originData && [originData objectForKey:@"adcode"]) {
                selecAddressController.adCodeId = [originData objectForKey:@"adcode"];
            }
            
            [self.navigationController pushViewController:selecAddressController animated:YES];
        }
            break;
        case 1003:
        {
            NSDictionary *tempData = originData;
            originData = destinationData;
            destinationData = tempData;
            //刷新一次出发地和目的地
            [self resetOriginDestination];
        }
            break;
        default:
            break;
    }
    
    
}
/**
 *  时间选择点击
 *
 *  @param recongnizer recongnizer description
 */
-(void)timeSelectClick:(UITapGestureRecognizer*)recongnizer
{
    DBG_MSG(@"你点击了重新选择时间");
    [self displayFSCalendar:KWindow];
}

/**
 *  车牌查询点击
 *
 *  @param sender sender description
 */
- (IBAction)seachClick:(id)sender {
    //如果未选择出发地目的地直接返回
    if (!originData || !destinationData || !setOutDate) {
        [self showTipsView:@"请选择出发地、目的地、出发时间"];
        return;
    }
    
    
    //缓存已经选择过出发地目的地
    if (!cacheOriginDestination) {
        cacheOriginDestination = [[NSMutableArray alloc] init];
    }
    //读取出发地目的地缓存数据
    if (cacheOriginDestination.count > 0) {
        NSDictionary *tempOriginData = [cacheOriginDestination[0] objectForKey:Origin];
        NSDictionary *tempDestinationData = [cacheOriginDestination[0] objectForKey:Destination];
        //第一个就是缓存的本次就不需要缓存了
        if ([tempOriginData isEqual:originData] && [tempDestinationData isEqual:destinationData])
        {
            [self performSegueWithIdentifier:@"toQueryResult" sender:nil];
            return;
        }
    }
    NSMutableDictionary *cacheDic = [[NSMutableDictionary alloc] init];
    [cacheDic setObject:originData forKey:Origin];
    [cacheDic setObject:destinationData forKey:Destination];
    [cacheOriginDestination insertObject:cacheDic atIndex:0];
    
    //移除超过三个点缓存
    if (cacheOriginDestination.count>3) {
        for (int i=0 ; i<cacheOriginDestination.count-3 ; i++) {
            [cacheOriginDestination removeLastObject];
        }
    }
    //执行缓存
    [[CachedataPreferences sharedInstance] setOriginDestination:cacheOriginDestination];
    cacheOriginDestination = [[CachedataPreferences sharedInstance] getOriginDestination];//获取缓存方便使用
    
    [self performSegueWithIdentifier:@"toQueryResult" sender:nil];
}

-(void)navigateionViewBack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KShowMenuNotification object:nil];
}

#pragma mark --- MAMapViewDelegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation && isNeedPositionData)
    {
        //取出当前位置的坐标
        //        DBG_MSG(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        AMapReGeocodeSearchRequest *_regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];;
        _regeoRequest.location = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        _regeoRequest.requireExtension = YES;
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
    if (isNeedPositionData) {
        //定位失败
        _originLabel.text = @"请选择";
    }
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    if (isNeedPositionData) {
        DBG_MSG(@"_city==%@,_adcode=%@",response.regeocode.addressComponent.city,response.regeocode.addressComponent.adcode);
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:response.regeocode.addressComponent.city forKey:@"name"];
        NSString *tempAdcode = response.regeocode.addressComponent.adcode;
        [tempDic setObject:[tempAdcode stringByReplacingCharactersInRange:NSMakeRange(tempAdcode.length-2,2) withString:@"00"] forKey:@"adcode"]; //根据高德地图转换为市的adCode
        originData = tempDic;
        //重置显示
        [self resetOriginDestination];
    }
}

#pragma mark --- BannerViewDelegate
/**
 *  点击banner协议回调
 *
 *  @param index index
 */
-(void)bannerViewWithIndex:(int)index
{
    DBG_MSG(@"点击了第%d张图片",index);
    //点击了某一个bannar 跳转网页
    if (_bannerInfor.count > index) {
        //获取字典数据
        NSMutableDictionary *bannerDic = _bannerInfor[index];
        if ([bannerDic objectForKey:@"Url"] && ![[bannerDic objectForKey:@"Url"] isEqualToString:@""]) {
            //使用webView查看
            WebContentViewController *ruleViewController = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"WebContentViewController"];
            ruleViewController.vcTitle = [bannerDic objectForKey:@"Title"] ? [bannerDic objectForKey:@"Title"] :@"";
            ruleViewController.urlString = [bannerDic objectForKey:@"Url"];
            
            [self.navigationController pushViewController:ruleViewController animated:YES];
        }
    }
}

#pragma mark --- SelectDestViewControllerDelegate

- (void)chooseAddressClick:(int)pageId selectInfor:(id)selectInfor
{
    NSDictionary *returnDic = selectInfor;
    switch (pageId) {
        case 0:
        {
            _originLabel.text = [returnDic objectForKey:@"name"];
            originData = selectInfor;
            //选择了出发地就不需要定位的数据
            isNeedPositionData = NO;
        }
            break;
        case 1:
        {
            _destinationLabel.text = [returnDic objectForKey:@"name"];
            destinationData = selectInfor;
        }
            break;
        default:
            break;
    }
}
#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *tempData = [cacheOriginDestination objectAtIndex:indexPath.row];
    if ([tempData objectForKey:Origin]) {
        originData = [tempData objectForKey:Origin];
    }
    if ([tempData objectForKey:Destination]) {
        destinationData = [tempData objectForKey:Destination];
    }
    //重新刷新
    [self resetOriginDestination];
}

#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cacheOriginDestination.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"seachTableViewCellId"];
    UILabel *originLabel = [cell viewWithTag:101];
    UILabel *destinationLabel = [cell viewWithTag:102];
    
    NSDictionary *tempOriginData = [cacheOriginDestination[indexPath.row] objectForKey:Origin];
    NSDictionary *tempDestinationData = [cacheOriginDestination[indexPath.row] objectForKey:Destination];
    
    if ([tempOriginData objectForKey:@"name"]) {
        originLabel.text = [tempOriginData objectForKey:@"name"];
    }
    
    if ([tempDestinationData objectForKey:@"name"]) {
        destinationLabel.text = [tempDestinationData objectForKey:@"name"];
    }
    
    return cell;
}
#pragma mark ---FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    return [DateUtils chineseDayFromDate:date];
}

#pragma mark ---FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    //设置时间
    setOutDate = date;
    _timeSelectLabel.text = [[NSString alloc] initWithFormat:@"%@，%@",[DateUtils formatDate:setOutDate format:@"yyyy-MM-dd"],[DateUtils weekFromDate:setOutDate]];
    //隐藏时间
    [self deDisplayFSCalendar];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date{
    
    if ([[date laterDate:calenderStartData] isEqualToDate:date] && [[date earlierDate:calenderEndDate] isEqualToDate:date]) {
        return YES;
    }
    return NO;
}
//标题颜色
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date
{
    if ([[date laterDate:calenderStartData] isEqualToDate:date] && [[date earlierDate:calenderEndDate] isEqualToDate:date]) {
        return UIColorFromRGB(0x333333);
    }
    return UIColorFromRGB(0xB4B4B4);
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date
{
    if ([[date laterDate:calenderStartData] isEqualToDate:date] && [[date earlierDate:calenderEndDate] isEqualToDate:date]) {
        return UIColorFromRGB(0x333333);
    }
    return UIColorFromRGB(0xB4B4B4);
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date{
    
    return UIColorFromRGB(0xFF7043);
}
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date{
    
    return NO;
}

#pragma mark ----
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    switch (resultData.type) {
        case EmRequestType_DateRange:
        {
            _ticketTimeRange = resultData.data;
            if ([resultData.data objectForKey:@"startDate"]) {
                calenderStartData = [DateUtils dateFromString:[resultData.data objectForKey:@"startDate"] format:@"yyyy-MM-dd"];
            }
            if ([resultData.data objectForKey:@"endDate"]) {
                calenderEndDate = [DateUtils dateFromString:[resultData.data objectForKey:@"endDate"] format:@"yyyy-MM-dd"];
            }
            //重新加载日起显示
            if (_mainCalendar) {
                [_mainCalendar reloadData];
            }
        }
            break;
        case EmRequestType_CarouselIndex:
        {
            //图片
            _bannerInfor = resultData.data;
            //缓存数据
            [[CachedataPreferences sharedInstance] setBannerInfor:_bannerInfor];
            //获取图片地址
            NSMutableArray *imageInfor = [[NSMutableArray alloc] init];
            for (NSDictionary *tempDic in _bannerInfor) {
                if ([tempDic objectForKey:@"Image"]) {
                    [imageInfor addObject:[tempDic objectForKey:@"Image"]];
                }
            }
            //根据数据获取
            if (imageInfor.count > 0) {
                [self.banner loadImagesUrl:imageInfor];
            }
            else
            {
                [self.banner loadImagesUrl:@[@""]];
            }
            [self.banner addTimer];
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













