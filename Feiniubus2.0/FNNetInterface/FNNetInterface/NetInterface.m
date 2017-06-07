//
//  XRNetwork.m
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import "NetInterface.h"
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
//#import "JsonBaseBuilder.h"

#import <FNCommon/JsonUtils.h>


#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES


@interface NetInterface ()

@property (nonatomic, retain) NSString *curUrl;
@property (nonatomic, retain) NSString *curBody;

@property (nonatomic, copy) NSString *authString;
@property (nonatomic, copy) NSString *commuteAdcode;
@property (nonatomic, copy) NSString *shuttleAdcode;
@end



@implementation NetInterface

+ (NetInterface*)sharedInstance
{
    static NetInterface *instance = nil;
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

- (int)reach
{
    static int ret = 0;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DBG_MSG(@"%ld", (long)status);
        ret = status;
    }];
    
    return ret;
}


#pragma mark ---
/**
 *  设置鉴权字符串
 *
 *  @param auth 鉴权字符串
 */
-(void)setAuthorization:(NSString*)auth
{
    self.authString = auth;
}

/**
 *  设置httpheader adcode
 *
 *  @param auth adcode
 */
-(void)setCommuteAdcode:(NSString*)adcode
{
    _commuteAdcode = adcode;
}
-(void)setShuttleAdcode:(NSString*)adcode
{
    _shuttleAdcode = adcode;
}

-(AFHTTPRequestOperationManager*) buildHttpManager:(int)withType
{
    //初始化http
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20.0;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setValue:BUILDVERSION forHTTPHeaderField:@"AppVersion"];
    [manager.requestSerializer setValue:@"2" forHTTPHeaderField:@"TerminalType"];
    
    //设置token
    if (self.authString && self.authString.length != 0) {
        [manager.requestSerializer setValue:self.authString forHTTPHeaderField:@"Authorization"];
    }
    //adcode 通勤与接送区分
    if (withType > 33) {
        if (self.commuteAdcode && self.commuteAdcode.length != 0) {
            [manager.requestSerializer setValue:self.commuteAdcode forHTTPHeaderField:@"x-feiniubus-adcode"];
        }
    }
    else {
        if (self.shuttleAdcode && self.shuttleAdcode.length != 0) {
            [manager.requestSerializer setValue:self.shuttleAdcode forHTTPHeaderField:@"x-feiniubus-adcode"];
        }
    }
    
    //打印请求头部
    //DBG_MSG(@"http reqest header: %@", manager.requestSerializer.HTTPRequestHeaders);
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    return manager;
}

-(AFHTTPRequestOperation *) buildHTTPRequestOperation:(NSMutableURLRequest *)request
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //设置token
    if (self.authString) {
         [(NSMutableURLRequest*)operation.request setValue:self.authString forHTTPHeaderField:@"Authorization"];
    }
    
    //打印请求头部
    DBG_MSG(@"http reqest header: %@", request.allHTTPHeaderFields);
    [request setTimeoutInterval:20.f];
    
    return operation;
}

#pragma mark ---

- (void)httpPostRequest:(NSString*)strUrl
                   body:(NSDictionary*)body
                   type:(int)type
           suceeseBlock:(void(^)(NSDictionary *header, NSString*))suceese
            failedBlock:(void(^)(NSError*))failed
{
    //发送请求
    AFHTTPRequestOperationManager *manager = [self buildHttpManager:type];
     AFHTTPRequestOperation *operation = [manager POST:strUrl parameters:body success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = responseObject;
        NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DBG_MSG(@"Http response string: %@", strings);
        if (suceese) {
            suceese(operation.response.allHeaderFields, strings);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DBG_MSG(@"Http reqest error: %@", error);
        
        if (failed) {
            failed(error);
        }
    }];
    
    DBG_MSG(@"http post request url= %@", operation.request.URL);
    DBG_MSG(@"http post request body= %@",body);
}

- (void)httpGetRequest:(NSString*)strUrl
                  body:(NSDictionary*)body
               isHttps:(BOOL)isHttps
                  type:(int)type
          suceeseBlock:(void(^)(NSString* msg))suceese
           failedBlock:(void(^)(NSError* msg))failed
{
    
    
    AFHTTPRequestOperationManager *manager = [self buildHttpManager:type];
//    if (isHttps) {
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//        securityPolicy.allowInvalidCertificates = YES;
//        manager.securityPolicy = securityPolicy;
//    }

    AFHTTPRequestOperation *operation = [manager GET:strUrl parameters:body success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = responseObject;
        NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DBG_MSG(@"Http response string: %@", strings);
        
        if (suceese) {
            suceese(strings);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DBG_MSG(@"Http reqest error: %@", error);
        
        if (failed) {
            failed(error);
        }
        
    }];

    DBG_MSG(@"http get request url= %@",operation.request.URL);
    DBG_MSG(@"http get request body= %@",body);
}


