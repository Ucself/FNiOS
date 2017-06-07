//
//  UINameView.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINameView : UIView

+ (instancetype)sharedInstance;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@end
