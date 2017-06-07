//
//  DataVersionCache.h
//  FNDataModule
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataVersionCache : NSObject

+(DataVersionCache*)sharedInstance;

/**
 *  运营范围版本
 *
 *  @return
 */
-(NSString*)getBusinessScopeVersion;

-(void)setBusinessScopeVersion:(NSString*)version;
/**
 *  车辆等级版本
 *
 *  @return
 */
-(NSString*)getVehicleLevelVersion;

-(void)setVehicleLevelVersion:(NSString*)version;
/**
 *  车辆类型版本
 *
 *  @return
 */
-(NSString*)getVehicleTypeVersion;


-(void)setVehicleTypeVersion:(NSString*)version;
/**
 *  运营范围缓存
 *
 *  @return
 */
-(NSArray*)getBusinessScope;

-(void)setBusinessScope:(NSArray*)version;
/**
 *  车辆等级缓存
 *
 *  @return
 */
-(NSArray*)getVehicleLevel;

-(void)setVehicleLevel:(NSArray*)version;
/**
 *  车辆类型缓存
 *
 *  @return
 */
-(NSArray*)getVehicleType;

-(void)setVehicleType:(NSArray*)version;

@end
