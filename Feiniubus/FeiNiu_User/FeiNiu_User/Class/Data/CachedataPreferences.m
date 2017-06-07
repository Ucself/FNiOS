//
//  CachedataPreferences.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/12/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CachedataPreferences.h"
#import <FNCommon/FileManager.h>

@implementation CachedataPreferences

+(CachedataPreferences*)sharedInstance
{
    static CachedataPreferences *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    if ( !self )
        return nil;
    NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:@"CachedataPreferences.plist"];
    _preDict = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    if (_preDict == nil)
    {
        _preDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:@"CachedataPreferences.plist"];
        
        if (![NSKeyedArchiver archiveRootObject:_preDict toFile:fullPath]) {
            DBG_MSG(@"wirte file 'CachedataPreferences.plist' failed!");
        }
    });
}

//缓存历史目的地
-(void)setHistoryDestination:(NSMutableArray*)infor
{
    [self.preDict  setValue:infor forKey:@"HistoryDestination"];
    [self save];
}

-(NSMutableArray*)getHistoryDestination
{
    return [self.preDict objectForKey:@"HistoryDestination"];
}

//缓存首页的bannar 的数据
-(void)setBannerInfor:(NSMutableArray*)infor
{
    [self.preDict  setValue:infor forKey:@"BannerInfor"];
    [self save];
}
-(NSMutableArray*)getBannerInfor
{
    return [self.preDict objectForKey:@"BannerInfor"];
}

@end
