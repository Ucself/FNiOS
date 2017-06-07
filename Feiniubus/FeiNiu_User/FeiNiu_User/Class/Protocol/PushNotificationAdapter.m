//
//  PushNotificationAdapter.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "PushNotificationAdapter.h"

NSString *kNotification_APNS = @"kNotification_APNS";

NSString *kProccessType = @"processType";

NSString *kAPNSItemDate = @"APNSItemDate";
NSString *kAPNSItemMessage = @"APNSItemMessage";
NSString *kAPNSItemIsRead = @"APNSItemIsRead";

@implementation PushNotificationAdapter
+ (NSString *)apnsListFilePath{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [document stringByAppendingPathComponent:@"APNSList.plist"];
}

+ (void)addAPNSMessage:(NSDictionary *)message{
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[self apnsListFilePath]];
    if (!array) {
        array = [NSMutableArray array];
    }
    NSDictionary *aps = message[@"aps"];
    if (aps) {
        NSDictionary *dic = @{kAPNSItemDate:[[NSDate date] timeStringByDefault], kAPNSItemMessage:[NSString stringWithFormat:@"%@", aps[@"alert"]], kAPNSItemIsRead:@NO};
        [array insertObject:dic atIndex:0];
        [array writeToFile:[self apnsListFilePath] atomically:YES];
    }
    
}
+ (void)readAll{
    NSArray *array = [NSArray arrayWithContentsOfFile:[self apnsListFilePath]];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setObject:@YES forKey:kAPNSItemIsRead];
    }];
    [array writeToFile:[self apnsListFilePath] atomically:YES];
}
+ (BOOL)hasNewMessage{
    NSArray *array = [NSArray arrayWithContentsOfFile:[self apnsListFilePath]];
    return [[array firstObject][kAPNSItemIsRead] boolValue];
}
+ (NSArray *)getAPNSList{
    NSArray *array = [NSArray arrayWithContentsOfFile:[self apnsListFilePath]];
    return array;
}

+ (void)clearAPNSList{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager removeItemAtPath:[self apnsListFilePath] error:nil];
}
@end
