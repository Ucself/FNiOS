//
//  IFConstanst.h
//  FeiNiu_Business
//
//  Created by tianbo on 16/7/5.
//  Copyright © 2016年 tianbo. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef IFConstanst_h
#define IFConstanst_h


#ifdef DEBUG    // 调试阶段
#define KTestServer
#else           // 发布阶段
#define KFinalServer
#endif

//#define KTestServer
//#define KFinalServer

//测试环境地址--围栏-车坐标使用
#ifdef KTestServer

#define KServerAddr                @"http://dev.feiniubus.com:9030/api/"
#define KServerLocationAddr        @"http://dev.feiniubus.com:9031/api/"    //地图相关测试地址

#endif

//正式地址
#ifdef KFinalServer

#define KServerAddr                @"http://api.feiniubus.com:9001/api/"
#define KServerLocationAddr        @"http://api.feiniubus.com:9003/api/"    //地图相关测试地址

#endif

#define KPayServerAddr             @"http://dev.feiniubus.com:8020/api/v1/"  //没有使用
#define KAboutServerAddr           @"http://about.feiniubus.com/"




/******************************************************
 *  v2.0 接口
 ******************************************************/

//登录
#define UNI_Login                 @"account/login"
//获取验证码
#define UNI_VerifyCode            @"account/verificationcode"
//获取设置个人信息
#define UNI_UserInfo              @"account/accountinfo"



///******************************************************
// *  请求类型
// ******************************************************/
////typedef NS_ENUM(NSInteger, EMRequestType){
//enum EMRequestType:int{
//    //用户接口
//    EmRequestType_Login = 0,
//    EmRequestType_GetVerifyCode=1,
//    EmRequestType_GetUserInfo=2,
//    EmRequestType_SetUserInfo=3,
//
//    
//};



#define REQUESTURL(X) [NSString stringWithFormat:@"%@%@", KServerAddr, X]
#define REQUESTURL2(A, B) [NSString stringWithFormat:@"%@%@", A, B]



#endif /* IFConstanst_h */
