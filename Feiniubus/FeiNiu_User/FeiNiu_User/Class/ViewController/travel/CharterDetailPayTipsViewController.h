//
//  CharterDetailPayTipsViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/14.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
@class CharterSuborderItem;

@interface CharterDetailPayTipsViewController : UserBaseUIViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottom;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (nonatomic, strong) CharterSuborderItem *suborder;
@end