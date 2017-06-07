//
//  ComTempCache.h
//  FeiNiu_User
//
//  Created by tianbo on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//
//  数据临时缓存

//联系人
#define KeyContactList    @"KeyContactList"
//城市列表
#define KeyCityList       @"KeyCityList"
//城市对应航站车站列表
#define KeyStationInfo    @"KeyStationInfo"

@interface ComTempCache : NSObject

+(void)setObject:(id)obj forKey:(NSString*)key;
+(id)getObjectWithKey:(NSString*)key;
+(void)removeObjectWithKey:(NSString*)key;
@end
