//
//  UserBaseUIViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/1.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "LoginViewController.h"
#import <FNNetInterface/FNNetInterface.h>
#import "UIColor+Hex.h"
#import "PushNotificationAdapter.h"
#import "LoadingViewController.h"
#import "UserCustomAlertView.h"

NSInteger alertPhoneTag = 0x1003;

@interface UserBaseUIViewController ()<UserCustomAlertViewDelegate>

@end
@implementation UserBaseUIViewController
+ (instancetype)instanceFromStoryboard{
    return [self new];
}

- (void)takeAPhoneCallTo:(NSString *)phone{
    
    UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否要拨打客服热线：%@", phone] delegate:self buttons:@[@"确定", @"取消"]];
    alert.delegate = self;
    @try {
        alert.userInfo = @{@"tag":@(alertPhoneTag), @"phone":phone};
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [alert showInView:[UIApplication sharedApplication].keyWindow];
    
}
- (void)takeAPhoneCallTo:(NSString *)phone alertMessage:(NSString *)message{
    UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"温馨提示" message:message delegate:self buttons:@[@"确定", @"取消"]];
    alert.delegate = self;
    @try {
        alert.userInfo = @{@"tag":@(alertPhoneTag), @"phone":phone};
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [alert showInView:[UIApplication sharedApplication].keyWindow];

}

- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (alertView.userInfo && [alertView.userInfo isKindOfClass:[NSDictionary class]]) {
        if ([alertView.userInfo[@"tag"] integerValue] == alertPhoneTag && btnIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.userInfo[@"phone"]]]];
        }
    }
    
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor  = [UIColor colorWithHex:0xF2F2F2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationResume:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification:) name:kNotification_APNS object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_APNS object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark -
- (void) startWaitWithMessage:(NSString *)message{
    [self stopWait];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.detailsLabelText = message;
}
- (void)startWait{
    [LoadingViewController showInWindow];
//    [LoadingViewController showInViewController:self];
}
- (void)stopWait{
    [LoadingViewController hideLoadingViewInWindow];
//    [LoadingViewController hideLoadingViewInViewController:self];
}
- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type{
    [self showTip:tipMsg WithType:type hideDelay:1.5];
}
- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type hideDelay:(NSTimeInterval)delay{
    if (type == FNTipTypeNone) {
        [super showTipsView:tipMsg];
    }else{
        [MBProgressHUD showTip:tipMsg WithType:type withDelay:delay];
    }
}

- (void)handlePushNotification:(NSNotification *)notification{
    [self pushNotificationArrived:notification.object];
}

- (void)handleApplicationResume:(NSNotification *)notification{
    
}

#pragma mark -
- (void)loginActionCanceled{
    
}
- (void)pushNotificationArrived:(NSDictionary *)userInfo{
    
}
- (void)applicationDidResume{
    
}

/**
 *  @author Nick
 *
 *  鉴权失败统一处理
 *
 *  @param notification
 */
- (void)httpRequestFailed:(NSNotification *)notification{
    [self stopWait];

    NSDictionary *dict = notification.object;
    
    NSError *error = [dict objectForKey:@"error"];
    int type = [[dict objectForKey:@"type"] intValue];
    
    DBG_MSG(@"httpRequestFailed: error = %@", error);
    
    if (error.code == 401 || error.code == 403) {
//        [self showTipsView:@"鉴权失效，请登录！"];
        
        __block BOOL needToHome = NO;
        if (dict[NeedToHomeKey]) {
            needToHome = [dict[NeedToHomeKey] boolValue];
        }
        [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"TravelHistoryViewController")]) {
                needToHome = YES;
                *stop = YES;
            }
        }];
        
        //鉴权失效重置token
        [[UserPreferences sharedInstance] setToken:nil];
        [[UserPreferences sharedInstance] setUserId:nil];
        
        // 进入登录界面
        UIViewController *root = [self.navigationController.viewControllers firstObject];
        [LoginViewController presentAtViewController:root needBack:YES requestToHomeIfCancel:needToHome completion:^{

        } callBalck:^(BOOL isSuccess, BOOL needToHome) {
            if (!isSuccess) {
                if (needToHome) {
                    [self.navigationController popToRootViewControllerAnimated:NO];

                    if (root.frostedViewController && root.frostedViewController.menuViewController) {
                        @try {
                            [root.frostedViewController hideMenuViewController];
                        }
                        @catch (NSException *exception) {
                            
                        }
                        @finally {
                        }
                        DBG_MSG(@"FrostedViewController Hide.\n---------------------");
                    }
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
            }
        }];
//        [LoginViewController presentAtViewController:self completion:^{
////            [self showTip:@"请登录！" WithType:FNTipTypeFailure];
//        }callBalck:^(BOOL isSuccess) {
//            if (!isSuccess) {
//                __block BOOL needPopToRoot = NO;
//                [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([obj isKindOfClass:NSClassFromString(@"TravelHistoryViewController")]) {
//                        needPopToRoot = YES;
//                        *stop = YES;
//                    }
//                }];
//                if (needPopToRoot) {
//                    [self.navigationController popToRootViewControllerAnimated:YES];
//                }
//            }else{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
//            }
//        }];

        //重置别名
        [[PushConfiguration sharedInstance] resetAlias];
    }
}
@end
