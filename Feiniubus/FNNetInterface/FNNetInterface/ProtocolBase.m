//
//  ProtocolBase.m
//  FNNetInterface
//
//  Created by 易达飞牛 on 15/8/5.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ProtocolBase.h"
#import "JsonBaseBuilder.h"
#import "NetInterfaceManager.h"
#import "NetInterface.h"
#import <FNCommon/Constants.h>

@interface ProtocolBase ()


@end

@implementation ProtocolBase

-(void)postRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type
{
    [[NetInterfaceManager sharedInstance] postRequst:url body:body requestType:type];
}


-(void)getRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type
{
    [[NetInterfaceManager sharedInstance] getRequst:url body:body requestType:type];
}

-(BOOL)getRequstSynchronized:(NSString*)url body:(NSDictionary*)body delegate:(id<NetInterfaceDelegate>)delegate {
    return[[NetInterface sharedInstance]httpGetRequestSynchronized:url body:body delegate:delegate];
}


-(void)putRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type
{
    [[NetInterfaceManager sharedInstance] putRequst:url body:body requestType:type];
}

-(void)deleteRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type
{
    [[NetInterfaceManager sharedInstance] deleteRequest:url body:body requestType:type];
}

-(void)setAuthorization:(NSString*)auth
{
    [[NetInterfaceManager sharedInstance] setAuthorization:auth];
}

#pragma mark --- 通用协议接口
/**
 *  上传图片
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param img     图片
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */
- (void)uploadImage:(UIImage*)img
               body:(NSDictionary*)body
       suceeseBlock:(void(^)(NSString* msg))suceese
        failedBlock:(void(^)(NSError* error))failed
{
    //body = [[JsonBaseBuilder sharedInstance] jsonWithUpImage:1];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, Kurl_UploadImage];
    //[[NetInterfaceManager sharedInstance] uploadImage:url img:img body:body type:1];
    
    [[NetInterfaceManager sharedInstance] uploadImage:url img:img body:body suceeseBlock:^(NSString *msg) {
        suceese(msg);
    } failedBlock:^(NSError *error) {
        failed(error);
    }];
}

/**
 *  传入字典信息的-GET请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)getInforWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType
{
    NSString *body = [[JsonBaseBuilder sharedInstance] generateJsonWithDictionary:dict];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, urlSuffix];
    
    [self getRequst:url body:body requestType:requestType];
}
/**
 *  获取坐标位置get
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)getLocationWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType
{
    NSString *body = [[JsonBaseBuilder sharedInstance] generateJsonWithDictionary:dict];
    NSString *url = [NSString stringWithFormat:@"%@%@", KLocationAddr, urlSuffix];
    
    [self getRequst:url body:body requestType:requestType];
}

-(BOOL)getInforWithNSDictionarySynchronized:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix delegate:(id<NetInterfaceDelegate>)delegate {
    NSString *body = [[JsonBaseBuilder sharedInstance] generateJsonWithDictionary:dict];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, urlSuffix];
    return [self getRequstSynchronized:url body:body delegate:delegate];
}
/**
 *  传入字典信息的-POST请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)postInforWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType
{
    NSString *body = [[JsonBaseBuilder sharedInstance] generateJsonWithDictionary:dict];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, urlSuffix];
    
    [self postRequst:url body:body requestType:requestType];
}
/**
 *  上传坐标位置post
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)postLocationWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType
{
    NSString *body = [[JsonBaseBuilder sharedInstance] generateJsonWithDictionary:dict];
    NSString *url = [NSString stringWithFormat:@"%@%@", KLocationAddr, urlSuffix];
    
    [self postRequst:url body:body requestType:requestType];
}
/**
 *  传入字典信息的-put请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)putInforWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType
{
    NSString *body = [[JsonBaseBuilder sharedInstance] generateJsonWithDictionary:dict];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, urlSuffix];
    
    [self putRequst:url body:body requestType:requestType];
}

#pragma mark 通信协议接口

/**
 *  客户端登录系统
 *
 *  @param phone       手机号码
 *  @param code        短信验证码
 *  @param devicesType 终端类型 1:Android 2:ios3:WeixinWeb4:Mobile5:Pcweb
 *  @param vType       验证类型 1:code 2:password
 *  @param password    客户端密码 使用md5加密
 *  @param userRole    用户角色 1:用户端 2:司机 3:车主4:摆渡车 101:管理员
 */
-(void)login:(NSString*)phone code:(NSString*)code vType:(int)vType password:(NSString*)password userRole:(int)userRole
{
    NSString *body = [[JsonBaseBuilder sharedInstance] jsonWithLogin:phone code:code vType:vType password:password userRole:userRole];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, KUrl_Login];
    [self getRequst:url body:body requestType:KRequestType_Login];
    
}

/**
 *  车主注册
 *
 *  @param phone    电话号码
 *  @param code     短信验证码
 *  @param password 车主密码
 *  @param userRole 用户角色 1:用户端 2:司机 3:车主4:摆渡车 101:管理员
 */
-(void)carOwnerRegist:(NSString*)phone code:(NSString*)code password:(NSString*)password userRole:(int)userRole
{
    NSString *body = [[JsonBaseBuilder sharedInstance] carOwnerRegist:phone code:code password:password userRole:userRole];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, KUrl_Login];
    [self postRequst:url body:body requestType:KRequestType_CarOwnerRegister];
}

/**
 *  获取验证码
 *
 *  @param phone 手机号码
 *  @param type  类型    1:登录   2:注册
 */
-(void)getVerifyCode:(NSString*)phone type:(int)type
{
    NSString *body = [[JsonBaseBuilder sharedInstance] jsonWithVerifyCode:phone type:type];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, KUrl_VerifyCode];
    
    [self getRequst:url body:body requestType:KRequestType_GetVerifyCode];
}

/**
 *  注册新用户
 *
 *  @param phone 手机号码
 *  @param code  短信验证码
 */
-(void)registerNew:(NSString*)phone code:(NSString*)code
{
    NSString *body = [[JsonBaseBuilder sharedInstance] jsonWithRegister:phone code:code];
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, KUrl_Register];
    
    [self getRequst:url body:body requestType:KRequestType_Register];
}

/**
 *  获取用户信息
 */
-(void)memberInfo
{
    NSString *body = @"";
    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, KUrl_MemberInfo];
    
    [self getRequst:url body:body requestType:FNUserRequestType_GetUserInfo];
}


@end












