//
//  ProtocolBase.h
//  FNNetInterface
//
//  Created by 易达飞牛 on 15/8/5.
//  Copyright (c) 2015年 feiniu.com All rights reserved.
//
// 通信接口基类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NetInterface.h"

@interface ProtocolBase : NSObject


-(void)postRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type;

-(void)getRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type;

-(BOOL)getRequstSynchronized:(NSString*)url body:(NSDictionary*)body delegate:(id<NetInterfaceDelegate>)delegate;

-(void)putRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type;

-(void)deleteRequst:(NSString*)url body:(NSDictionary*)body requestType:(int)type;

/**
 *  设置鉴权字符串
 *
 *  @param auth 鉴权字符串
 */
-(void)setAuthorization:(NSString*)auth;

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
        failedBlock:(void(^)(NSError* error))failed;

/**
 *  传入字典信息的-GET请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)getInforWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType;
/**
 *  传入字典信息的-GET请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)getLocationWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType;

-(BOOL)getInforWithNSDictionarySynchronized:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix delegate:(id<NetInterfaceDelegate>)delegate;

/**
 *  传入字典信息的-POST请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)postInforWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType;
/**
 *  上传坐标位置post
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)postLocationWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType;
/**
 *  传入字典信息的-put请求
 *
 *  @param dict        请求的body字典信息
 *  @param urlSuffix   请求后缀
 *  @param requestType 请求类型
 */
-(void)putInforWithNSDictionary:(NSDictionary*)dict urlSuffix:(NSString*)urlSuffix requestType:(int)requestType;

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
-(void)login:(NSString*)phone code:(NSString*)code vType:(int)vType password:(NSString*)password userRole:(int)userRole;

/**
 *  车主注册
 *
 *  @param phone    电话号码
 *  @param code     短信验证码
 *  @param password 车主密码
 *  @param userRole 用户角色 1:用户端 2:司机 3:车主4:摆渡车 101:管理员
 */
-(void)carOwnerRegist:(NSString*)phone code:(NSString*)code password:(NSString*)password userRole:(int)userRole;

/**
 *  获取验证码 GET
 *
 *  @param phone 手机号码
 *  @param type  类型    1:登录
 */
-(void)getVerifyCode:(NSString*)phone type:(int)type;

/**
 *  注册新用户
 *
 *  @param phone 手机号码
 *  @param code  短信验证码
 */
-(void)registerNew:(NSString*)phone code:(NSString*)code;

/**
 *  获取用户信息
 */
-(void)memberInfo;

@end
