//
//  CarOwnerRegistViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/10.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverLoginViewController.h"
#import "ProtocolDriver.h"
#import "FNUIView/DynaButton.h"
#import "DriverPreferences.h"
#import <FNCommon/String+MD5.h>

@interface DriverLoginViewController ()<UITextFieldDelegate,DynaButtonDelegate>
{
    BOOL isPasswordType;
}

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *codeButton;
@property (weak, nonatomic) IBOutlet DynaButton *codeButtonView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *eyeButton;


@end

@implementation DriverLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
    // 设置导航栏
    [self setNavigationBarSelf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //打开手势滑动
    //    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark ----

-(void) initInterface
{
    //设置圆角
    _phoneNumberTextField.layer.cornerRadius = 3;
    _phoneNumberTextField.layer.masksToBounds = YES;
    _codeTextField.layer.cornerRadius = 3;
    _codeTextField.layer.masksToBounds = YES;
    _codeButton.layer.cornerRadius = 3;
    _codeButton.layer.masksToBounds = YES;
    //    _passwordTextField.layer.cornerRadius = 3;
    //    _passwordTextField.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 3;
    _loginButton.layer.masksToBounds = YES;
    //设置输入框左边图标
    UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 22)];
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phoneIcon"]];
    [phoneImageView setFrame:CGRectMake(15, 0, (44.0/44.0)*22, 22)];
    [phoneView addSubview:phoneImageView];
    _phoneNumberTextField.leftView = phoneView;
    _phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *codeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 22)];
    UIImageView *codeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verificationCodeIcon"]];
    [codeImageView setFrame:CGRectMake(15, 0, (44.0/44.0)*22, 22)];
    [codeView addSubview:codeImageView];
    _codeTextField.leftView = codeView;
    _codeTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 22)];
    //    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordIcon"]];
    //    [passwordImageView setFrame:CGRectMake(15, 0, (44.0/48.0)*22, 22)];
    //    [passwordView addSubview:passwordImageView];
    //    _passwordTextField.leftView = passwordView;
    //    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //设置输入框协注册协议
    _phoneNumberTextField.delegate = self;
    _codeTextField.delegate = self;
    //    _passwordTextField.delegate = self;
    
    //初始化看不见密码
    isPasswordType = YES;
    
    //设置倒计时
    [_codeButtonView setDelegate:self];
    [_codeButtonView setTitle:@"获取验证码" textColor:UIColorFromRGB(0xFF5A37) normalImage:nil highImage:nil];
    
    //设置应用上的图标显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //向极光服务器设置
    [[PushConfiguration sharedInstance] setBadge:0];
    
}

-(void)setNavigationBarSelf
{
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xFC5338)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = nil;
}

- (IBAction)cancelClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginClick:(id)sender {
    //隐藏键盘
    [self hideKeyboard];
    //验证输入框是否输入
    if ([_phoneNumberTextField.text isEqualToString:@""]) {
        [self showTipsView:@"请输入手机号码"];
        return;
    }
    if ([_codeTextField.text isEqualToString:@""]) {
        [self showTipsView:@"请输入验证码"];
        return;
    }
    //    if ([_passwordTextField.text isEqualToString:@""]) {
    //        [self showTipsView:@"请输入密码"];
    //        return;
    //    }
    //暂时跳转使用
    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //请求前添加等待符号
    [self startWait];
    NSMutableDictionary *loginDic = [[NSMutableDictionary alloc] init];
    [loginDic setObject:_phoneNumberTextField.text forKey:@"phone"];
    [loginDic setObject:_codeTextField.text forKey:@"code"];
    [loginDic setObject:[[NSNumber alloc] initWithInt:2] forKey:@"terminalType"];
    [loginDic setObject:[[NSNumber alloc] initWithInt:1] forKey:@"vType"];
    [loginDic setObject:@"" forKey:@"password"];
    [loginDic setObject:[[PushConfiguration sharedInstance] getRegistrationID] forKey:@"registrationId"];
    [loginDic setObject:[[NSNumber alloc] initWithInt:EMUserRole_Driver] forKey:@"userRole"];
    //提醒视图
    [self startWait];
    //    [[ProtocolDriver sharedInstance] login:_phoneNumberTextField.text code:_codeTextField.text vType:1 password:@"" userRole:2];
    [[ProtocolDriver sharedInstance] getInforWithNSDictionary:loginDic urlSuffix:KUrl_Login requestType:KRequestType_Login];
}

