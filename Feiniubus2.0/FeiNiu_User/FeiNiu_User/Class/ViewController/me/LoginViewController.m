//
//  LoginViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import "LoginViewController.h"
#import <FNCommon/BCBaseObject.h>
#import "UserPreferences.h"
#import "PushConfiguration.h"
#import <FNUIView/TimerButton.h>
#import <FNUIView/UIColor+Hex.h>
#import "WebContentViewController.h"
#import "AuthorizeCache.h"
#import "LoginInputView.h"

#import "FeiNiu_User-Swift.h"


@interface LoginViewController ()
@property (nonatomic, assign) BOOL needToHome;
@property (nonatomic, assign) BOOL needBack;
@property (nonatomic, strong) LoginCallbackBlock callBackBlock;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet TimerButton *btnCode;
@property (weak, nonatomic) IBOutlet UITextField *inputPhone;
@property (weak, nonatomic) IBOutlet UITextField *inputPwd;



//@property (nonatomic, strong) TimerButton *btnCode;
@property (nonatomic, strong) UIButton *btnRecive;
@end

@implementation LoginViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Me" bundle:nil];
    LoginViewController *c = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    return c;
}
+ (instancetype)presentAtViewController:(UIViewController *)viewController needBack:(BOOL)needBack requestToHomeIfCancel:(BOOL)needToHome completion:(void (^)(void))completeBlock callBalck:(LoginCallbackBlock)callBack{
    if (!viewController || ![viewController isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    if ([viewController isKindOfClass:[LoginViewController class]]) {
        return nil;
    }
    LoginViewController *logVC = [self instanceFromStoryboard];
    logVC.callBackBlock = callBack;
    logVC.needBack = needBack;
    logVC.needToHome = needToHome;
    
    [logVC stopWait];  //停止前面操作的等待
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:logVC];
    [viewController presentViewController:nav animated:YES completion:completeBlock];
    return logVC;
}
+ (instancetype)presentAtViewController:(UIViewController *)viewController completion:(void (^)(void))completeBlock callBalck:(LoginCallbackBlock)callBack{
    return [self presentAtViewController:viewController needBack:YES requestToHomeIfCancel:NO  completion:completeBlock callBalck:callBack];
}
-(void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    [self.inputPhone becomeFirstResponder];
    
#if DEBUG
    //    self.textPhone.text = @"18681691612";
    //    self.txtCode.text = @"123123";
#endif
}

-(void)initUI
{
    if (!self.needBack) {
        // self.navigationItem.leftBarButtonItem = nil;
        self.btnBack.hidden = YES;
    }
    

    [_btnCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_btnCode setTitleColor:UITextColor_LightGray forState:UIControlStateNormal];
    [_btnCode.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_btnCode setBackgroundColor:UIColor.whiteColor];
    [_btnCode addTarget:self action:@selector(btnCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    _btnCode.layer.cornerRadius = 5;
    
    //btn按钮边框
    _btnLogin.layer.borderWidth = 1;
    _btnLogin.layer.borderColor = UIColorFromRGB(0xFE6E35).CGColor;
    _btnLogin.layer.cornerRadius = 22;
    _btnLogin.layer.masksToBounds = YES;
    
    [self.inputPhone addTarget:self action:@selector(textChangeAction:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (!self.needBack) {
//        [self.navigationController setNavigationBarHidden:YES animated:NO];
//    }else{
//        self.navigationController.navigationBar.translucent= YES;
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.inputPhone resignFirstResponder];
    [self.inputPwd resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue destinationViewController] isKindOfClass:[WebContentViewController class]]) {
        WebContentViewController *webViewController = [segue destinationViewController];
        webViewController.vcTitle = @"用车协议";
        webViewController.urlString = [NSString stringWithFormat:@"%@agreement1.html",KAboutServerAddr];
    }
}

#pragma mark - controls event mothed


//UINavigationView delegate goback
-(void)navigationViewBackClick {
    if (self.callBackBlock) {
        self.callBackBlock(NO, self.needToHome);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)btnAgreeClick:(id)sender {
    // 用户协议
//    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
//    ruleVC.vcTitle = @"用车协议";
//    ruleVC.urlString = [NSString stringWithFormat:@"%@agreement1.html",KAboutServerAddr];
//    //    [self.navigationController pushViewController:ruleVC animated:YES];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:ruleVC];
//    nav.navigationBar.barTintColor = [UIColor colorWithHex:GloabalTintColor];
//    [self presentViewController:nav animated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"toRule" sender:nil];
}


-(IBAction)btnBKClick:(id)sender {
    [self.inputPhone resignFirstResponder];
    [self.inputPwd resignFirstResponder];
}

- (IBAction)btnLoginClick:(id)sender {
    if (![BCBaseObject isFNMobileNumber:_inputPhone.text]) {
        [self showTip:@"请输入正确的手机号码" WithType:FNTipTypeFailure];
        return;
    }
    
    if (_inputPwd.text.length == 0) {
        [self showTip:@"请输入验证码" WithType:FNTipTypeFailure];
        return;
    }
    
    [_inputPhone resignFirstResponder];
    [_inputPwd resignFirstResponder];
    
    [self startWait];
    //登录接口
    [NetManagerInstance sendFormRequstWithType:EmRequestType_Login params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"username":_inputPhone.text,
                        @"phone":_inputPhone.text,
                        @"code":_inputPwd.text,
                        @"grant_type":@"totp",
                        @"client_id":KClient_id,
                        @"registration_id":[[PushConfiguration sharedInstance] getRegistrationID],
                        @"terminal_type":@"Ios",
                        @"terminal":@"PG"};
    }];

//刷新token接口
//    [NetManagerInstance sendHttpsRequstWithType:EmRequestType_HttpsRefreshToken params:^(NetParams *params) {
//        params.method = EMRequstMethod_POST;
//        params.data = @{@"refresh_token":@"b913fe32026c4637babfe504fa550d5d",
//                        @"grant_type":@"refresh_token",
//                        @"client_id":KClient_id,
//                        @"client_secret":KClient_secret};
//    }];
}

- (void)btnCodeClick:(id)sender {
    if (![BCBaseObject isFNMobileNumber:_inputPhone.text]) {
        [self showTip:@"请输入正确的手机号码" WithType:FNTipTypeFailure];
        return;
    }

    [_inputPhone resignFirstResponder];
    [_inputPwd resignFirstResponder];
    
    [self startWait];


    //验证码
    [NetManagerInstance sendRequstWithType:EmRequestType_GetVerifyCode params:^(NetParams *params) {
        params.data = @{@"phone": _inputPhone.text,
                        @"client_id": KClient_id};
    }];
}

- (void)textChangeAction:(id) sender {
    
    UITextField *phoneTextField = (UITextField*)sender;
    
    if ([BCBaseObject isFNMobileNumber:phoneTextField.text]) {
        [self.btnCode setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
    }
    else {
        [self.btnCode setTitleColor:UITextColor_LightGray forState:UIControlStateNormal];
    }
}

#pragma mark - UITextField Delegate
- (void)resignTextFieldFirstResponder:(UITextField *)tf{
    [tf resignFirstResponder];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.view.frame = self.view.bounds ;
//    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[self resignTextFieldFirstResponder:textField];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    CGRect rect = [textField.superview convertRect:textField.frame toView:self.view];
//    CGFloat bottom = CGRectGetMaxY(rect);
//    CGFloat delta = self.view.frame.size.height - bottom - 290;
//    if (delta < 0) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.view.frame = CGRectOffset(self.view.bounds, 0, delta);
//        }];
//    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        //退格键
        return YES;
    }
 
    if (textField == self.inputPhone) {
        if (textField.text.length >= 11)
            return NO;
    }
    else if (textField == self.inputPwd) {
        if (textField.text.length >= 6)
            return NO;
    }
    
    
    return YES;
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *result = (ResultDataModel *)notification.object;
    switch (result.type) {
        case EmRequestType_GetVerifyCode:
        {
            [self showTip:@"验证码已发送" WithType:FNTipTypeSuccess];
            [_btnCode startTimerWithInitialCount:60];
        }
            break;
        case EmRequestType_Login:
        {
            NSString *token = [result.data objectForKey:@"id_token"];
            NSString *refreshToken = [result.data objectForKey:@"refresh_token"];
            NSString *alias = [result.data objectForKey:@"feiniu_alias"];
            NSString *userId = [result.data objectForKey:@"feiniu_user_id"];
            if (token) {
                //存储刷新token//保存token
                [[AuthorizeCache sharedInstance] setAccessToken:token];
                [[AuthorizeCache sharedInstance] setRefreshToken:refreshToken];
                //[[AuthorizeCache sharedInstance] setUserId:userId];
                // 1 为用户角色, 用户端
                [NetManagerInstance setAuthorization:[[NSString alloc] initWithFormat:@"Bearer %@",token]];
                // 注册通知别名
                [[PushConfiguration sharedInstance] setAlias:PassengerAlias userAlias:alias];
            }
            
            //保存用户信息
            User *user = [[User alloc] init];
            user.Id = userId;
            user.phone = self.inputPhone.text;
            [UserPreferInstance setUserInfo:user];
            
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.callBackBlock) {
                    self.callBackBlock(YES, self.needToHome);
                }
            }];
            //[self showTip:@"登录成功" WithType:FNTipTypeSuccess];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
        }
            break;
        default:
            break;
    }
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];

    ResultDataModel *result = notification.object;
    if (result.code  == 400) {
        [self showTip:result.message WithType:FNTipTypeFailure hideDelay:1.5];
    }
    else {
        [super httpRequestFailed:notification];
    }
}

@end
