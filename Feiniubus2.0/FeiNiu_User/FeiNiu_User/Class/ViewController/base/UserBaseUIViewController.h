//
//  UserBaseUIViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/1.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

//#import <FNUIView/FNUIView.h>
#import <FNUIView/BaseUIViewController.h>
#import <FNUIView/MBProgressHUD.h>
#import <FNUIView/UserCustomAlertView.h>
//#import "CommonDefines.h"
#import <FNCommon/Common.h>
#import <FNNetInterface/UIImageView+AFNetworking.h>

#import <FNDataModule/ResultDataModel.h>
#import <FNDataModule/MJExtension.h>

@interface UserBaseUIViewController : BaseUIViewController<UserCustomAlertViewDelegate>

@property (nonatomic, assign) BOOL isLogonAutoBack;

+ (instancetype)instanceFromStoryboard;

- (void)takeAPhoneCallTo:(NSString *)phone;
- (void)takeAPhoneCallTo:(NSString *)phone alertMessage:(NSString *)message;

- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type;
- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type hideDelay:(NSTimeInterval)delay;

//- (void) startWaitWithMessage:(NSString *)message;
-(void)navigationViewBackClick;
-(void)navigationViewRightClick;

- (void)loginActionCanceled;
// 收到推送通知
- (void)pushNotificationArrived:(NSDictionary *)userInfo;
- (void)applicationDidResume;

//登录成功方法
-(void)loginSuccessHandler;
-(void)logoutHandler;
-(void)toLoginViewController;
@end
