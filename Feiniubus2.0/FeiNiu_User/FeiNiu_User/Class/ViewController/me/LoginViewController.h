//
//  LoginViewController.h
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
typedef void (^LoginCallbackBlock)(BOOL isSuccess, BOOL needToHome);

@interface LoginViewController : UserBaseUIViewController


+ (instancetype)presentAtViewController:(UIViewController *)viewController completion:(void (^)(void))completeBlock callBalck:(LoginCallbackBlock)callBack;

+ (instancetype)presentAtViewController:(UIViewController *)viewController needBack:(BOOL)needBack requestToHomeIfCancel:(BOOL)needToHome completion:(void (^)(void))completeBlock callBalck:(LoginCallbackBlock)callBack;
@end
