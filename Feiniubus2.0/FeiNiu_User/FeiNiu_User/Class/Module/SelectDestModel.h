//
//  SelectDestModel.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/12/9.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectDestModel : NSObject

@property(strong,nonatomic)NSMutableDictionary *returnDic;

-(instancetype)initWithData:(NSMutableArray*)array;

@end
