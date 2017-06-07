//
//  CarOwnerCompanySourceModel.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/4.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNCommon/pinyin.h>

@interface CarOwnerCompanySourceModel : NSObject

@property(strong,nonatomic)NSMutableDictionary *returnDic;


-(instancetype)initWithData:(NSMutableArray*)array;
@end
