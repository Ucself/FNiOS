//
//  AppDelegate.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/7/29.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//


//极光key
#define JPushAppKey 		@"15bbc3acd9942bb748d917f5"
#define JPushSecret 		@"aedf090d6adc4b99a3c97794"

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "DriverLocationUploadModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//位置对象
@property (nonatomic,copy) DriverLocationUploadModel *locationUploadModel;
//全局只用一个地图对象
@property (nonatomic,strong) MAMapView *mapView;

@end

