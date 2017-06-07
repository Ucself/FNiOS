//
//  UserCustomAlertView.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FNUIView/BaseUIView.h>

@protocol UserCustomAlertViewDelegate ;

@interface UserCustomAlertView : BaseUIView
@property (nonatomic, assign) id<UserCustomAlertViewDelegate> delegate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) BOOL isLongMessage;
@property (nonatomic, assign) BOOL disableDismiss;   //更新提示

@property (nonatomic, strong) id userInfo;

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)msg delegate:(id<UserCustomAlertViewDelegate>)delegate;
+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)msg delegate:(id<UserCustomAlertViewDelegate>)delegate buttons:(NSArray *)buttonsTitle;

- (void)showInView:(UIView *)view;
- (void)hide:(BOOL)animated;

@end

@protocol UserCustomAlertViewDelegate <NSObject>

@optional
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex;

@end
