//
//  NetInterfaceManager.m
//  XinRanApp
//
//  Created by tianbo on 14-12-8.
//  Copyright (c) 2014年 feiniu. All rights reserved.
//

#import "NetInterfaceManager.h"
#import "NetInterFace.h"
#import "JsonBaseBuilder.h"
#import "UrlMaps.h"

#import <FNDataModule/FNDataModule.h>
#import <FNDataModule/EnvPreferences.h>
#import <FNCommon/Constants.h>
//#import "User.h"
#import <FNDataModule/NSObject+MJKeyValue.h>


typedef NS_ENUM(int, EmRequestMothed)
{
    RequestMothed_Put = 0,
    RequestMothed_Post,
    RequestMothed_Get,
    RequestMothed_Delete,
};


@interface NetInterfaceManager ()
{
    NSString *recordUrl;
    NSDictionary *recordBody;
    RequestType recordRequestType;
    int recordRequestMothed;
    
    NSString *controllerId;
}

@property(nonatomic, copy) void (^successBlock)(NSString* msg);
@property(nonatomic, copy) void (^failedBlock)(NSString* msg);

//url字典
@property (nonatomic, strong) UrlMaps *urpMaps;
@end

@implementation NetInterfaceManager

+(NetInterfaceManager*)sharedInstance
{
    static NetInterfaceManager *instance = nil;
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
        _urpMaps = [[UrlMaps alloc]init];
    }
    return self;
}

-(void)dealloc
{
    self.successBlock = nil;
    self.failedBlock = nil;
}

/**
 *  设置鉴权字符串
 *
 *  @param auth 鉴权字符串
 */
-(void)setAuthorization:(NSString*)auth
{
    [[NetInterface sharedInstance] setAuthorization:auth];
}

- (int)reach
{
    return [[NetInterface sharedInstance] reach];
}

-(void)setSuccessBlock:(void (^)(NSString*))success failedBlock:(void (^)(NSString*))failed
{
    self.successBlock = success;
    self.failedBlock = failed;
}

#pragma mark-
- (void)uploadImage:(NSString*)strurl
                img:(UIImage*)img
               body:(NSDictionary*)body
       suceeseBlock:(void(^)(NSString* msg))suceese
        failedBlock:(void(^)(NSError* error))failed
{
    //绕过授权
//    strurl = [[NSString alloc ] initWithFormat:@"%@%@",strurl,@"?manager=xxx"];
    
    [[NetInterface sharedInstance] uploadImage:strurl body:body img:img suceeseBlock:^(NSString *msg) {
        suceese(msg);
    } failedBlock:^(NSError *error) {
        failed(error);
    }];
}


/**
 *  统一网络请求接口
 *
 *  @param type  请求类型
 *  @param block 参数配置回调
 */
- (void)sendRequstWithType:(int)type params:(void(^)(NetParams* params))block
{
    NetParams *params = [[NetParams alloc] init];
    if (block) {
        block(params);
    }
    
    NSString *url = [_urpMaps urlWithType:type];
    
    switch (params.method) {
        case EMRequstMethod_GET:
        {
            [self getRequst:url body:params.data requestType:type];
        }
            break;
        case EMRequstMethod_POST:
        {
            [self postRequst:url body:params.data requestType:type];
        }
            break;
        case EMRequstMethod_PUT:
        {
            [self putRequst:url body:params.data requestType:type];
        }
            break;
        case EMRequstMethod_DELETE:
        {
            [self deleteRequest:url body:params.data requestType:type];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark-
-(void)postRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type
{
    //绕过授权
//    strUrl = [[NSString alloc ] initWithFormat:@"%@%@",strUrl,@"?manager=xxx"];
    //记录上次请求
    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Post];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpPostRequest:strUrl body:body suceeseBlock:^(NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:msg reqType:type];
        
    }failedBlock:^(NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
    }];
}

-(void)getRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type
{
    //绕过授权
//    strUrl = [[NSString alloc ] initWithFormat:@"%@%@",strUrl,@"?manager=xxx"];
    //记录上次请求
    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Get];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpGetRequest:strUrl body:body suceeseBlock:^(NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:msg reqType:type];
        
    }failedBlock:^(NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
        
    }];
}

-(void)putRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type
{
    //记录上次请求
    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Put];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpPutRequest:strUrl body:body suceeseBlock:^(NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:msg reqType:type];
        
    }failedBlock:^(NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
        
    }];
}
- (void)deleteRequest:(NSString *)strUrl body:(NSDictionary*)body requestType:(int)type{
    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Delete];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpDeleteRequest:strUrl body:body suceeseBlock:^(NSString *msg) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:msg reqType:type];
    } failedBlock:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
    }];
}

-(void)successHander:(NSString*)msg reqType:(int)reqestType
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict = [JsonBaseBuilder dictionaryWithJson:msg decode:NO key:nil];
        if (dict) {
            if ([dict objectForKey:@"code"] &&
                ([[dict objectForKey:@"code"] intValue] == 100002 ||
                 [[dict objectForKey:@"code"] intValue] == 100001) &&
                reqestType!= KRequestType_Login)         //后台鉴权失败
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [NSError errorWithDomain:@"" code:401 userInfo:nil];
                    NSMutableDictionary *result = [@{@"type": [NSNumber numberWithInt:reqestType], @"error":error} mutableCopy];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    ResultDataModel *obj = [[ResultDataModel alloc] initWithDictionary:dict reqType:reqestType];
                    
                    //通知页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFinished object:obj];
                });
            }
        }
        else {
            DBG_MSG(@"dict is nil!!!");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"" code:405 userInfo:@{NSLocalizedDescriptionKey:@"数据异常"}];

                NSMutableDictionary *result = [@{@"type": [NSNumber numberWithInt:reqestType], @"error":error} mutableCopy];

                [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
            });

        }
    });
}

