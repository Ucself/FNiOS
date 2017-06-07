//
//  MapCoordinaterModule.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapCoordinaterModule : NSObject

+ (instancetype)sharedInstance;

//@property (nonatomic, strong) NSString *ringKey;
//@property (nonatomic, strong) NSString *tianfuKey;
//@property (nonatomic, strong) NSString *airportKey;
//
//@property (nonatomic, strong) NSArray *ringCoordinateArr;//三环的坐标数组
//@property (nonatomic, strong) NSArray *tianfuCoordinateArr;//天府新区的数组
//@property (nonatomic, strong) NSArray *airportCoordinateArr;//机场的数组

//后面功能添加 以上未删除防治其他报错 
@property (nonatomic, strong) NSArray *fenceArray;   //围栏数组集合


@end
