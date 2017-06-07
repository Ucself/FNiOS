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
#import <FNNetInterface/PushConfiguration.h>
#import "CountDownButton.h"
#import "UIColor+Hex.h"
#import "RuleViewController.h"

@interface LoginViewController ()
@property (nonatomic, assign) BOOL needToHome;
@property (nonatomic, assign) BOOL needBack;

@property (nonatomic, strong) LoginCallbackBlock callBackBlock;
@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UITextField *textPhone;
@property(nonatomic, strong) UITextField *textCode;
@property (nonatomic, strong) CountDownButton *btnCode;
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
    [self setupNavigationBar];
    // add by nick
#if DEBUG
    //    self.textPhone.text = @"18681691612";
    //    self.textCode.text = @"123123";
#endif
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.needBack) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }else{
        self.navigationController.navigationBar.translucent= YES;
    }
}
-(void)initUI
{
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbktrans"] forBarMetrics:UIBarMetricsDefault];
    //    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnBK = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBK addTarget:self action:@selector(btnBKClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBK];
    
    [btnBK makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _contentView = [UIView new];
    _contentView.clipsToBounds = YES;
    _contentView.layer.cornerRadius = 3;
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.borderWidth = 0.6;
    _contentView.layer.borderColor = [UIColorFromRGB(0xcdcdcd) CGColor];
    [self.view addSubview:_contentView];
    
    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(190);
        make.height.equalTo(150);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-20);
    }];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone_icon"]];
    [_contentView addSubview:imgView];
    [imgView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(15);
        make.left.equalTo(13);
        make.width.equalTo(22);
        make.height.equalTo(22);
    }];
    
    _textPhone = [UITextField new];
    _textPhone.font = [UIFont systemFontOfSize:15];
    _textPhone.borderStyle = UITextBorderStyleNone;
    _textPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textPhone.placeholder = @"请输入手机号码";
    _textPhone.keyboardType = UIKeyboardTypeNumberPad;
    _textPhone.delegate = self;
    [_contentView addSubview:_textPhone];
    
    [_textPhone makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.right).offset(20);
        make.right.equalTo(_contentView.right).offset(-5);
        make.centerY.equalTo(imgView);
        make.height.equalTo(30);
        
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xcdcdcd);
    [_contentView addSubview:line];
    
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.height.equalTo(0.6);
        make.top.equalTo(50);
    }];
    
    
    // 验证码图标
    imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"code_icon"]];
    [_contentView addSubview:imgView];
    [imgView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.bottom).offset(15);
        make.left.equalTo(13);
        make.width.equalTo(22);
        make.height.equalTo(22);
    }];
    
    // 验证码输入框
    _textCode = [UITextField new];
    _textCode.font = [UIFont systemFontOfSize:15];
    _textCode.borderStyle = UITextBorderStyleNone;
    _textCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textCode.placeholder = @"请输入验证码";
    _textCode.keyboardType = UIKeyboardTypeNumberPad;
    _textCode.delegate = self;
    [_contentView addSubview:_textCode];
    
    
    //验证码分割线
    line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xcdcdcd);
    [_contentView addSubview:line];
    
    // 验证码按钮
    _btnCode = [CountDownButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    _btnCode.tintColor = UIColorFromRGB(GloabalTintColor);
    [_btnCode addTarget:self action:@selector(btnCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnCode];
    
    // 验证码布局
    [_btnCode makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView);
        make.right.equalTo(_contentView.right).offset(-15);
        make.width.equalTo(120);
        make.height.equalTo(30);
    }];
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView);
        make.right.equalTo(_btnCode.left);
        make.width.equalTo(1);
        make.height.equalTo(30);
    }];
    [_textCode makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.right).offset(20);
        make.right.equalTo(line.left);
        make.centerY.equalTo(imgView);
        make.height.equalTo(30);
    }];
    //
    //    [btnCode makeConstraints:^(MASConstraintMaker *make) {
    
    //    }];
    //
    //    line.backgroundColor = UIColorFromRGB(0xcdcdcd);
    //    [_contentView addSubview:line];
    //
    //    [line makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(btnCode.left).offset(-15);
    //        make.width.equalTo(0.6);
    //        make.height.equalTo(30);
    //        make.centerY.equalTo(btnCode);
    //    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btn setBackgroundColor:UIColorFromRGB(GloabalTintColor)];
    [btn addTarget:self action:@selector(btnLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btn];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.bottom.equalTo(_contentView);
        make.height.equalTo(50);
    }];
    
    //用户协议
    UILabel *label = [UILabel new];
    label.text = @"点击\"登录\"即表示同意";
    label.font = [UIFont systemFontOfSize:13];
    //label.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:label];
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.top.equalTo(_contentView.bottom).offset(15);
        make.height.equalTo(15);
        make.width.equalTo(130);
    }];
    
    UIButton *btnAgree = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnAgree setTitle:@"《飞牛巴士使用协议》" forState:UIControlStateNormal];
    btnAgree.tintColor = UIColorFromRGB(GloabalTintColor);
    btnAgree.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnAgree addTarget:self action:@selector(actionAgreeProtocol:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAgree];
    
    [btnAgree makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(label);
        make.left.equalTo(label.right);
        make.height.equalTo(30);
        make.width.equalTo(170);
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - PrivateMethods
- (void)setupNavigationBar {
    
    //[self.navigationController.navigationBar setBarTintColor:UIColor_DefGreen];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:GloabalTintColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //    self.navigationController.navigationBar.clipsToBounds = YES;
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbkgreen"] forBarMetrics:UIBarMetricsDefault];
    
    if (!self.needBack) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
-(void)btnBackClick:(id)sender{
    if (self.callBackBlock) {
        self.callBackBlock(NO, self.needToHome);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark-
- (void)actionAgreeProtocol:(UIButton *)sender{
    // 用户协议
    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    ruleVC.vcTitle = @"用车协议";
    ruleVC.urlString = [NSString stringWithFormat:@"%@agreement1.html",KAboutServerAddr];
    //    [self.navigationController pushViewController:ruleVC animated:YES];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:ruleVC];
    nav.navigationBar.barTintColor = [UIColor colorWithHex:GloabalTintColor];
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)btnBKClick:(id)sender {
    [self.textPhone resignFirstResponder];
    [self.textCode resignFirstResponder];
}

- (void)btnLoginClick:(id)sender {
    
    //使键盘消失
    [_textPhone resignFirstResponder];
    [_textCode resignFirstResponder];
    
    if (![BCBaseObject isFNMobileNumber:_textPhone.text]) {
        [self showTipsView:@"请输入正确的手机号码"];
        return;
    }
    
    if (_textCode.text.length == 0) {
        [self showTipsView:@"请输入验证码"];
        return;
    }
    [self startWait];
    NSDictionary *loginDic = @{@"phone":_textPhone.text,
                               @"code":_textCode.text,
                               @"terminalType":@(2),
                               @"vType":@(EMUserRole_User),
                               @"password":@"",
                               @"registrationId":[[PushConfiguration sharedInstance] getRegistrationID],
                               @"userRole":@(EMUserRole_User)};
    
    [NetManagerInstance sendRequstWithType:FNUserRequestType_Login params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = loginDic;
    }];
    
}

- (void)btnCodeClick:(id)sender {
    //使键盘消失
    [_textPhone resignFirstResponder];
    [_textCode resignFirstResponder];
    
    if (![BCBaseObject isFNMobileNumber:_textPhone.text]) {
        [self showTipsView:@"请输入正确的手机号码"];
        return;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_GetVerifyCode params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{@"phone":_textPhone.text,
                        @"type":@1};
    }];
    
    [self startWait];
}
#pragma mark - UITextField Delegate
- (void)resignTextFieldFirstResponder:(UITextField *)tf{
    [tf resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = self.view.bounds ;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resignTextFieldFirstResponder:textField];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect = [textField.superview convertRect:textField.frame toView:self.view];
    CGFloat bottom = CGRectGetMaxY(rect);
    CGFloat delta = self.view.frame.size.height - bottom - 290;
    if (delta < 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0, delta);
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self resignTextFieldFirstResponder:textField];
}
#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
    ResultDataModel *parse = (ResultDataModel *)notification.object;
    
    switch (parse.requestType) {
        case KRequestType_GetVerifyCode: {
            if (parse.resultCode == 0) {
                [self showTipsView:@"验证码已发送"];
                [_btnCode startAutoCountDownByInitialCount:60];
            }else {
                [self showTip:parse.message WithType:FNTipTypeFailure];
            }
        }
            break;
        case FNUserRequestType_Login: {
            if (parse.resultCode == 0) {
                NSString *token = [parse.data objectForKey:@"token"];
                NSString *userId = [parse.data objectForKey:@"id"];
                if (token) {    //保存token
                    [[UserPreferences sharedInstance] setToken:token];
                    [[UserPreferences sharedInstance] setUserId:userId];
                    // 1 为用户角色, 用户端
                    [NetManagerInstance setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", userId,token,EMUserRole_User]];
                    // 注册通知别名
                    [[PushConfiguration sharedInstance] setAlias:PassengerAlias userId:userId];
                }
                
                //保存用户信息
                User *user = [[User alloc] init];
                user.Id = [parse.data objectForKey:@"id"];
                user.phone = self.textPhone.text;
                [[UserPreferences sharedInstance] setUserInfo:user];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.callBackBlock) {
                        self.callBackBlock(YES, self.needToHome);
                    }
                }];
                [self showTip:@"登录成功" WithType:FNTipTypeSuccess];
                //                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self showTip:parse.message WithType:FNTipTypeFailure];
            }
        }
            break;
            
        default:
            break;
    }
    
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
    NSError *error = notification.object[@"error"];
    if (error.code != 401 && error.code != 403) {
        [self showTip:error.localizedDescription WithType:FNTipTypeFailure hideDelay:1.5];
    }
}

@end
