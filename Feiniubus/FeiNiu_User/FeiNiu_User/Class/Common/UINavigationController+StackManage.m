//
//  UINavigationController+StackManage.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UINavigationController+StackManage.h"

@implementation UINavigationController (StackManage)
- (void)popToViewControllerByClass:(NSString *)classString animated:(BOOL)animated{
    [self popToViewControllerByClass:classString animated:animated isNeedToRootWhenClassNotFound:NO];
}

- (void)popToViewControllerByClass:(NSString *)classString animated:(BOOL)animated isNeedToRootWhenClassNotFound:(BOOL)flag{
    NSArray *array = self.viewControllers;
    UIViewController *popToViewController;
    for (UIViewController *vc in array) {
        if ([vc isKindOfClass:NSClassFromString(classString)]) {
            popToViewController = vc;
            break;
        }
    }
    if (popToViewController) {
        [self popToViewController:popToViewController animated:animated];
    }else{
        if (flag) {
            [self popToRootViewControllerAnimated:animated];
        }
    }
}
@end
