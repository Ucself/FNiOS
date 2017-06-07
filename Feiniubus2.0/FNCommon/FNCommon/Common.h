//
//  Common.h
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
//  通用基础功能定义

#ifndef XinRanApp_Common_h
#define XinRanApp_Common_h



//颜色转换
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColor_DefGreen    UIColorFromRGB(0x24aa59)
#define UIColor_DefOrange   UIColorFromRGB(0xfe6e35)
#define UIColor_Background  UIColorFromRGB(0xf9f9fd)

#define UITextColor_Black      UIColorFromRGB(0x303030)
#define UITextColor_DarkGray   UIColorFromRGB(0x828282)
#define UITextColor_LightGray  UIColorFromRGB(0xbbbbbb)

#define UINavigationBKColor    UIColorFromRGB(0xf4f4f8)
#define UITranslucentBKColor   [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5]

#define degreesToRadian(x) (M_PI * x / 180.0)

//#define DBG_MSG(msg, ...)\
//{\
//DBG_MSG(@"[ %@:(%d)] %@<-- %@ -->",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,[NSString stringWithUTF8String:__FUNCTION__], [NSString stringWithFormat:(msg), ##__VA_ARGS__]);\
//}

#ifdef DEBUG  // 调试阶段
#define DBG_MSG(msg, ...)\
{\
printf("%s <- %s ->\n",__FUNCTION__, [[NSString stringWithFormat:(msg), ##__VA_ARGS__] UTF8String]);\
}
#else // 发布阶段
#define DBG_MSG(msg, ...)
#endif


#ifdef DEBUG
#define NSLog(msg, ...)\
{\
printf("%s <- %s ->\n",__FUNCTION__, [[NSString stringWithFormat:(msg), ##__VA_ARGS__] UTF8String]);\
}

#else
#define NSLog(format, ...)
#endif


#if __has_feature(objc_arc)
#define ShowMessage(X,Y) UIAlertView *t = [[UIAlertView alloc]initWithTitle:X message:Y delegate:nil \
cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] ; \
[t show];
#else
#define ShowMessage(X,Y) UIAlertView *t = [[UIAlertView alloc]initWithTitle:X message:Y delegate:nil \
cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] ; \
[t show];\
[t release];
#endif

#define SYSVERSION  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define BUILDVERSION  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]

#define ISIOS9BEFORE   ( [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0 )
//设备的相关信息
#define deviceWidth  [UIScreen mainScreen].bounds.size.width
#define deviceHeight  [UIScreen mainScreen].bounds.size.height
#define deviceUUID  [[[UIDevice currentDevice] identifierForVendor] UUIDString]

#define KNotifyEnterBackGround   @"enterBackGround"
#define KNotifyBecomeActive      @"becomeActive"


#define NotOpenCityAlertString @"目前小牛只支持成都地区"

#define KNotifyNetworkStatusChange     @"NetworkStatusChange"
typedef enum XNetworkStatus {
    NotNetwork = 0,
    NetworkViaWiFi,
    NetworkViaWWAN
} XNetworkStatus;


#endif
