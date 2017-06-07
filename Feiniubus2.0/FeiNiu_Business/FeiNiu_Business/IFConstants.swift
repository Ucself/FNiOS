//
//  IFConstants.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import Foundation


#if DEBUG 
    
let KServerAddr              =  "http://dev.feiniubus.com:9030/api/"
let KServerLocationAddr      =  "http://dev.feiniubus.com:9031/api/"    //地图相关测试地址
    
#else
    
let KServerAddr              =  "http://api.feiniubus.com:9001/api/"
let KServerLocationAddr      =  "http://api.feiniubus.com:9003/api/"    //地图相关测试地址
    
#endif


let KPayServerAddr           =  "http://dev.feiniubus.com:8020/api/v1/"  //没有使用
let KAboutServerAddr         =  "http://about.feiniubus.com/"


/******************************************************
 *  v2.0 接口
 ******************************************************/

//登录
let UNI_Login                = "account/login"
//获取验证码
let UNI_VerifyCode           = "account/verificationcode"
//获取设置个人信息
let UNI_UserInfo             = "account/accountinfo"




/******************************************************
 *  请求类型
 ******************************************************/

enum EMRequestType:NSInteger{
    //用户接口
    case EmRequestType_Login = 1,
    EmRequestType_GetVerifyCode,
    EmRequestType_GetUserInfo,
    EmRequestType_SetUserInfo
    
    
    
}