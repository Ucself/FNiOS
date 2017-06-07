//
//  ConfigInfo.h
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
//  系统环境参数类

#import <Foundation/Foundation.h>

@interface EnvPreferences : NSObject
{
    
}
@property (nonatomic, strong) NSMutableDictionary  *preDict;

-(void)save;

+(EnvPreferences*)sharedInstance;

@end
