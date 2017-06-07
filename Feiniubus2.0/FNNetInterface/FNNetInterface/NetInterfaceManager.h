//
//  NetInterfaceManager.h
//  XinRanApp
//
//  Created by tianbo on 14-12-8.
//  Copyright (c) 2014年 feiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NetParams.h"


#define NetManagerInstance  [NetInterfaceManager sharedInstance]

@interface NetInterfaceManager : NSObject


+(NetInterfaceManager*)sharedInstance;

/**
 *  设置网络请求标识
 *
 *  @param controller name
 */
-(void)setReqControllerId:(NSString*)cId;
-(NSString*)getReqControllerId;


/**
 *  重新加载一次数据
 */
-(void) reloadRecordData;

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

/**
 *  检测当前网络状态
 *
 *  @return 0：没有网络  1：移动数据  2：WIFI
 */
- (int)reach;

/**
 *  上传图片
 *
 *  @param img img
 */
- (void)uploadImage:(NSString*)strurl
                img:(UIImage*)img
               body:(NSDictionary*)body
       suceeseBlock:(void(^)(NSString* msg))suceese
        failedBlock:(void(^)(NSError* error))failed;


//-(void)postRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type;
//
//
//-(void)getRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type;
//
//
//-(void)putRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type;
//
//
//- (void)deleteRequest:(NSString *)strUrl body:(NSDictionary*)body requestType:(int)type;


/**
 *  统一网络请求接口
 *
 *  @param type  请求类型
 *  @param block 参数配置回调
 */
- (void)sendRequstWithType:(int)type params:(void(^)(NetParams* params))block;

//特殊处理put方法, 参数与url中
- (void)putRequstWithType:(int)type params:(void(^)(NetParams* params))block;

- (void)sendFormRequstWithType:(int)type params:(void(^)(NetParams* params))block;

- (void)sendHttpsRequstWithType:(int)type params:(void (^)(NetParams *params))block;
@end
