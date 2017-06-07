//
//  CustomVersionView.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/14.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomVersionView : UIView

@property (nonatomic, strong) UIView *parentView;

@property (strong, nonatomic) IBOutlet UILabel *versionNum;
@property (strong, nonatomic) IBOutlet UILabel *versionCubage;
@property (strong, nonatomic) IBOutlet UILabel *versionContent;


+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;

@end
