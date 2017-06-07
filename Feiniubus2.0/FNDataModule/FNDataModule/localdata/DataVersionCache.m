//
//  DataVersionCache.m
//  FNDataModule
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DataVersionCache.h"
#import <FNCommon/FileManager.h>

@interface DataVersionCache ()
{
    NSMutableDictionary *dictDataVersion;
}

@end

@implementation DataVersionCache

+(DataVersionCache*)sharedInstance
{
    static DataVersionCache *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(void)save
{
    //{{modify by 20150122 tianbo 后台写入数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:@"DataVersion.plist"];
        if (![NSKeyedArchiver archiveRootObject:dictDataVersion toFile:fullPath]) {
            DBG_MSG(@"wirte file 'DataVersion.plist' failed!");
        }
    });
    //}}
}

-(id)init
{
    self = [super init];
    if ( !self )
        return nil;
    
    NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:@"DataVersion.plist"];
    dictDataVersion = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    if (dictDataVersion == nil)
    {
        dictDataVersion = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark ---
/**
 *  运营范围版本
 *
 *  @return
 */
-(NSString*)getBusinessScopeVersion
{
    NSString *version = [dictDataVersion valueForKey:@"businessScopeVersion"];
    return version;
}

-(void)setBusinessScopeVersion:(NSString*)version
{
    [dictDataVersion setValue:version forKey:@"businessScopeVersion"];
    [self save];
}
/**
 *  车辆等级版本
 *
 *  @return
 */
-(NSString*)getVehicleLevelVersion
{
    NSString *version = [dictDataVersion valueForKey:@"vehicleLevelVersion"];
    return version;
}

-(void)setVehicleLevelVersion:(NSString*)version
{
    [dictDataVersion setValue:version forKey:@"vehicleLevelVersion"];
    [self save];
}
/**
 *  车辆类型版本
 *
 *  @return
 */
-(NSString*)getVehicleTypeVersion
{
    NSString *version = [dictDataVersion valueForKey:@"vehicleTypeVersion"];
    return version;
}

-(void)setVehicleTypeVersion:(NSString*)version
{
    [dictDataVersion setValue:version forKey:@"vehicleTypeVersion"];
    [self save];
}

/**
 *  运营范围缓存
 *
 *  @return
 */
-(NSArray*)getBusinessScope
{
    NSArray *version = [dictDataVersion valueForKey:@"businessScope"];
    return version;
}

-(void)setBusinessScope:(NSArray*)version
{
    [dictDataVersion setValue:version forKey:@"businessScope"];
    [self save];
}

/**
 *  车辆等级缓存
 *
 *  @return
 */
-(NSArray*)getVehicleLevel
{
    NSArray *version = [dictDataVersion valueForKey:@"vehicleLevel"];
    return version;
}

-(void)setVehicleLevel:(NSArray*)version
{
    [dictDataVersion setValue:version forKey:@"vehicleLevel"];
    [self save];
}

/**
 *  车辆类型缓存
 *
 *  @return
 */
-(NSArray*)getVehicleType
{
    NSArray *version = [dictDataVersion valueForKey:@"vehicleType"];
    return version;
}

-(void)setVehicleType:(NSArray*)version
{
    [dictDataVersion setValue:version forKey:@"vehicleType"];
    [self save];
}




@end
