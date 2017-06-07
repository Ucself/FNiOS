//
//  MapViewManager.h
//  FNMap
//
//  Created by 易达飞牛 on 15/8/6.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>


@interface MapViewManager : NSObject

+ (MapViewManager*)sharedInstance;

- (void)registerAppKey:(NSString*)key;
- (MAMapView*)getMapView;
- (AMapSearchAPI*)getSearch;
- (void)clearMapView;
- (void)clearSearch;

@end
