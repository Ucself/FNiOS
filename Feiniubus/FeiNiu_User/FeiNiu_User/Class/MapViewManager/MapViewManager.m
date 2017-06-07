//
//  MapViewManager.m
//  FNMap
//
//  Created by 易达飞牛 on 15/8/6.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "MapViewManager.h"


@interface MapViewManager ()

@property(nonatomic, strong)MAMapView *mapView;
@property(nonatomic, strong)AMapSearchAPI *search;
@property(nonatomic, strong)NSString *appKey;

@end

@implementation MapViewManager


+(MapViewManager*)sharedInstance
{
    static MapViewManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[MapViewManager alloc] init];
    });
    
    return instance;
}

-(void)registerAppKey:(NSString*)key
{
    self.appKey = key;
    [MAMapServices sharedServices].apiKey = key;
    [AMapSearchServices sharedServices].apiKey = key;
}

-(MAMapView*)getMapView
{
    if (!self.mapView) {
        self.mapView = [[MAMapView alloc] init];
    }
    
    return self.mapView;
}

-(AMapSearchAPI*)getSearch
{
    if (!self.search) {
        self.search = [[AMapSearchAPI alloc] init];
    }
    return self.search;
}

- (void)clearMapView
{
//    self.mapView.showsUserLocation = NO;
    if ([self.mapView respondsToSelector:@selector(setTouchPOIEnabled:)]) {
        self.mapView.touchPOIEnabled = NO;
    }
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.delegate = nil;
    [self.mapView setCompassImage:nil];
}

- (void)clearSearch
{
    self.search.delegate = nil;
}


@end
