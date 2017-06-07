//
//  UINavigationController+StackManage.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (StackManage)

- (void)popToViewControllerByClass:(NSString *)classString animated:(BOOL)animated;
- (void)popToViewControllerByClass:(NSString *)classString animated:(BOOL)animated isNeedToRootWhenClassNotFound:(BOOL)flag;
@end
