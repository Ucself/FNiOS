//
//  ShuttleStationViewCotroller.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationObj.h"

typedef NS_ENUM(NSUInteger, ShuttleStationType) {
    ShuttleStationTypeBus = 1,      //1 汽车
    ShuttleStationTypeTrain,        //2 火车
    ShuttleStationTypeAirport,      //3 飞机
};

@interface ShuttleStationViewCotroller : UserBaseUIViewController

@property(nonatomic,assign)ShuttleStationType shuttleStation;

@property(nonatomic,retain)LocationObj *defaultLocation;

@end
