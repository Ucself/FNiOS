//
//  ComTempCache.m
//  FeiNiu_User
//
//  Created by tianbo on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ComTempCache.h"

@interface ComTempCache ()

@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation ComTempCache

+(ComTempCache*)sharedInstance
{
    static ComTempCache *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        self.dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(void)setObject:(id)obj forKey:(NSString*)key
{
    ComTempCache *cache = [ComTempCache sharedInstance];
    [cache.dict setObject:obj forKey:key];
}
+(id)getObjectWithKey:(NSString*)key
{
    ComTempCache *cache = [ComTempCache sharedInstance];
    return [cache.dict objectForKey:key];
}
+(void)removeObjectWithKey:(NSString*)key
{
    ComTempCache *cache = [ComTempCache sharedInstance];
    [cache.dict removeObjectForKey:key];
}
@end
