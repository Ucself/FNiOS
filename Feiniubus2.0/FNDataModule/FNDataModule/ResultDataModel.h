//
//  ResultDataModel.h
//  XinRanApp
//
//  Created by tianbo on 14-12-9.
//  Copyright (c) 2014年 feiniu. All rights reserved.
//
// 返回数据类

#import <Foundation/Foundation.h>

@interface ResultDataModel : NSObject

@property (nonatomic, assign) int type;
//结果码
@property (nonatomic, assign) int code;
//描述信息∫
@property (nonatomic,copy) NSString *message;
//返回业务数据
@property (nonatomic, strong) id data;
//返回header
@property (nonatomic, strong) NSDictionary *header;

//  code取出来 然后data里面返回整个数据包


//初始化方法
-(id)initWithDictionary:(NSDictionary*)dict reqType:(int)reqestType;
-(id)initWithDictionary:(NSDictionary *)dict header:(NSDictionary *)header reqType:(int)reqestType;

-(id)initWithErrorInfo:(NSError*)error reqType:(int)reqestType;

//将返回的字典数据转化为相应的类
-(void)parseData:(NSDictionary*)dict;
@end
