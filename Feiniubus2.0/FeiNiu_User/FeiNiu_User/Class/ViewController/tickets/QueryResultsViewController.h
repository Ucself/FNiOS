//
//  QueryResultsViewController.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@interface QueryResultsViewController : UserBaseUIViewController

@property (nonatomic,strong) NSDictionary *originData;
@property (nonatomic,strong) NSDictionary *destinationData;
@property (nonatomic,strong) NSDate  *setOutDate;
//开始时间
@property (nonatomic,strong) NSDate  *calenderStartData;
//结束时间
@property (nonatomic,strong) NSDate  *calenderEndDate;

@end
