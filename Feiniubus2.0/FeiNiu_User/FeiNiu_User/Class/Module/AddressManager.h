//
//  AddressManager.h
//  FeiNiu_User
//
//  Created by CYJ on 16/4/12.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChooseStationObj.h"

@interface AddressManager : NSObject

+ (instancetype)sharedInstance;

/**
 * @breif 通过type取站点
 */
- (NSArray *)addressForType:(NSInteger) type;

/**
 * @breif 获取默认第一个 站点
 */
- (ChooseStationObj *)defaultChooseAddressForType:(NSInteger) type;



@property (nonatomic, strong) NSArray *allAddressArray;     //未分类站点
@property (nonatomic, strong) NSArray *busAddressArray;     //汽车站
@property (nonatomic, strong) NSArray *airAddressArray;     //机场
@property (nonatomic, strong) NSArray *trainAddressArray;   //火车站

@end
