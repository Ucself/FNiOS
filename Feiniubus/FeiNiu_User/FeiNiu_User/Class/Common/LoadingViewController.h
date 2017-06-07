//
//  LoadingViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/30.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingViewController : UIViewController

+ (void)showInWindow;
+ (void)hideLoadingViewInWindow;


+ (void)showInViewController:(UIViewController *)vc;
+ (void)hideLoadingViewInViewController:(UIViewController *)vc;
@end
