//
//  MapCoordinaterModule.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "MapCoordinaterModule.h"
#import <FNCommon/JsonUtils.h>
#import "ContainsMutable.h"

@implementation MapCoordinaterModule

+ (instancetype)sharedInstance{
    
    static MapCoordinaterModule *mapCoordinater = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapCoordinater = [[MapCoordinaterModule alloc] init];
        //mapCoordinater.adCode = 510100;
    });
    
    return mapCoordinater;
}

- (BOOL) isContainsInFenceWithLatitude:(double)latitude longitude:(double)longitude
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    int fenceCount = (int)self.fenceArray.count;
    CLLocationCoordinate2D fenceCoordinates[fenceCount];
    for (int i = 0; i < fenceCount; i++) {
        fenceCoordinates[i].latitude = [(self.fenceArray[i])[@"latitude"] floatValue];
        fenceCoordinates[i].longitude = [(self.fenceArray[i])[@"longitude"] floatValue];
    }
    if ([ContainsMutable isContainsMutableBoundCoords:fenceCoordinates count:fenceCount coordinate:coordinate]) {
        return YES;
    }
    return NO;
}

@end
