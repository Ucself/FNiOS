//
//  IFConstants.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import Foundation


#if DEBUG                    //需要在配置 -D DEBUG
    
let KServerAddr              =  "http://micro.feelbus.cn/Harrenhal/api/"
let KServerLocationAddr      =  "http://dev.feiniubus.com:9031/api/"    //地图相关测试地址
    
#else
    
let KServerAddr              =  "http://micro.feelbus.cn/Harrenhal/api/"
let KServerLocationAddr      =  "http://api.feiniubus.com:9003/api/"    //地图相关测试地址
    
#endif

let KPayServerAddr           =  "http://dev.feiniubus.com:8020/api/v1/"  //没有使用
let KAboutServerAddr         =  "http://about.feiniubus.com/"

//常量
let KClient_id               =  "b65d7a61d53149e5bfb5f0a9826229f9"
let KClient_secret           =  "ye9lZVc5F1przoxAmj44lsUHp1HtLYulbXMZ54Ag0Pk"

/******************************************************
 *  v1.0 接口
 ******************************************************/
//MARK: - 商家账号信息
//商家注册
let UNI_Registered           = "account/create"
let UNI_CityOpen             = "city/open"
//商家登录
let UNI_Login                = "account/login"
//验证码接口
let UNI_VerifyCode           = "vcode/get"
//密码重置接口
let UNI_PasswordReset        = "password/exist"
//访问令牌刷新接口
let UNI_TokenRefresh         = "account/refresh"
//密码修改接口
let UNI_PasswordChange       = "password/change"

//{{重置密码相关接口
//手机号存在检查
let UNI_PwdExist             = "password/exist"
//获取重置验证码
let UNI_PwdVerify            = "password/verify"
//重置密码
let UNI_PwdReset             = "password/reset"
//}}

//商家列表获取接口
let UNI_MerchantList         = "merchant/list"

//订单中心
let UNI_OrderCenterList      = "order/station/list"
let UNI_OrderDetail          = "order/station/detail"


/******************************************************
 *  请求类型
 ******************************************************/

enum EMRequestType:NSInteger{
    //用户接口
    case emRequestType_PostRegistered = 1,
    emRequestType_GetCityOpen,
    emRequestType_PostLogin,
    emRequestType_GetVerifyCode,
    emRequestType_GetPasswordChange,
    emRequestType_PostTokenRefresh,
    emRequestType_PostPasswordChange,
    //订单中心
    emRequestType_GetMerchantList,
    emRequestType_GetOrderCenterList,
    emRequestType_GetOrderDetail,
    
    //{{重置密码相关接口
    emRequestType_GetPwdExist,
    emRequestType_GetPwdVerify,
    emRequestType_PostPwdReset
    //}}

}



func REQUESTURL(_ X:String) -> String {
    //return String(format: "%s%s", KServerAddr, X)      //这个是返回16进制
    return "\(KServerAddr)\(X)"
}

func REQUESTURL2(_ A:String, B:String) -> String {
//    return String(format: "%s%s", A, B)
    return "\(A)\(B)"
}
