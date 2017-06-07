//
//  CityInfoCache.m
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CityInfoCache.h"
#import "FeiNiu_User-Swift.h"

@implementation CityInfoCache


-(instancetype)init
{
    self = [super init];
    if (self) {
        _bLocationSuccess = NO;
        _shuttleCurCity = [self.preDict objectForKey:@"currentCity"];
        _commuteCurCity = [self.preDict objectForKey:@"commuteCurCity"];
//        _arShuttleCitys = [self.preDict objectForKey:@"cityList"];
//        _arCommuteCitys = [self.preDict objectForKey:@"commuteCityList"];
//        _arAirports = [self.preDict objectForKey:@"arAirports"];
//        _arTrainStations = [self.preDict objectForKey:@"arTrainStations"];
//        _arBusStations = [self.preDict objectForKey:@"arBusStations"];
//        _arFences = [self.preDict objectForKey:@"arFences"];
    }
    return self;
}

+(CityInfoCache*)sharedInstance
{
    static CityInfoCache *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(void)setShuttleCurCity:(CityObj *)shuttleCurCity
{
    if (!shuttleCurCity) {
        return;
    }
    _shuttleCurCity = shuttleCurCity;
    [self.preDict setObject:shuttleCurCity forKey:@"currentCity"];
    [self save];
}


-(void)setCommuteCurCity:(CityObj *)commuteCurCity
{
    if (!commuteCurCity) {
        return;
    }
    _commuteCurCity = commuteCurCity;
    [self.preDict setObject:commuteCurCity forKey:@"commuteCurCity"];
    [self save];
}

-(void)setArShuttleCitys:(NSArray*)arShuttleCitys
{
    _arShuttleCitys = arShuttleCitys;
    //    [self.preDict setObject:arShuttleCitys forKey:@"cityList"];
    //    [self save];
}

-(void)setArCommuteCitys:(NSArray<CityObj *> *)arCommuteCitys
{
    _arCommuteCitys = arCommuteCitys;
//    [self.preDict setObject:arCommuteCitys forKey:@"arCommuteCitys"];
//    [self save];
}

-(void)setArAirports:(NSArray<StationObj*> *)arAirports
{
    _arAirports = arAirports;
    //[self.preDict setObject:arAirports forKey:@"arAirports"];
    //[self save];

}

-(void)setArTrainStations:(NSArray<StationObj*> *)arTrainStations
{
    _arTrainStations = arTrainStations;
    //[self.preDict setObject:arTrainStations forKey:@"arTrainStations"];
    //[self save];
    
}

-(void)setArBusStations:(NSArray<StationObj*> *)arBusStations
{
    _arBusStations = arBusStations;
    //[self.preDict setObject:arBusStations forKey:@"arBusStations"];
    //[self save];
    
}


-(void) setAirports:(NSArray*)airports trainStations:(NSArray*)trainStations busStations:(NSArray*)busStations
{
    _arAirports = airports;
    _arTrainStations = trainStations;
    _arBusStations = busStations;
//    [self.preDict setObject:airports forKey:@"arAirports"];
//    [self.preDict setObject:trainStations forKey:@"arTrainStations"];
//    [self.preDict setObject:busStations forKey:@"arBusStations"];
    //[self save];
}

-(void)setArFences:(NSArray<FenceObj *> *)arFences
{
    _arFences = arFences;
    //[self.preDict setObject:arFences forKey:@"arFences"];
    //[self save];
}

@end
