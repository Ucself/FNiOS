//
//  FlightInfoCache.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "FlightInfoCache.h"

@implementation FlightInfoCache

-(instancetype)init
{
    self = [super init];
    if (self) {
        _searchHistoryFlight = [self.preDict objectForKey:@"searchHistoryFlight"];
    }
    return self;
}

+(FlightInfoCache*)sharedInstance
{
    static FlightInfoCache *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(void)setSearchHistoryFlight:(NSMutableArray *)historyFlightArray
{
    if (!historyFlightArray) {
        return;
    }
    _searchHistoryFlight = historyFlightArray;
    [self.preDict setObject:historyFlightArray forKey:@"searchHistoryFlight"];
    [self save];
}
@end
