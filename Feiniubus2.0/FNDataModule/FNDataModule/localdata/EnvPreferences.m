//
//  ConfigInfo.m
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import "EnvPreferences.h"
#import <FNCommon/FileManager.h>

@interface EnvPreferences ()
{
    
}
////token
//@property (copy, nonatomic) NSString *token;
////用户id
//@property (copy, nonatomic) NSString *userId;

@end


@implementation EnvPreferences

+(EnvPreferences*)sharedInstance
{
    static EnvPreferences *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(void)save
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSString *fileName = [NSString stringWithFormat:@"%@.plist", [NSString stringWithUTF8String:object_getClassName(strongSelf)]];
        NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:fileName];
        
        
        if (!strongSelf.preDict || !fullPath) {
            return;
        }

        if (![NSKeyedArchiver archiveRootObject:strongSelf.preDict toFile:fullPath]) {
            DBG_MSG(@"wirte file 'EnvPreferences.plist' failed!");
        }
    });
}

-(id)init
{
    self = [super init];
    if ( !self )
        return nil;
    
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", [NSString stringWithUTF8String:object_getClassName(self)]];
    NSString *fullPath = [FileManager fileFullPathAtDocumentsDirectory:fileName];
    _preDict = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    if (_preDict == nil)
    {
        _preDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)dealloc
{
    [self save];
}


#pragma mark--

@end
