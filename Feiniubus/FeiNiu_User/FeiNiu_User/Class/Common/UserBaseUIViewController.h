//
//  UserBaseUIViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/1.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNUIView/FNUIView.h>
#import "MBProgressHUD+User.h"
#import "CommonDefines.h"
#import <FNCommon/Common.h>

@interface UserBaseUIViewController : BaseUIViewController
+ (instancetype)instanceFromStoryboard;

- (void)takeAPhoneCallTo:(NSString *)phone;
- (void)takeAPhoneCallTo:(NSString *)phone alertMessage:(NSString *)message;

- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type;
- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type hideDelay:(NSTimeInterval)delay;

//- (void) startWaitWithMessage:(NSString *)message;

- (void)loginActionCanceled;
// 收到推送通知
- (void)pushNotificationArrived:(NSDictionary *)userInfo;
- (void)applicationDidResume;

@end
