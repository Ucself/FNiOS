//
//  ComTempCache.h
//  FeiNiu_User
//
//  Created by tianbo on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//
//  数据临时缓存

#import <Foundation/Foundation.h>

//联系人
#define KeyContactList    @"KeyContactList"

@interface ComTempCache : NSObject

+(void)setObject:(id)obj forKey:(NSString*)key;
+(id)getObjectWithKey:(NSString*)key;
+(void)removeObjectWithKey:(NSString*)key;
@end
