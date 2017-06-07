//
//  FlightInfoCache.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

@interface FlightInfoCache : EnvPreferences

//当前城市选择
@property (nonatomic, copy) NSMutableArray *searchHistoryFlight;

+(FlightInfoCache*)sharedInstance;

-(void)setSearchHistoryFlight:(NSMutableArray *)historyFlightArray;
@end
