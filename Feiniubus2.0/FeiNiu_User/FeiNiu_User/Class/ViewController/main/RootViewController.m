//
//  RootViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import "RootViewController.h"
#import "UserPreferences.h"
#import <FNCommon/DateUtils.h>
#import <FNCommon/Common.h>
#import <FNCommon/WebImageCache.h>

#import "CityInfoCache.h"
#import "FNLocation.h"
#import <AMapLocationKit/AMapLocationManager.h>

#import "CityInitializeLogic.h"

#import "ContainerViewController.h"
#import "WebContentViewController.h"

#import <QuartzCore/QuartzCore.h>
@interface RootViewController ()
{
    BOOL bSleep;
    //ScheduleCalendarView *calenderView;
    AMapLocationManager *locationManager;
    
    int timerIndex;
}
@property (nonatomic, copy) NSString *aname;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *btnSkip;
@property (nonatomic, strong) FNLocation *curlocation;
@end

@implementation RootViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    timerIndex = 5;
    
    [self showLaunchImage];
    [self location];
    
    //二月初时间
//    NSDate *februaryEnd = [DateUtils stringToDate:@"2016-02-29 23:59:59"];
//    NSDate *nowData = [NSDate date];
//    NSDate *earlier_date = [nowData earlierDate:februaryEnd];
//    
//    if ([earlier_date isEqual:nowData]) {
//        
//        UIImageView *splashScreen = [[UIImageView alloc] initWithFrame:self.view.bounds];
//        splashScreen.image = [UIImage imageNamed:@"ad"];
//        [self.view addSubview:splashScreen];
//        [self.view bringSubviewToFront:splashScreen];
//        [self.view setNeedsDisplay];
//        
//        bSleep = YES;
//    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [CityInitializeLogic sharedInstance].controller = self;
//    [CityInitializeLogic sharedInstance].done = ^(BOOL success) {
//        [self goNext];
//    };
//    [[CityInitializeLogic sharedInstance] initCityInfo];
    

}

#pragma mark -
//定位
-(void)location
{
    if (!locationManager) {
        locationManager = [[AMapLocationManager alloc] init];
    }
    
    //设置期望定位精度
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //设置不允许系统暂停定位
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    //设置定位超时时间
    [locationManager setLocationTimeout:6];
    //设置逆地理超时时间
    [locationManager setReGeocodeTimeout:3];
    
    
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    __weak RootViewController *weakSelf = self;
    [locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        __strong RootViewController *strongSelf = weakSelf;
        
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"~~定位 用时 %f ms~~", linkTime *1000.0);

        if (error) {
            NSLog(@"~定位失败:%li - %@~", (long)error.code, error.description);
            [CityInfoCache sharedInstance].bLocationSuccess = NO;
            [strongSelf goNext];
            return;
        }
        
        //转换返回的adcode
        NSString *adcode = regeocode.adcode;
        if (!adcode || adcode.length == 0) {
            NSLog(@"定位失败: adcode is nil!");
            [CityInfoCache sharedInstance].bLocationSuccess = NO;
            [strongSelf goNext];
            return;
        }
        
        //缓存定位城市
        _curlocation = [[FNLocation alloc] init];
        if (!regeocode.AOIName || [regeocode.AOIName isEqualToString:@""]) {
            _curlocation.name = regeocode.POIName;
        }
        else{
            _curlocation.name = regeocode.AOIName;
        }
        _curlocation.latitude = location.coordinate.latitude;
        _curlocation.longitude = location.coordinate.longitude;
        _curlocation.adCode = adcode;
        [CityInfoCache sharedInstance].curLocation = _curlocation;
        
        [CityInfoCache sharedInstance].bLocationSuccess = YES;
        [strongSelf goNext];

    }];
}

#pragma mark -----

