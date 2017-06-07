//
//  AppDelegate.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/7/29.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//


//极光key
#define JPushAppKey 		@"4059b0a46ce274b25182f9c3"
#define JPushSecret 		@"9bb8cc2dc07afe67a6191a74"

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//全局只用一个地图对象
@property (nonatomic,strong) MAMapView *mapView;

@end

