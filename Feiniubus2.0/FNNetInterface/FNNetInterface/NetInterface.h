//
//  XRNetwork.h
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
//
//  网络通信类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol NetInterfaceDelegate;

@protocol NetInterfaceDelegate <NSObject>

- (BOOL)httpRequestSeccess: (NSDictionary *)dict;
- (BOOL)httpRequestFailure: (NSString *)msg;

@end

@interface NetInterface : NSObject

/**
 *  设置鉴权字符串
 *
 *  @param auth 鉴权字符串
 */
-(void)setAuthorization:(NSString*)auth;

/**
 *  设置httpheader adcode
 *
 *  @param auth adcode
 */
-(void)setCommuteAdcode:(NSString*)adcode;
-(void)setShuttleAdcode:(NSString*)adcode;
//实例化
+ (NetInterface*)sharedInstance;

/**
 *  检测当前网络状态
 *
 *  @return 0：没有网络  1：移动数据  2：WIFI
 */
- (int)reach;

/**
 *  发送http post请求
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */

- (void)httpPostRequest:(NSString*)strUrl
                   body:(NSDictionary*)body
                   type:(int)type
           suceeseBlock:(void(^)(NSDictionary *header, NSString* msg))suceese
            failedBlock:(void(^)(NSError* msg))failed;

/**
 *  发送http get请求
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */
- (void)httpGetRequest:(NSString*)strUrl
                   body:(NSDictionary*)body
               isHttps:(BOOL)isHttps
                  type:(int)type
           suceeseBlock:(void(^)(NSString* msg))suceese
            failedBlock:(void(^)(NSError* msg))failed;

// 表单方式请求
- (void)httpPostFormRequest:(NSString*)strUrl
                  body:(NSDictionary*)body
                isHttps:(BOOL)isHttps
                       type:(int)type
          suceeseBlock:(void(^)(NSDictionary *header, NSString* msg))suceese
                failedBlock:(void(^)(NSError* msg))failed;

// 同步请求
- (BOOL)httpGetRequestSynchronized:(NSString*)strUrl
                              body:(NSDictionary*)body
                          delegate:(id<NetInterfaceDelegate>)delegate;

/**
 *  发送http get请求
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */
- (void)httpPutRequest:(NSString*)strUrl
                  body:(NSDictionary*)body
          suceeseBlock:(void(^)(NSString* msg))suceese
           failedBlock:(void(^)(NSError* msg))failed;

/**
 *  发送http delete请求
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */
- (void)httpDeleteRequest:(NSString*)strUrl
                  body:(NSDictionary*)body
          suceeseBlock:(void(^)(NSString* msg))suceese
           failedBlock:(void(^)(NSError* msg))failed;
/**
 *  上传图片
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param img     图片
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */
- (void)uploadImage:(NSString*)strUrl
               body:(NSDictionary*)body
                img:(UIImage*)img
       suceeseBlock:(void(^)(NSString* msg))suceese
        failedBlock:(void(^)(NSError* error))failed;
@end
