//
//  JsonBuilder.h
//  XinRanApp
//
//  Created by tianbo on 14-12-8.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
//  json类

#import <Foundation/Foundation.h>

@interface JsonBaseBuilder : NSObject
{
    
}

+(JsonBaseBuilder*)sharedInstance;

/**
 *  设置加解密密钥
 *
 *  @param key 密钥
 */
-(void)setCryptKey:(NSString*)key;


//解析json
///////////////////////////////////////////////////////////////

/**
*  解析json数据
*
*  @param json     json字符串
*  @param isDecode 是否需要解密
*  @param key      密钥
*
*  @return dictionary
*/
+(NSDictionary*)dictionaryWithJson:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key;

/**
 *  initAndPlay
 *
 *  @param json     json字符串
 *  @param isDecode 是否需要解密
 *  @param key      密钥
 *
 *  @return string
 */
+(NSString*)stringWithJson:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key;

/**
 *  解析token字符串
 *
 *  @param json     josn字符串
 *  @param isDecode 是否需要解密
 *  @param key      密钥
 *
 *  @return return value description
 */
+(NSString*)tokenStringWithJosn:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key;
/**
 *  解析userId字符串
 *
 *  @param json     josn字符串
 *  @param isDecode 是否需要解密
 *  @param key      密钥
 *
 *  @return return value description
 */
+(NSString*)userIdStringWithJosn:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key;

#pragma mark --生成json
/**
 *  生成json字符串
 *
 *  @param dict 字典
 *
 *  @return json字符串
 */
+(NSString*)jsonWithDictionary:(NSDictionary*)dict;

-(NSString*)generateJsonWithDictionary:(NSDictionary*)dict;


//生成请求json数据
///////////////////////////////////////////////////////////////

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
-(NSString*)jsonWithLogin:(NSString*)phone code:(NSString*)code vType:(int)vType password:(NSString*)password userRole:(int)userRole;

/**
 *  车主注册
 *
 *  @param phone    手机号码
 *  @param code     短信验证码
 *  @param password 密码 使用md5加密
 *  @param userRole 用户角色1:用户端 2:司机 3:车主4:摆渡车 101:管理员
 *
 *  @return
 */
-(NSString*)carOwnerRegist:(NSString*)phone code:(NSString*)code password:(NSString*)password userRole:(int)userRole;

/**
 *  获取验证码
 *
 *  @param phone 手机号码
 *  @param type  类型    1:登录
 */
-(NSString*)jsonWithVerifyCode:(NSString*)phone type:(int)type;



-(NSString*)jsonWithRegister:(NSString*)phone code:(NSString*)code;

-(NSString*)jsonWithUpImage:(int)type;


////微信支付接口
//-(NSString*)jsonWithweixinPay:(NSString*)pdtName price:(NSString*)price orderId:(NSString*)orderId;
//
////确认微信支付接口
//-(NSString*)jsonWithCheckWxPay:(NSString*)orderId;



@end
