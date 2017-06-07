//
//  NetParams.h
//  FNNetInterface
//
//  Created by tianbo on 16/1/15.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, EMRequstMethod)
{
    EMRequstMethod_GET = 0,
    EMRequstMethod_POST,
    EMRequstMethod_PUT,
    EMRequstMethod_DELETE,
};

@interface NetParams : NSObject

@property (nonatomic, assign) EMRequstMethod method;    //请求方式, 默认GET
@property (nonatomic, strong) id data;                  //数据

@end
