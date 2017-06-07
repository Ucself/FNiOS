//
//  DriverTableViewCell.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/28.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/CPTextViewPlaceholder.h>
#import <FNUIView/RatingBar.h>
#import "RatingCellDelegate.h"

@interface DriverTableViewCell : UITableViewCell <RatingBarDelegate>

@property (assign, nonatomic) id<RatingCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet RatingBar *smallSating;
@property (weak, nonatomic) IBOutlet RatingBar *lagreSating;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *textView;

@end
