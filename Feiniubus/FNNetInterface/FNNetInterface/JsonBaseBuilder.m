//
//  JsonBuilder.m
//  XinRanApp
//
//  Created by tianbo on 14-12-8.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import "JsonBaseBuilder.h"

#import <FNCommon/Data+Encrypt.h>
#import <FNCommon/String+MD5.h>
#import <FNCommon/JsonUtils.h>
#import <FNCommon/Constants.h>

@interface JsonBaseBuilder ()

@property(nonatomic, strong) NSString *strKey;
@end

@implementation JsonBaseBuilder

+(JsonBaseBuilder*)sharedInstance
{
    static JsonBaseBuilder *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

-(void)setCryptKey:(NSString*)key
{
    self.strKey = key;
}

//转换byte
+(NSData*) hexToBytes:(NSString*)str {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+(NSString*)decrypt:(NSString*)json key:(NSString*)key
{
    NSData *cipher = [self hexToBytes:json];
    NSData *plain = [cipher AESDecryptWithKey:key];
    
    NSString *dest = [[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding];
    return dest;
}

#pragma mark- 解析json
+(NSDictionary*)dictionaryWithJson:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key
{
    if (isDecode) {
        json = [self decrypt:json key:key];
    }

    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    
    return [JsonUtils jsonDataToDcit:data];
}

+(NSString*)stringWithJson:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key
{
    NSString *strRet = nil;
    if (isDecode) {
        strRet = [self decrypt:json key:key];
    }
    return strRet;
}

+(NSString*)tokenStringWithJosn:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key
{
    NSString *token;
    NSDictionary *dict = [self dictionaryWithJson:json decode:isDecode key:key];
    if (dict && ![[dict objectForKey:@"token"] isKindOfClass:[NSNull class]]) {
        token = [[NSString alloc] initWithFormat:@"%@",[dict objectForKey:@"token"]];
    }
    return token;
}

+(NSString*)userIdStringWithJosn:(NSString*)json decode:(BOOL)isDecode key:(NSString*)key
{
    NSString *userId;
    NSDictionary *dict = [self dictionaryWithJson:json decode:isDecode key:key];
    if (dict && ![[dict objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
        userId =[[NSString alloc] initWithFormat:@"%@",[dict objectForKey:@"id"]];
    }
    return userId;
}

//生成json
+(NSString*)jsonWithDictionary:(NSDictionary*)dict
{
    JsonBaseBuilder *parse = [[JsonBaseBuilder alloc] init];
    NSString *json = [parse generateJsonWithDictionary:dict];
    return json;
}

#pragma mark- 生成json
-(NSString*)generateJsonWithDictionary:(NSDictionary*)dict;
{
    if (!dict) {
        return nil;
    }
    
    return [JsonUtils dictToJson:dict];
}

#pragma  mark- 生成请求数据
-(NSString*)getVersion
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSRange range = [version rangeOfString:@"."];
    NSString *mainVersion = [version substringToIndex:range.location];
    
    NSString *temp = [version substringFromIndex:range.location+1];
    NSString *subVersion = [[temp componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];;
    
    return [NSString stringWithFormat:@"%@.%@", mainVersion, subVersion];
}

-(NSString*)jsonWithLogin:(NSString*)phone code:(NSString*)code vType:(int)vType password:(NSString*)password userRole:(int)userRole
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:code forKey:@"code"];
    [dict setObject:KDevicesType forKey:@"terminalType"];
    [dict setObject:[[NSNumber alloc] initWithInt:vType] forKey:@"vType"];
    if (password) {
        [dict setObject:password forKey:@"password"];
    }
    
    [dict setObject:[[NSNumber alloc] initWithInt:userRole] forKey:@"userRole"];
    
    NSString *jsonString = [self generateJsonWithDictionary:dict];
    return jsonString;
}

-(NSString*)carOwnerRegist:(NSString*)phone code:(NSString*)code password:(NSString*)password userRole:(int)userRole
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:code forKey:@"code"];
    [dict setObject:@"2" forKey:@"devicesType"];
    [dict setObject:password forKey:@"password"];
    [dict setObject:[[NSNumber alloc] initWithInt:userRole] forKey:@"userRole"];
    
    NSString *jsonString = [self generateJsonWithDictionary:dict];
    return jsonString;
}

#pragma mark-
/**
 *  获取验证码
 *
 *  @param phone 手机号码
 *  @param type  类型    1:登录
 */
-(NSString*)jsonWithVerifyCode:(NSString*)phone type:(int)type
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    
    NSString *jsonString = [self generateJsonWithDictionary:dict];
    return jsonString;
}

-(NSString*)jsonWithRegister:(NSString*)phone code:(NSString*)code
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:code forKey:@"code"];
    
    NSString *jsonString = [self generateJsonWithDictionary:dict];
    return jsonString;
}

-(NSString*)jsonWithUpImage:(int)type
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    
    NSString *jsonString = [self generateJsonWithDictionary:dict];
    return jsonString;
}

////微信和支付宝序列化支付接口
//-(NSString*)jsonWithweixinPay:(NSString*)pdtName price:(NSString*)price orderId:(NSString*)orderId
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
//    [dict setObject:pdtName forKey:KJsonElement_Body];
//    [dict setObject:price forKey:KJsonElement_TotalFee];
//    [dict setObject:orderId forKey:KJsonElement_Trade_no];
//    
//    NSString *jsonString = [self generateJsonWithDictionary:dict];
//    return jsonString;
//}
//
////确认微信支付接口
//-(NSString*)jsonWithCheckWxPay:(NSString*)orderId
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
//    if (orderId && orderId.length > 0) {
//        [dict setObject:orderId forKey:KJsonElement_Trade_no];
//    }
//    
//    NSString *jsonString = [self generateJsonWithDictionary:dict];
//    return jsonString;
//}

@end
