//
//  CommonDefines.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/28.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#ifndef CommonDefines_h
#define CommonDefines_h

#define GloabalTintColor 0xFE714B
#define DarkTintColor 0x666666

#pragma mark - HTML Address


// 规则－城际拼车
#define HTMLAddr_CityCarpoolRule [KAboutServerAddr stringByAppendingString:@"rule1.html"]

// 规则－包车
#define HTMLAddr_CharterRule [KAboutServerAddr stringByAppendingString:@"rule2.html"]

// 规则－接送机
#define HTMLAddr_AirportRule [KAboutServerAddr stringByAppendingString:@"rule3.html"]

// 规则－城区拼车
#define HTMLAddr_AreaCarpoolRule [KAboutServerAddr stringByAppendingString:@"rule4.html"]

// 规则－城区拼车
#define HTMLAddr_TianFuBusRule [KAboutServerAddr stringByAppendingString:@"rule5.html"]

// 规则－退款
#define HTMLAddr_CharterRefundRule [KAboutServerAddr stringByAppendingString:@"rule6.html"]

// 关于
#define HTMLAddr_About [KAboutServerAddr stringByAppendingString:@"about.html"]

// 使用协议－乘客
#define HTMLAddr_ProtocolUser [KAboutServerAddr stringByAppendingString:@"agreement1.html"]

// 温馨提示－拼车－待支付
#define HTMLAddr_CarpoolWaitPayTip [KAboutServerAddr stringByAppendingString:@"prompt1.html"]

// 温馨提示－拼车－已支付
#define HTMLAddr_CarpoolPaidTip [KAboutServerAddr stringByAppendingString:@"prompt2.html"]

// 功能介绍
#define HTMLAddr_FuncIntroduce [KAboutServerAddr stringByAppendingString:@"introduce.html"]


// 客服电话
//#define KEFU_PHONE @"028-85886008"
// 热线电话
#define HOTLINE @"4000820112"


#define NeedToHomeKey @"NeedToHomeKey"
#endif /* CommonDefines_h */
