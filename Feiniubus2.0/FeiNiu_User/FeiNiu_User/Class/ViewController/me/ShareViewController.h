//
//  ShareViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/22.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@interface ShareViewController : UserBaseUIViewController

//通勤车
@property(nonatomic,strong) NSString *commuteId;
@property(nonatomic,strong) UIViewController *controller;

@end
