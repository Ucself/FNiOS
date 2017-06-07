//
//  AddressManager.m
//  FeiNiu_User
//
//  Created by CYJ on 16/4/12.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AddressManager.h"
#import <FNDataModule/MJExtension.h>

@implementation AddressManager

+ (instancetype)sharedInstance{
    
    static AddressManager *addressManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addressManager = [[AddressManager alloc] init];
    });
    
    return addressManager;
}

- (NSArray *)addressForType:(NSInteger) type
{
    switch (type) {
        case 1:
            return self.busAddressArray;
            break;
        case 2:
            return self.trainAddressArray;
            break;
        case 3:
            return self.airAddressArray;
            break;
            
        default:
            break;
    }
    return nil;
}

- (ChooseStationObj *)defaultChooseAddressForType:(NSInteger) type
{
    switch (type) {
        case 1:
        {
            if (!self.busAddressArray && self.busAddressArray.count == 0) {
                return nil;
            }
            return self.busAddressArray[0];
        }
            break;
        case 2:
        {
            if (!self.trainAddressArray && self.trainAddressArray.count == 0) {
                return nil;
            }
            return self.trainAddressArray[0];
        }
            break;
        case 3:
        {
            if (!self.airAddressArray && self.airAddressArray.count == 0) {
                return nil;
            }
            return self.airAddressArray[0];
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (void)setAllAddressArray:(NSArray *)allAddressArray
{
    _allAddressArray = allAddressArray;
    
    NSMutableArray *bus = @[].mutableCopy;
    NSMutableArray *train = @[].mutableCopy;
    NSMutableArray *air = @[].mutableCopy;
    [allAddressArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseStationObj *station = [ChooseStationObj mj_objectWithKeyValues:obj];
        if (station.type == 1) {
            [bus addObject:station];
        }else if (station.type == 2){
            [train addObject:station];
        }else if (station.type == 3){
            [air addObject:station];
        }
    }];
    
    _busAddressArray = bus;
    _trainAddressArray = train;
    _airAddressArray = air;
}

@end
