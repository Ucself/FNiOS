//
//  UserBaseUIViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/1.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "PushConfiguration.h"
//#import "LoginViewController.h"
#import <FNNetInterface/FNNetInterface.h>
#import <FNUIView/UIColor+Hex.h>
#import "PushNotificationAdapter.h"

#import "ComTempCache.h"
#import "UserPreferences.h"
#import "LoginViewController.h"
#import <FNUIView/WaitView.h>

NSInteger alertPhoneTag = 0x1003;

@interface UserBaseUIViewController ()

@end
@implementation UserBaseUIViewController
+ (instancetype)instanceFromStoryboard{
    return [self new];
}

- (void)takeAPhoneCallTo:(NSString *)phone{
    
    UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否要拨打客服热线：%@", phone] delegate:self buttons:@[@"取消",@"确定"]];
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
    UserCustomAlertView *alert = [UserCustomAlertView alertViewWithTitle:@"温馨提示" message:message delegate:self buttons:@[ @"取消",@"确定"]];
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
    //    if (alertView.userInfo && [alertView.userInfo isKindOfClass:[NSDictionary class]]) {
    //        if ([alertView.userInfo[@"tag"] integerValue] == alertPhoneTag && btnIndex == 0) {
    //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.userInfo[@"phone"]]]];
    //        }
    //    }
    
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = 200;
    
    self.view.backgroundColor  = UIColor_Background;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationResume:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:KLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification) name:KLogoutNotification object:nil];
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

#pragma mark - UINavigationView delegate goback
-(void)navigationViewBackClick
{
    [self popViewController];
}
-(void)navigationViewRightClick
{
    return;
}

#pragma mark -

- (void) startWaitWithMessage:(NSString *)message{
    [self stopWait];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.detailsLabelText = message;
}
- (void)startWait{
    //[[WaitView sharedInstance] start];
    [super startWait];
}
- (void)stopWait{
    //[[WaitView sharedInstance] stop];
    [super stopWait];
}
- (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type{
    if (!tipMsg || tipMsg.length == 0) {
        return;
    }
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

-(void)onApplicationBecomeActive
{
    //[self stopWait];
}
- (void)toLoginViewController {
    //进入登录界面
    UIViewController *root = [self.navigationController.viewControllers firstObject];
    [LoginViewController presentAtViewController:root needBack:YES requestToHomeIfCancel:NO completion:^{
        
    } callBalck:^(BOOL isSuccess, BOOL needToHome) {
        if (!isSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (needToHome) {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
                else if (_isLogonAutoBack) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:KLoginSuccessNotification object:nil];
            //[self loginSuccessNotification];
        }
    }];
}

#pragma mark -

-(void)httpRequestFinished:(NSNotification *)notification
{
//    [self stopWait];
}

/**
 *  @author Nick
 *
 *  失败统一处理
 *
 *  @param notification
 */
- (void)httpRequestFailed:(NSNotification *)notification{
    
    [self stopWait];
    
    ResultDataModel *result = notification.object;
    if (result.type == EmRequestType_GetUserInfo)
        return;
    
    if (result && result.message) {
        if ([result.message isKindOfClass:[NSNull class]]) {
            result.message = @"返回信息异常";
        }
        //[self showTipsView:result.message];
        [self showTip:result.message WithType:FNTipTypeFailure];
    }
    
//    if (result.code == EmCode_AuthError) {
//        //鉴权失效重置token
//        [UserPreferInstance setToken:nil];
//        [UserPreferInstance setUserId:nil];
//        
//        //重置别名
//        [[PushConfiguration sharedInstance] resetAlias];
//        
//        //重置联系人
//        [ComTempCache removeObjectWithKey:KeyContactList];
//        
//        
//        //进入登录界面
//        UIViewController *root = [self.navigationController.viewControllers firstObject];
//        [LoginViewController presentAtViewController:root needBack:YES requestToHomeIfCancel:NO completion:^{
//            
//        } callBalck:^(BOOL isSuccess, BOOL needToHome) {
//            if (!isSuccess) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    if (needToHome) {
//                        [self.navigationController popToRootViewControllerAnimated:NO];
//                    }
//                    else if (!_isNotAuthBack) {
//                        [self.navigationController popViewControllerAnimated:YES];
//                    }
//                });
//                
//            }else{
//                [[NSNotificationCenter defaultCenter] postNotificationName:KLoginSuccessNotification object:nil];
//                //[self loginSuccessNotification];
//            }
//        }];
//    }
    
}
-(void)loginSuccessHandler
{
    
}

-(void)logoutHandler
{
    
}

- (void) loginSuccessNotification
{
    [self loginSuccessHandler];
}

-(void) logoutNotification
{
    [self logoutHandler];
}
@end
