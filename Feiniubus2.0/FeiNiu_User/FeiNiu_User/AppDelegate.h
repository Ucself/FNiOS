//
//  AppDelegate.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//定位对象
@property (strong, nonatomic) CLLocationManager *locationManager;

//3DTouch
@property (strong, nonatomic) UIApplicationShortcutItem *shortcutItem;

@property (strong, nonatomic) MainViewController *mainController;
//后台运行
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (assign, nonatomic) BOOL needBgTask;

@end

