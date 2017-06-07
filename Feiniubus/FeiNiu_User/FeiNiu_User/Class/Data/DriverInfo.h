//
//  DriverInfo.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/26.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverInfo : NSObject

@property (nonatomic, assign) int status;//1.呼叫中，2.接客中,3.已扫描二维码
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *plateNumber;


+ (instancetype)sharedInstance;

@end