- (void)httpPostFormRequest:(NSString*)strUrl
                          body:(NSDictionary*)body
                       isHttps:(BOOL)isHttps
                       type:(int)type
                  suceeseBlock:(void(^)(NSDictionary *header, NSString* msg))suceese
                   failedBlock:(void(^)(NSError* msg))failed
{
    AFHTTPRequestOperationManager *manager = [self buildHttpManager:type];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    if (isHttps) {
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//        securityPolicy.allowInvalidCertificates = YES;
//        manager.securityPolicy = securityPolicy;
//    }
    
    AFHTTPRequestOperation *operation = [manager POST:strUrl parameters:body success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = responseObject;
        NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DBG_MSG(@"Http response string: %@", strings);
        
        if (suceese) {
            suceese(operation.response.allHeaderFields, strings);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DBG_MSG(@"Http reqest error: %@", error);
        
        if (failed) {
            failed(error);
        }
    }];

    
//    AFHTTPRequestOperation *operation = [manager POST:strUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        
//        //填写表单内容
//        for (NSString *key in body) {
//            NSString *data = body[key];
//            [formData appendPartWithFormData:[data dataUsingEncoding:NSUTF8StringEncoding] name:key];
//        }
//        
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSData *data = responseObject;
//        NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        DBG_MSG(@"Http response string: %@", strings);
//        
//        if (suceese) {
//            suceese(strings);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DBG_MSG(@"Http reqest error: %@", error);
//        
//        if (failed) {
//            failed(error);
//        }
//    }];
    
    DBG_MSG(@"http get request url= %@",operation.request.URL);
    DBG_MSG(@"http get request body= %@",body);

    
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"GET"
//                                                                                              URLString:strUrl
//                                                                                             parameters:body
//                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
//                                    {
//                                        //填写表单内容
//                                        for (NSString *key in body) {
//                                            NSString *data = body[key];
//                                            [formData appendPartWithFormData:[data dataUsingEncoding:NSUTF8StringEncoding] name:key];
//                                        }
//                                    }];

//    AFHTTPRequestOperation *operation =  [self buildHTTPRequestOperation:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSData *data = responseObject;
//        NSString *strings = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        DBG_MSG(@"Success: %@", strings);
//        if (suceese) {
//            suceese(strings);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DBG_MSG(@"Error: %@", error);
//        if (failed) {
//            failed(error);
//        }
//    }];
//    [operation start];
}

- (BOOL)httpGetRequestSynchronized:(NSString*)strUrl
                              body:(NSDictionary*)body
                          delegate:(id<NetInterfaceDelegate>)delegate {
    DBG_MSG(@"lcc http get request url=%@",strUrl);
    DBG_MSG(@"lcc http get request body=%@",body);
    AFHTTPRequestOperationManager *manager = [self buildHttpManager:-1];
    AFJSONRequestSerializer *requestSerializer = (AFJSONRequestSerializer *)manager.requestSerializer;

    NSMutableURLRequest *request = [requestSerializer requestWithMethod: @"GET" URLString:strUrl parameters: body error:nil];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    @try {
        [requestOperation setResponseSerializer: responseSerializer];
        [requestOperation start];
        [requestOperation waitUntilFinished];
    } @catch(NSException *ex) {
        if(delegate) {
            return [delegate httpRequestFailure: ex.reason];
        }
        return NO;
    }
    NSData *data = [requestOperation responseObject];
    NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSDictionary *dict = [JsonBaseBuilder dictionaryWithJson:strings decode:NO key:nil];
//    if (dict) {
//        if ([dict objectForKey:@"code"] &&
//            ([[dict objectForKey:@"code"] intValue] == 100002 ||
//             [[dict objectForKey:@"code"] intValue] == 100001))         //后台鉴权失败
//        {
//            if(delegate) {
//                return [delegate httpRequestFailure: @"后台鉴权失败"];
//            }
//            return NO;
//        }   else {
//            if(delegate) {
//                return [delegate httpRequestSeccess: dict];
//            }
//        }
//    }   else {
//        if(delegate) {
//            return [delegate httpRequestFailure: @"后台鉴权失败"];
//        }
//        return NO;
//    }
    return YES;
}

/**
 *  发送http put请求
 *
 *  @param strUrl  url
 *  @param strBody 发送内容
 *  @param suceese 成功回调
 *  @param failed  失败回调
 */
- (void)httpPutRequest:(NSString*)strUrl
                  body:(NSDictionary*)body
          suceeseBlock:(void(^)(NSString* msg))suceese
           failedBlock:(void(^)(NSError* msg))failed
{
    
    
    
    AFHTTPRequestOperationManager *manager = [self buildHttpManager:-1];
    AFHTTPRequestOperation *operation = [manager PUT:strUrl parameters:body success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = responseObject;
        NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DBG_MSG(@"Http response string: %@", strings);
        
        if (suceese) {
            suceese(strings);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DBG_MSG(@"Http reqest error: %@", error);
        
        if (failed) {
            failed(error);
        }
        
    }];
    
    DBG_MSG(@"http put request url= %@",operation.request.URL);
    DBG_MSG(@"http put request body= %@",body);
}

- (void)httpDeleteRequest:(NSString *)strUrl
                     body:(NSDictionary*)body
             suceeseBlock:(void (^)(NSString *))suceese
              failedBlock:(void (^)(NSError *))failed{
    
    
    
    AFHTTPRequestOperationManager *manager = [self buildHttpManager:-1];
    AFHTTPRequestOperation *operation = [manager DELETE:strUrl parameters:body success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = responseObject;
        NSString *strings =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DBG_MSG(@"Http response string: %@", strings);
        
        if (suceese) {
            suceese(strings);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DBG_MSG(@"Http reqest error: %@", error);
        
        if (failed) {
            failed(error);
        }
    }];
    
    DBG_MSG(@"http delete request url= %@",operation.request.URL);
    DBG_MSG(@"http delete request body= %@",body);
}

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
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:strUrl
                                                                                             parameters:body
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(img, 0.5) name:@"file" fileName:@"image1.jpg" mimeType:@"image/jpeg"];
    }];

    
    AFHTTPRequestOperation *operation =  [self buildHTTPRequestOperation:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = responseObject;
        NSString *strings = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        DBG_MSG(@"Success: %@", strings);
        if (suceese) {
            suceese(strings);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DBG_MSG(@"Error: %@", error);
        if (failed) {
            failed(error);
        }
    }];
    [operation start];
}

@end