//隐藏键盘使用
-(void)hideKeyboard
{
    [self.phoneNumberTextField resignFirstResponder];
    [self.codeTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)yanjinClick:(id)sender {
    isPasswordType = !isPasswordType;
    self.passwordTextField.secureTextEntry = isPasswordType;
    //设置图标
    if (isPasswordType)
    {
        [self.eyeButton setBackgroundImage:[UIImage imageNamed:@"yanjinOpenIcon"] forState:UIControlStateNormal];
    }
    else
    {
        [self.eyeButton setBackgroundImage:[UIImage imageNamed:@"yanjinCloseIcon"] forState:UIControlStateNormal];
    }
}

#pragma mark ---DynaButtonDelegate
//发送短信点击
-(void)dynaButtonClick:(UIView*)sender
{
    //隐藏键盘
    [self hideKeyboard];
    if ([_phoneNumberTextField.text isEqualToString:@""]) {
        [self showTipsView:@"请输入手机号码"];
        return;
    }
    //请求获取验证码
    [[ProtocolDriver sharedInstance] getVerifyCode:_phoneNumberTextField.text type:1];
    [_codeButtonView beginTimer:@"KRequestType_GetVerifyCode"];
}

#pragma mark ---UITextFieldDelegate
//开始编辑的时候键盘遮住输入框
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    return;
    //转换到当前坐标
    CGRect frame = textField.frame;
    frame = [self.view convertRect:frame fromView:textField.superview ];
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 280.0);//键盘高度250
    if (offset <= 0) {
        return;
    }
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    [UIView animateWithDuration:0.30f animations:^{
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
//动画视图还原
-(void)textFieldDidEndEditing:(UITextField *)textField{
    return;
    //动画还原
    [UIView animateWithDuration:0.30f animations:^{
        self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //回收键盘
    [textField resignFirstResponder];
    return YES;
}

#pragma mark- 点击背景回收键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[[event allTouches] anyObject];
    if (touch.tapCount >=1) {
        [self hideKeyboard];
    }
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel *)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_GetVerifyCode:
            //获取验证码请求
        {
            if (resultParse.resultCode == 0 )
            {
                [self showTipsView:@"验证码发送成功"];
            }
            else
            {
                [self showTipsView:@"验证码发送失败，请重试"];
            }
        }
            break;
        case KRequestType_Login:
        {
            
            if (resultParse.resultCode == 0)
            {
                NSString *token = [resultParse.data objectForKey:@"token"];
                NSString *userId = [resultParse.data objectForKey:@"id"];
                if (token)
                {    //保存token
                    [[DriverPreferences sharedInstance] setToken:token];
                    [[DriverPreferences sharedInstance] setUserId:userId];
                    // 3 为车主
                    [[ProtocolDriver sharedInstance] setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", userId,token, EMUserRole_Driver]];
                }
                
                [self hideKeyboard];
                //重新设置标签和别名
                [[PushConfiguration sharedInstance] setTagAndAlias:feiniuBusDrvierTag alias:DriverAlias userId:userId];
//                //注册推送
//                [[PushConfiguration sharedInstance] setTag:feiniuBusDrvierTag];
//                [[PushConfiguration sharedInstance] setAlias:DriverAlias userId:userId];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else if (resultParse.resultCode  == 100002)
            {
                //账号或者密码错误
                [self showTipsView:@"该账号不存在"];
            }
            else if (resultParse.resultCode  == 100008)
            {
                //账号或者密码错误
                [self showTipsView:@"验证码错误"];
            }
            else if (resultParse.resultCode  == 100006)
            {
                //账号或者密码错误
                [self showTipsView:@"电话号码格式错误"];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        default:
            break;
    }
    
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

@end
