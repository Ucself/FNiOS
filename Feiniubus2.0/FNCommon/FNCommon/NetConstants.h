//
//  NetConstants.h
//  FNCommon
//
//  Created by tianbo on 16/3/16.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#ifndef NetConstants_h
#define NetConstants_h

/******************************************************
 *  返回码
 ******************************************************/
typedef enum {
    EmCode_Success     = 1,            //成功
    EmCode_Unkown     = 100,          //未知
    EmCode_ParamError = 101,          //参数不正确
    EmCode_AuthError  = 102,          //鉴权失败
    EmCode_SysError   = 103,          //系统资源不足
    EmCode_RefreshTokenError   = 400, //刷新token失败
    EmCode_TokenOverdue   = 401,      //token过期
    
}EMResultCode;


//登示类型
typedef enum{
    LoginType_Phone = 0,
    LoginType_Email,
}LoginType;


//用户角色定议
typedef enum{
    EMUserRole_User = 1,    //用户
    EMUserRole_Driver,      //司机
    EMUserRole_CarOwner     //车主
    
}EMUserRole;

typedef enum {
    ImageTypeCommon = 1,
    ImageTypeCertificate,
}EMImageType;



#pragma mark- 回调消息通知
//请求回调消息通知
#define KNotification_RequestFinished     @"HttpRequestFinishedNoitfication"
#define KNotification_RequestFailed       @"HttpRequestFailedNoitfication"
#define KNotification_AuthenticationFail       @"AuthenticationLogicFailNoitfication"

#endif /* NetConstants_h */
