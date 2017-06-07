//
//  FeedbackViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

typedef NS_ENUM(int, FeedbackType)
{
    FeedbackType_Complain = 0,    //投诉
    FeedbackType_Suggest          //建议
};

@interface FeedbackViewController : UserBaseUIViewController


@property (nonatomic, assign) int feedType;
@property (strong, nonatomic) IBOutlet UIButton *telephoneButton;

@end
