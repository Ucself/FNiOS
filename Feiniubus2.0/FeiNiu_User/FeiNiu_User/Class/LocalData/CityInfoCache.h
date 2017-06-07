//
//  CityInfoCache.h
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/EnvPreferences.h>
#import "FNLocation.h"
//#import "CityObj.h"

@class CityObj;
@class StationObj;
@class FenceObj;
@interface CityInfoCache : EnvPreferences

@property (nonatomic, assign) BOOL bLocationSuccess;

//当前城市选择
@property (nonatomic, copy) CityObj *shuttleCurCity;
//通勤车当前城市选择
@property (nonatomic, copy) CityObj *commuteCurCity;
//当前定位位置
@property (nonatomic, copy) FNLocation *curLocation;
//城市列表
@property (nonatomic, copy) NSArray<CityObj*> *arShuttleCitys;
//通勤车城市列表
@property (nonatomic, copy) NSArray<CityObj*> *arCommuteCitys;
//机场
@property (nonatomic, copy) NSArray<StationObj*> *arAirports;
//火车站
@property (nonatomic, copy) NSArray<StationObj*> *arTrainStations;
//汽车站
@property (nonatomic, copy) NSArray<StationObj*> *arBusStations;
//围栏数据
@property (nonatomic, copy) NSArray<FenceObj*> *arFences;

+(CityInfoCache*)sharedInstance;

-(void) setAirports:(NSArray*)airports trainStations:(NSArray*)trainStations busStations:(NSArray*)busStations;
@end
