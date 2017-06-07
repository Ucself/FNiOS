//
//  ResultDataModel.m
//  XinRanApp
//
//  Created by tianbo on 14-12-9.
//  Copyright (c) 2014年 feiniu. All rights reserved.
//

#import "ResultDataModel.h"
#import <FNCommon/Constants.h>
#import <FNDataModule/NSObject+MJKeyValue.h>

@implementation ResultDataModel

-(void)dealloc
{
    self.message = nil;
    self.data = nil;
}

-(id)initWithDictionary:(NSDictionary *)dict reqType:(int)reqestType
{
    self = [super init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }

    if (self) {
        self.data = dict;
        self.requestType = reqestType;
        
        int resultCode = [dict[@"code"] intValue];
        self.resultCode = resultCode;
        
        if (resultCode == 999999) {
            //系统异常
            NSString *msg = [dict objectForKey:@"msg"];
            self.message = msg ? msg : @"系统异常";
        }
        else if (resultCode >= 0 && resultCode < 10000) {
            self.message = @"请求成功";
        }
        else {
            NSString *msg = [dict objectForKey:@"message"];
            self.message = msg ? msg : @"亲，数据获取失败，请重试!";
        }
    }
    
    return self;
}

-(id)initWithErrorInfo:(NSError*)error reqType:(int)reqestType
{
    self = [super init];
    if (self) {
        self.requestType = reqestType;
        self.resultCode = (int)error.code;
        DBG_MSG(@"http request error code: (%d)", self.resultCode);
        
        switch (self.resultCode) {
            case NSURLErrorNotConnectedToInternet:
                self.message = @"亲，你的网络不给力，请检查网络!";
                break;
            default:
                self.message = @"亲，数据 获取失败，请重试!";
                break;
        }
        self.data = nil;
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
