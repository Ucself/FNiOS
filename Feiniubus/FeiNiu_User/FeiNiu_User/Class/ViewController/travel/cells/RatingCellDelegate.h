//
//  RatingCellDelegate.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/29.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//
#import <UIKit/UIKit.h>


@protocol RatingCellDelegate <NSObject>

-(void)tableViewCell:(UITableViewCell*)cell newRating:(float)newRating;

@end