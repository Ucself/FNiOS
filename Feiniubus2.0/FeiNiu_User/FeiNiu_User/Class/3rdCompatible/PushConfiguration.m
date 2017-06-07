//
//  PushConfiguration.m
//  FNNetInterface
//
//  Created by 易达飞牛 on 15/9/16.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "PushConfiguration.h"
//#import "APService.h"
#import "JPUSHService.h"
#import <UIKit/UIDevice.h>

@interface PushConfiguration ()
{
    
    //最后一次的标签
    NSString *lastTimeTag;
    //最后一次的别名
    NSString *lastTimeAlias;
    //最后一次userID
    NSString *lastUserId;
    
}
@end

@implementation PushConfiguration

#pragma mark --- 通知注册对外公布事件
//实例化
+ (PushConfiguration*)sharedInstance
{
    static PushConfiguration *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}
//设置标签
-(void)setTag:(NSString*)tag
{
    __autoreleasing NSMutableSet *tags = [NSMutableSet set];
    [self setTags:&tags addTag:tag];
    //记录一次
    lastTimeTag = tag;
    [JPUSHService setTags:tags callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}
//设置别名
-(void)setAlias:(NSString*)alias userId:(NSString*)userId
{
    NSString *aliasString = [[NSString alloc] initWithFormat:@"%@%@%@",userId,alias ? alias : @"",[self getRegistrationID]];
    //记录一次
    lastTimeAlias = aliasString;
    lastUserId = userId;
    [JPUSHService setAlias:aliasString callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}

-(void)setAlias:(NSString*)alias userAlias:(NSString*)userAlias
{
    //记录一次
    lastTimeAlias = userAlias;
    [JPUSHService setAlias:userAlias callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}

//设置标签和别名
-(void)setTagAndAlias:(NSString*)tag alias:(NSString*)alias userId:(NSString*)userId
{
    __autoreleasing NSMutableSet *tags = [NSMutableSet set];
    [self setTags:&tags addTag:tag];
    NSString *aliasString = [[NSString alloc] initWithFormat:@"%@%@%@",userId,alias ? alias : @"",[self getRegistrationID]];
    //记录一次
    lastTimeAlias = aliasString;
    lastTimeTag = tag;
    lastUserId = userId;
    [JPUSHService setTags:tags alias:aliasString callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}
//清除标签
-(void)resetTag
{
    //记录一次
    lastTimeTag = @"";
    [JPUSHService setTags:[NSSet new] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}
//清除别名
-(void)resetAlias
{
    //记录一次
    lastTimeAlias = @"";
    [JPUSHService setAlias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}
//清除标签和别名
-(void)resetTagAndAlias
{
    //记录一次
    lastTimeTag = @"";
    lastTimeAlias = @"";
    [JPUSHService setTags:[NSSet new] alias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}

//获取激光注册的设备注册id
-(NSString*)getRegistrationID
{
    //使用设备ID替换RegistrationID
    NSString *registrationID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //删除-
    registrationID = [registrationID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //截取前15个字符串使用
    registrationID = [registrationID substringToIndex:15];
    
    return registrationID;
//    if (registrationID && ![registrationID isEqualToString:@""]) {
//        return [APService registrationID];
//    }
//    else
//    {
//        return @"dsimulatorRegistrationID";
//    }
}

/**
 *  set setBadge
 *  @param value 设置JPush服务器的badge的值
 *  本地仍须调用UIApplication:setApplicationIconBadgeNumber函数,来设置脚标
 */
- (BOOL)setBadge:(NSInteger)value
{
    return [JPUSHService setBadge:value];
}


#pragma mark -----
//设置集合
-(void)setTags:(NSMutableSet **)tags addTag:(NSString *)tag {
    //如果为空或者未传入的对象，不做处理
    if (!tag || [tag isEqualToString:@""]) {
        return;
    }
    [*tags addObject:tag];
}
//设置回调
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet*)tags
                    alias:(NSString*)alias
{
    NSLog(@"\n iResCode:＝＝＝%d \n tags:＝＝＝%@ \n alias:＝＝＝%@ \n registrationID:= = =%@\n ",iResCode,tags,alias,[self getRegistrationID]);
    //如果注册失败等待一段时间再执行
    if (iResCode !=0) {
        [self performSelector:@selector(setTagAndAlias) withObject:nil afterDelay:10];
    }
    else {
        NSLog(@"推送注册成功!");
    }
}

//注册失败的时候重新发送
-(void)setTagAndAlias
{
    __autoreleasing NSMutableSet *tags = [NSMutableSet set];
    [self setTags:&tags addTag:lastTimeTag];
    [JPUSHService setTags:tags alias:lastTimeAlias callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
}

@end
