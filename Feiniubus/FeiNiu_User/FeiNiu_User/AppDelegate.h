//
//  AppDelegate.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/7/28.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

//极光key
#define JPushAppKey 		@"7dc8c920f522bc37c455a66f"
#define JPushSecret 		@"b64af584807445e970288011"

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//3DTouch
@property (strong, nonatomic) UIApplicationShortcutItem *shortcutItem;
//定位对象
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

