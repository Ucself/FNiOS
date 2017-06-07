//
//  CityInitializeLogic.h
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserBaseUIViewController.h"

@interface CityInitializeLogic : NSObject

@property(nonatomic,strong) UserBaseUIViewController *controller;
@property(nonatomic, copy)  void(^done)(BOOL success);

+(CityInitializeLogic*)sharedInstance;

//-(void)initWithController:(UserBaseUIViewController*)controller doneBlock:(void(^)(BOOL success))block;


-(void)initCityInfo;
-(void)initStationInfoWithAdcode:(NSString*)adcode;

@end
