//
//  ApplyRouteViewController.h
//  FeiNiu_User
//
//  Created by CYJ on 16/5/26.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"

#import <MAMapKit/MAMapKit.h>

@interface ApplyScheduledViewController : UserBaseUIViewController


@property (nonatomic, copy) NSString *homeAddr;
@property (nonatomic, copy) NSString *componyAddr;
@property (nonatomic, assign) CLLocationCoordinate2D homeCoorinate;
@property (nonatomic, assign) CLLocationCoordinate2D componyCoorinate;
@end