-(void)goNext
{
    //根据版本号区分是否显示引导页
    NSString *locVer = [UserPreferInstance getAppVersion];
    //打印当前版本
    DBG_MSG(@"The local version is %@", locVer);
    NSString *curVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (locVer && [curVer isEqualToString:locVer]) {
        NSDictionary *advert = [UserPreferInstance getAdvertInfo];
        if (advert) {
            NSString *path = advert[@"image_url"];
            UIImage *image =[[WebImageCache instance] loadImageWithName:path];
            if (image) {
                //显示广告
                [self showAdvertView:image];
            }
            else {
                //首页
                [self performSegueWithIdentifier:@"goMain" sender:nil];
            }
        }
        else{
            //首页
            [self performSegueWithIdentifier:@"goMain" sender:nil];
        }
    }
    else {
        //引导页
        [UserPreferInstance setAppVersion:curVer];
        [self performSegueWithIdentifier:@"goGuide" sender:nil];
    }
    
}

-(void)showLaunchImage
{
    CGSize viewSize = self.view.bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    UIImageView *launchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
    launchView.frame = self.view.bounds;
    launchView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:launchView];
    
}

-(void)showAdvertView:(UIImage*)image
{
    UIView *view = [[UIView alloc] init];
    view.alpha = 0;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    [view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.top.equalTo(0);
        make.right.equalTo(self.view.right);
        make.height.equalTo(deviceWidth*(548.0/375.0));
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imageView];
    [imageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAdvert:)];
    [view addGestureRecognizer:tap];
    
    [UIView transitionWithView:view duration:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.alpha = 1;
    } completion:nil];

    
    self.btnSkip = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnSkip setTitle:@"  跳过 5" forState:UIControlStateNormal];
    [self.btnSkip setTintColor:UITextColor_LightGray];
    [self.btnSkip addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    self.btnSkip.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    self.btnSkip.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.btnSkip.layer.borderWidth = 0.5;
    self.btnSkip.layer.borderColor = UITextColor_LightGray.CGColor;
    self.btnSkip.layer.cornerRadius = 12;
    self.btnSkip.layer.masksToBounds = YES;
    
    [self.view addSubview:self.btnSkip];
    [self.btnSkip makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(50);
        make.height.equalTo(24);
        make.right.equalTo(self.view.right).offset(-25);
        make.bottom.equalTo(self.view.bottom).offset(-25);
    }];
    
    [self startTimer];
}

-(void)tapAdvert:(UITapGestureRecognizer*)tap
{
    NSDictionary *advert = [UserPreferInstance getAdvertInfo];
    if (advert) {
        NSString *target_url = advert[@"target_url"];
        if (target_url && target_url.length != 0) {
            [self stopTimer];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ContainerViewController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"ContainerViewController"];
            
            WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
            webViewController.vcTitle = @"取票退票说明";
            webViewController.urlString = target_url;


            [self.navigationController pushViewController:mainController animated:NO];
            [self.navigationController pushViewController:webViewController animated:NO];
//            NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];//[NSArray arrayWithObjects: mainController, webViewController, nil];
//            [controllers addObject:mainController];
//            [controllers addObject:webViewController];
//            [self.navigationController setViewControllers:controllers animated:YES];
        }
    }
}

-(void)skip:(id)sender
{
    //首页
    [self stopTimer];
    [self performSegueWithIdentifier:@"goMain" sender:nil];
}


#pragma mark - timer
- (void)startTimer{
    if (_timer) {
        [self stopTimer];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];

}

- (void)stopTimer{

    [_timer invalidate];
    _timer = nil;

}

- (void)handleTimer:(NSTimer *)timer{
    if (timerIndex > 1) {
        timerIndex--;
        
        [UIView performWithoutAnimation:^{
            [self.btnSkip setTitle:[NSString stringWithFormat:@"  跳过 %d", timerIndex] forState:UIControlStateNormal];
            [self.btnSkip layoutIfNeeded];
        }];
    }
    else {
        [self skip:nil];
    }
}

#pragma mark - http handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    //ResultDataModel *result = (ResultDataModel *)notification.object;
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}
@end
