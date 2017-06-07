//
//  FNLocation.h
//  FNMap
//
//  Created by 易达飞牛 on 15/8/14.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FNLocation : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *adCode;
@end
