//
//  ResultDataModel.m
//  XinRanApp
//
//  Created by tianbo on 14-12-9.
//  Copyright (c) 2014年 feiniu. All rights reserved.
//

#import "ResultDataModel.h"
#import <FNCommon/NetConstants.h>
#import <FNDataModule/NSObject+MJKeyValue.h>
#import <FNCommon/JsonUtils.h>

@implementation ResultDataModel

-(void)dealloc
{
    self.message = nil;
    self.data = nil;
    self.header = nil;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict reqType:(int)reqestType
{
    self = [super init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }

    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            self.code = dict[@"code"] ? [dict[@"code"] intValue] : EmCode_Success;
            self.data = dict[@"data"] ? dict[@"data"] : dict;
            self.message = dict[@"message"];
            self.type = reqestType;
            self.header = dict[@"header"] ? dict[@"header"] : nil;
        }
        else if ([dict isKindOfClass:[NSArray class]]) {
            self.code = EmCode_Success;
            self.data = dict;
            self.message = @"Success";
            self.type = reqestType;
            self.header = nil;
        }
        

//        if (self.code != EmCode_Success) {
//            if (self.code == EmCode_AuthError) {
//                self.message = @"授权失败, 请重新登录";
//            }
////            else {
////                self.message = @"亲，数据获取失败，请重试!";
////            }
//        }
    }
    
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict header:(NSDictionary *)header reqType:(int)reqestType
{
    self = [super init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            self.code = dict[@"code"] ? [dict[@"code"] intValue] : EmCode_Success;
            self.data = dict[@"data"] ? dict[@"data"] : dict;
            self.message = dict[@"message"];
            self.type = reqestType;
            self.header = header;
        }
        else if ([dict isKindOfClass:[NSArray class]]) {
            self.code = EmCode_Success;
            self.data = dict;
            self.message = @"Success";
            self.type = reqestType;
            self.header = header;
        }
    }
    
    return self;
}

-(id)initWithErrorInfo:(NSError*)error reqType:(int)reqestType
{
    self = [super init];
    if (self) {
        self.type = reqestType;
        self.code = error.code;
        DBG_MSG(@"http request error code: (%d)", self.code);
        
        switch (self.code) {
            case NSURLErrorNotConnectedToInternet:
            {
                self.message = @"亲，你的网络不给力，请检查网络!";
            }
                break;
            case NSURLErrorTimedOut:
            {
                self.message = @"亲, 请求超时, 请重试!";
            }
                break;
            case NSURLErrorBadServerResponse:
            {
                self.code = (int)((NSHTTPURLResponse*)[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.response"]).statusCode;
                NSDictionary *errorData = (NSDictionary*)[JsonUtils jsonDataToDcit:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"]];
                if (!errorData) {
                    self.message = @"亲，数据获取失败，请重试!";
                    return self;
                }
                
                if ([errorData isKindOfClass:[NSArray class]]) {
                    NSArray *array = (NSArray*)errorData;
                    self.message = [array[0] isKindOfClass:[NSDictionary class]] ? [array[0] objectForKey:@"error_description"] : @"";
                }
                else {
                    if ([errorData objectForKey:@"error_description"]) {
                        self.message = [errorData objectForKey:@"error_description"];
                    }
                    else if ([errorData objectForKey:@"Message"]) {
                        self.message = [errorData objectForKey:@"Message"];
                    }
                }
                DBG_MSG(@"ERROR INFO: %@", self.message);
            }
                break;
            default:
            {
                self.message = @"亲，数据获取失败，请重试!";
            }
                break;
        }
        
    }
    
    return self;
}

-(NSString*)parseErrorCode:(NSInteger)code
{
    NSString *ret = @"";
    switch (code) {

        case 401:
            ret = @"请求失败";
            break;
            
        default:
            break;
    }
    
    return  ret;
}

//#pragma mark- 解析数据
////将返回的字典数据转化为相应的类
//-(void)parseData:(NSDictionary*)dict
//{
//    switch (self.requestType) {
//        default:
//            break;
//    }
//}
@end
