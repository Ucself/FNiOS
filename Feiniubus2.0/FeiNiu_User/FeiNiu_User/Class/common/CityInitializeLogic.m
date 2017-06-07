//
//  CityInitializeLogic.m
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CityInitializeLogic.h"
#import <FNDataModule/ResultDataModel.h>
#import <FNNetInterface/FNNetInterface.h>

#import "CityInfoCache.h"
#import "FNLocation.h"
#import <AMapLocationKit/AMapLocationManager.h>

#import "FeiNiu_User-Swift.h"
@interface CityInitializeLogic ()
{
    AMapLocationManager *locationManager;
}

@property (nonatomic, copy) NSString *aname;

@end

@implementation CityInitializeLogic


+(CityInitializeLogic*)sharedInstance
{
    static CityInitializeLogic *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
        //注册网络请求通知
    });
    
    return instance;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
-(void)initCityInfo
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
    
//    if ([CityInfoCache sharedInstance].arCitys && [CityInfoCache sharedInstance].arTrainStations) {
//        [self location];
//        return;
//    }
//    else {
        [self getOpenCitys];
//    }
}

-(void)initStationInfoWithAdcode:(NSString*)adcode
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
    
    [self getCityStations:adcode];
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
    __weak CityInitializeLogic *weakSelf = self;
    [locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        __strong CityInitializeLogic *strongSelf = weakSelf;
        
        if (error) {
            NSLog(@"~定位失败:%li - %@~", (long)error.code, error.description);
            
            if (error.code == AMapLocationErrorLocateFailed) {
                [strongSelf locationFailedHandler];
                return;
            }
        }
        
        NSLog(@"~定位成功~");
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"~~定位用时 %f ms~~", linkTime *1000.0);
        
        //转换返回的adcode
        NSString *adcode = regeocode.adcode;
        if (!adcode || adcode.length == 0) {
            NSLog(@"定位失败: adcode is nil!");
            [strongSelf locationFailedHandler];
            return;
        }
        
        [CityInfoCache sharedInstance].bLocationSuccess = YES;
        
        //开通城市数据
        NSArray *arCitys = [CityInfoCache sharedInstance].arShuttleCitys;
        
        BOOL isInOpenCity = NO;
        for (CityObj *city in arCitys) {
            if ([[adcode substringToIndex:4] isEqualToString:[city.adcode substringToIndex:4]]) {
                adcode = city.adcode;
                //缓存定位默认城市
                [CityInfoCache sharedInstance].shuttleCurCity = city;
                isInOpenCity = YES;
                break;
            }
        }
        
        if (isInOpenCity) {
            //当前位置
            //if (regeocode.neighborhood && regeocode.neighborhood.length != 0) {
            FNLocation *curlocation = [[FNLocation alloc] init];
            if (!regeocode.AOIName || [regeocode.AOIName isEqualToString:@""]) {
                strongSelf.aname = regeocode.POIName;
            }
            else{
                strongSelf.aname = regeocode.AOIName;
            }
            curlocation.name = strongSelf.aname;;
            curlocation.latitude = location.coordinate.latitude;
            curlocation.longitude = location.coordinate.longitude;
            curlocation.adCode = adcode;
            
            [CityInfoCache sharedInstance].curLocation = curlocation;
            //}
        }
        else {
            //如果定位未在城市列表中默认第一个
            if (arCitys.count > 0) {
                [CityInfoCache sharedInstance].shuttleCurCity = arCitys[0];
            }
        }
        
        //取车站信息
        [strongSelf getCityStations:[CityInfoCache sharedInstance].shuttleCurCity.adcode];
    }];
}

-(void) locationFailedHandler
{
    [CityInfoCache sharedInstance].bLocationSuccess = NO;
    
    NSArray *arCitys = [CityInfoCache sharedInstance].arShuttleCitys;
    if (arCitys.count != 0) {
        CityObj *city = arCitys[0];
        if (city) {
            [CityInfoCache sharedInstance].shuttleCurCity = city;
            [self getCityStations:city.adcode];
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (self.done) {
            self.done(NO);
        }
    }
    
}
#pragma mark -
-(void)getOpenCitys
{
    [NetManagerInstance sendRequstWithType:EmRequestType_OpenCity params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
}

-(void)getCityStations:(NSString*)adcode
{
    
    [NetManagerInstance sendRequstWithType:EMRequestType_StationInfo params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{@"adcode": adcode,
                        @"type": @"All"};    //4 取全部车站
    }];
}

#pragma mark -
-(void)httpRequestFinished:(NSNotification *)notification
{
    ResultDataModel *result = (ResultDataModel *)notification.object;

    if (result.type == EmRequestType_OpenCity) {
        
        NSArray *arCitys = [CityObj mj_objectArrayWithKeyValuesArray:result.data];
        [[CityInfoCache sharedInstance] setArShuttleCitys:arCitys];
        
        //定位当前城市
        [self location];
    }
    else if (result.type == EMRequestType_StationInfo) {
        //保存车站数据
        NSDictionary *dict = result.data;
        NSArray *arAirport = [StationObj mj_objectArrayWithKeyValuesArray:dict[@"airport"]];
        NSArray *arTrainStations = [StationObj mj_objectArrayWithKeyValuesArray:dict[@"train_station"]];
        NSArray *arBusStations = [StationObj mj_objectArrayWithKeyValuesArray:dict[@"bus_station"]];
        [[CityInfoCache sharedInstance] setArAirports:arAirport];
        [[CityInfoCache sharedInstance] setArTrainStations:arTrainStations];
        [[CityInfoCache sharedInstance] setArBusStations:arBusStations];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (self.done) {
            self.done(YES);
        }
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification{
//    ResultDataModel *result = (ResultDataModel *)notification.object;
//    if (result.type == EmRequestType_OpenCity ||
//        result.type == EMRequestType_StationInfo) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [self.controller httpRequestFailed:notification];
//    }
    ResultDataModel *result = (ResultDataModel *)notification.object;
    [self.controller showTip:[NSString stringWithFormat:@"获取城市基础信息失败 - code:%d", result.type] WithType:FNTipTypeFailure];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.done) {
        self.done(NO);
    }
    
}
@end
