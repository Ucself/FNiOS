//
//  MapCoordinaterModule.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MapCoordinaterModule : NSObject

+ (instancetype)sharedInstance;

//@property (nonatomic, strong) NSString *ringKey;
//@property (nonatomic, strong) NSString *tianfuKey;
//@property (nonatomic, strong) NSString *airportKey;

//@property (nonatomic, strong) NSArray *ringCoordinateArr;//三环的坐标数组
//@property (nonatomic, strong) NSArray *tianfuCoordinateArr;//天府新区的数组
//@property (nonatomic, strong) NSArray *airportCoordinateArr;//机场的数组

/**
 * @breif 当前定位adCode
 */
//@property (nonatomic, assign) NSInteger adCode;

/**
 * @breif 记录上次选择定位位置
 */
@property (nonatomic, assign) CLLocationCoordinate2D lastLocation;

//后面功能添加 以上未删除防治其他报错 
@property (nonatomic, strong) NSArray *fenceArray;   //围栏数组集合


//是否在围栏中
- (BOOL) isContainsInFenceWithLatitude:(double)latitude longitude:(double)longitude;

@end
