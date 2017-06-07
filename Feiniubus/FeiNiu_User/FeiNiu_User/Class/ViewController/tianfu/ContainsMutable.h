//
//  ContainsMutable.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/23.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FNMap/FNLocation.h>
#import <MAMapKit/MAMapKit.h>

@interface ContainsMutable : NSObject

+ (BOOL)isContainsMutableBoundCoords:(CLLocationCoordinate2D*)coords count:(int)count coordinate:(CLLocationCoordinate2D)coordinate;

@end
