//
//  NetInterfaceManager.m
//  XinRanApp
//
//  Created by tianbo on 14-12-8.
//  Copyright (c) 2014年 feiniu. All rights reserved.
//

#import "NetInterfaceManager.h"
#import "NetInterFace.h"
#import "UrlMaps.h"

#import <FNDataModule/FNDataModule.h>
#import <FNDataModule/EnvPreferences.h>
#import <FNCommon/NetConstants.h>
#import <FNCommon/JsonUtils.h>
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
    int recordRequestType;
    int recordRequestMothed;
    
    NSString *controllerId;
}

@property(nonatomic, copy) void (^successBlock)(NSString* msg);
@property(nonatomic, copy) void (^failedBlock)(NSString* msg);

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
/**
 *  设置httpheader adcode
 *
 *  @param auth adcode
 */
-(void)setCommuteAdcode:(NSString*)adcode
{
    [[NetInterface sharedInstance] setCommuteAdcode:adcode];
}
-(void)setShuttleAdcode:(NSString*)adcode
{
    [[NetInterface sharedInstance] setShuttleAdcode:adcode];
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
    
    NSString *url = [UrlMapsInstance urlWithTypeNew:type];
    if (!url || url.length == 0) {
        DBG_MSG(@"url is nil!");
        return;
    }
    
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

//特殊处理put方法, 参数与url中
- (void)putRequstWithType:(int)type params:(void(^)(NetParams* params))block
{
    NetParams *params = [[NetParams alloc] init];
    if (block) {
        block(params);
    }
    
    NSString *url = [UrlMapsInstance urlWithTypeNew:type];
    if (!url || url.length == 0) {
        DBG_MSG(@"url is nil!");
        return;
    }
    
    NSDictionary *dict = params.data;
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dict) {
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, dict[key]]];
    }
    
    NSString *strParams = [array componentsJoinedByString:@"&"];
    url = [NSString stringWithFormat:@"%@?%@", url, strParams];
    
    [self putRequst:url body:nil requestType:type];
}

- (void)sendHttpsRequstWithType:(int)type params:(void (^)(NetParams *params))block
{
    NetParams *params = [[NetParams alloc] init];
    if (block) {
        block(params);
    }
    
    NSString *url = [UrlMapsInstance urlWithTypeNew:type];
    if (!url || url.length == 0) {
        DBG_MSG(@"url is nil!");
        return;
    }
    
    switch (params.method) {
        case EMRequstMethod_GET:
        {
            [self httpsGetRequst:url body:params.data requestType:type];
        }
            break;
        case EMRequstMethod_POST:
        {
            [self httpPostFormRequest:url body:params.data requestType:type isHttps:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)sendFormRequstWithType:(int)type params:(void(^)(NetParams* params))block
{
    NetParams *params = [[NetParams alloc] init];
    if (block) {
        block(params);
    }
    
    NSString *url = [UrlMapsInstance urlWithTypeNew:type];
    if (!url || url.length == 0) {
        DBG_MSG(@"url is nil!");
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpPostFormRequest:url body:params.data isHttps:NO type:type suceeseBlock:^(NSDictionary *header, NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:header msg:msg reqType:type];
        
    }failedBlock:^(NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
        
    }];
}

#pragma mark -  https
-(void)httpPostFormRequest:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type isHttps:(BOOL)isHttps
{
    //绕过授权
    //    strUrl = [[NSString alloc ] initWithFormat:@"%@%@",strUrl,@"?manager=xxx"];
    //记录上次请求
    //    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Get];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpPostFormRequest:strUrl body:body isHttps:isHttps type:type suceeseBlock:^(NSDictionary *header, NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:nil msg:msg reqType:type];
        
    }failedBlock:^(NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
        
    }];
}

-(void)httpsGetRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type
{
    //绕过授权
    //    strUrl = [[NSString alloc ] initWithFormat:@"%@%@",strUrl,@"?manager=xxx"];
    //记录上次请求
    //    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Get];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpGetRequest:strUrl body:body isHttps:YES type:type suceeseBlock:^(NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:nil msg:msg reqType:type];
        
    }failedBlock:^(NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
        
    }];
}

#pragma mark - http
-(void)postRequst:(NSString*)strUrl body:(NSDictionary*)body requestType:(int)type
{
    //绕过授权
//    strUrl = [[NSString alloc ] initWithFormat:@"%@%@",strUrl,@"?manager=xxx"];
    //记录上次请求
    [self recordRequst:strUrl body:body requestType:type mothed:RequestMothed_Post];
    
    __weak __typeof(self)weakSelf = self;
    [[NetInterface sharedInstance] httpPostRequest:strUrl body:body type:type suceeseBlock:^(NSDictionary *header, NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:nil msg:msg reqType:type];
        
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
    [[NetInterface sharedInstance] httpGetRequest:strUrl body:body isHttps:NO type:type suceeseBlock:^(NSString *msg){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf successHander:nil msg:msg reqType:type];
        
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
        [strongSelf successHander:nil msg:msg reqType:type];
        
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
        [strongSelf successHander:nil msg:msg reqType:type];
    } failedBlock:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failedHander:error reqType:type];
    }];
}

-(void)successHander:(NSDictionary*)header msg:(NSString*)msg reqType:(int)reqestType
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict ;
        //如果没有数据传入空字典
        if ([msg isEqualToString:@""]) {
            dict = @{};
        }
        else{
            dict = [JsonUtils jsonDataToDcit:data];
        }
        
        ResultDataModel *result = [[ResultDataModel alloc] initWithDictionary:dict header:header reqType:reqestType];
        if (result) {
            if (result.code == EmCode_Success)         //后台返回成功
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //通知页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFinished object:result];
                });
                
            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
//                });
//            }
        }
//        else {
//            DBG_MSG(@"result data is nil!!!");
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
//            });
//        }
    });
    
    
    
    /***********测试代码***********/
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dict = [JsonUtils jsonDataToDcit:data];
//        ResultDataModel *result = [[ResultDataModel alloc] initWithDictionary:dict reqType:reqestType];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //通知页面
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFinished object:result];
//        });
//
//    });
}

-(void)failedHander:(NSError*)error reqType:(int)reqestType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知页面
        ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:reqestType];
        //鉴权失败时候通知
        if (result.code == EmCode_TokenOverdue) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_AuthenticationFail object:result];
            
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_RequestFailed object:result];
        }
        
    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //转化错误信息到ResultDataModel
////        ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:reqestType];
//        
////        if (result.code == 401 || result.code == 403) {
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
    DBG_MSG(@"重新加载上一次的请求");
    if (recordUrl) {
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
    
    if (type == 2) {
        //刷新token请求EMRequestType_RefreshToken==2不记录
        return;
    }
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
//                if (result.code == 0) {
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

@end