-(void)failedHander:(NSError*)error reqType:(int)reqestType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知页面
        NSMutableDictionary *result = [@{@"type": [NSNumber numberWithInt:reqestType], @"error":error} mutableCopy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //转化错误信息到ResultDataModel
////        ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:reqestType];
//        
////        if (result.resultCode == 401 || result.resultCode == 403) {
////            //鉴权失效重置token
////            [[EnvPreferences sharedInstance] setToken:nil];
////            [[EnvPreferences sharedInstance] setUserId:nil];
////            //[self tokenExpireHandler];
////            return ;
////        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //通知页面
//            NSDictionary *result = @{@"type": [NSNumber numberWithInt:reqestType], @"error":error};
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
//        });
//    });
}

#pragma mark-

//重新加载上一次的请求
-(void) reloadRecordData {
    
    if (recordUrl && recordBody) {
        switch (recordRequestMothed) {
            case RequestMothed_Post:
                [self postRequst:recordUrl body:recordBody requestType:recordRequestType];
                break;
            case RequestMothed_Get:
                [self getRequst:recordUrl body:recordBody requestType:recordRequestType];
                break;
            case RequestMothed_Put:
                [self putRequst:recordUrl body:recordBody requestType:recordRequestType];
                break;
            case RequestMothed_Delete:
                [self deleteRequest:recordUrl body:recordBody requestType:recordRequestType];
                break;
            default:
                
                break;
        }
    }
    
}

-(void) recordRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type mothed:(EmRequestMothed)mothed {
    //记录一次请求数据
    recordUrl           = strUrl;
    recordBody          = body;
    recordRequestType   = type;
    recordRequestMothed = mothed;
}

//会话过期处理方法
//-(void)tokenExpireHandler {
//
//    //// stup 1. 登录
//    User *user = [[EnvPreferences sharedInstance] getUserInfo];
//    if (user && user.username && user.pwd) {
//
//        NSString *body = [[JsonBuilder sharedInstance] jsonWithLogin:user.username pwd:user.pwd type: LoginType_Email];
//        NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, KUrl_Login];
//
//        [[NetInterface sharedInstance] httpPostRequest:url body:body suceeseBlock:^(NSString *msg){
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//                //转化josn数据到ResultDataModel
//                ResultDataModel *result = [[ResultDataModel alloc] initWithDictionary:[JsonBuilder dictionaryWithJson:msg decode:NO key:nil] reqType:KReqestType_Login];
//
//                if (result.resultCode == 0) {
//                    //解析出token字符串
//                    NSString *token = [JsonBuilder tokenStringWithJosn:msg decode:NO key:nil];
//                    [[EnvPreferences sharedInstance] setToken:token];
//
//                    //// stup 2. 重新请求
//                    [self reloadRecordData];
//                }
//                else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        //通知页面
//                        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
//                    });
//                }
//
//            });
//
//        }failedBlock:^(NSError *error) {
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                //转化错误信息到ResultDataModel
//                ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:KReqestType_Login];
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    //通知页面
//                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
//                });
//
//            });
//
//        }];
//    }
//}



/**
 *  设置当前的ViewController
 *
 *  @param controller name
 */
-(void)setReqControllerId:(NSString*)cId
{
    //DBG_MSG(@"--controllerid=%@", cId)
    controllerId= cId;
}

-(NSString*)getReqControllerId
{
    return controllerId;
}





///**
// *  微信支付接口
// *
// *  @param pdtName  商品名称
// *  @param price 总价
// *  @param orderId  订单id
// */
//-(void)weixinPay:(NSString*)pdtName price:(NSString*)price orderId:(NSString*)orderId
//{
//    NSString *body = [[JsonBuilder sharedInstance] jsonWithweixinPay:pdtName price:price orderId:orderId];
//    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, Kurl_WXPay];
//
//    [self postRequst:url body:body requestType:KReqestType_weixinPay];
//}
//
///**
// *  微信支付确认接口
// *
// *  @param orderId 订单id
// */
//-(void)checkWXPay:(NSString*)orderId
//{
//    NSString *body = [[JsonBuilder sharedInstance] jsonWithCheckWxPay:orderId];
//    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, Kurl_Checkwxpay];
//
//    [self postRequst:url body:body requestType:KReqestType_CheckWXPay];
//}
///**
// *  支付宝支付接口
// *
// *  @param pdtName  商品名称
// *  @param price 总价
// *  @param orderId  订单id
// */
//-(void)aliPay:(NSString*)pdtName price:(NSString*)price orderId:(NSString*)orderId
//{
//    NSString *body = [[JsonBuilder sharedInstance] jsonWithweixinPay:pdtName price:price orderId:orderId];
//    NSString *url = [NSString stringWithFormat:@"%@%@", KServerAddr, Kurl_AliPay];
//    
//    [self postRequst:url body:body requestType:KReqestType_AliPay];
//}


@end
