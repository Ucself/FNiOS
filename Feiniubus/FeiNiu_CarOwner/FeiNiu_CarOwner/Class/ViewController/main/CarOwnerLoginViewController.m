//
//  CarOwnerLoginViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/10.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerLoginViewController.h"
#import "ProtocolCarOwner.h"
#import "CarOwnerPreferences.h"
#import <FNNetInterface/PushConfiguration.h>


@interface CarOwnerLoginViewController ()<UITextFieldDelegate>
{
    BOOL isPasswordType;
}

@property (weak, nonatomic) IBOutlet UILabel *registLable;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLable;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *eyeButton;


@end

@implementation CarOwnerLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化界面加载
    [self initInterface];
    //设置Navbar
    [self setNavigationBarSelf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    //关闭手势滑动
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
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
//设置tabbar
-(void)setNavigationBarSelf
{
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xFFFFFF)];
    [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0x333333)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x333333)}];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //iOS7 增加滑动手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
/**
 *  初始化界面使用
 */
-(void)initInterface
{
    //背景色
    [self.view setBackgroundColor:UIColorFromRGB(0xF5F5F5)];
    //设置圆角
    _accountTextField.layer.cornerRadius = 3;
    _accountTextField.layer.masksToBounds = YES;
    _passwordTextField.layer.cornerRadius = 3;
    _passwordTextField.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 3;
    _loginButton.layer.masksToBounds = YES;
    //设置输入框左边图标
    UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 22)];
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phoneIcon"]];
    [phoneImageView setFrame:CGRectMake(15, 0, (44.0/44.0)*22, 22)];
    [phoneView addSubview:phoneImageView];
    _accountTextField.leftView = phoneView;
    _accountTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 22)];
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordIcon"]];
    [passwordImageView setFrame:CGRectMake(15, 0, (44.0/48.0)*22, 22)];
    [passwordView addSubview:passwordImageView];
    _passwordTextField.leftView = passwordView;
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //注册点击手势
    UITapGestureRecognizer *registGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registClick:)];
    [_registLable addGestureRecognizer:registGesture];
    [_registLable setUserInteractionEnabled:YES];
    //忘记密码点击手势
    UITapGestureRecognizer *forgotPasswordGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPasswordClick:)];
    [_forgotPasswordLable addGestureRecognizer:forgotPasswordGesture];
    
    //注册协议
    _accountTextField.delegate = self;
    _passwordTextField.delegate = self;
    
    //设置默认为密码模式
    isPasswordType = YES;
    
    //设置应用上的图标显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //向极光服务器设置
    [[PushConfiguration sharedInstance] setBadge:0];
    
}


/**
 *  点击注册按钮
 */
-(void)registClick:(UITapGestureRecognizer *)recognizer
{
    [self hideKeyboard];
    [self performSegueWithIdentifier:@"toRegist" sender:self];
}
/**
 *  忘记密码点击
 */
-(void)forgotPasswordClick:(UITapGestureRecognizer *)recognizer
{
    [self hideKeyboard];
    [self performSegueWithIdentifier:@"toForgot" sender:self];
}

//隐藏键盘使用
-(void)hideKeyboard
{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}
/**
 *  登录点击
 *
 *  @param sender
 */
- (IBAction)loginClick:(id)sender {
    
    [self hideKeyboard];
    
    NSString *tempPhone = _accountTextField.text;
    NSString *tempPassword = _passwordTextField.text;
    
    if ([tempPhone isEqualToString:@""] || [tempPassword isEqualToString:@""]) {
        [self showTipsView:@"电话号码或密码不能为空"];
        return;
    }
    //请求前添加等待符号
    [self startWait];
    NSMutableDictionary *loginDic = [[NSMutableDictionary alloc] init];
    [loginDic setObject:tempPhone forKey:@"phone"];
    [loginDic setObject:@"" forKey:@"code"];
    [loginDic setObject:[[NSNumber alloc] initWithInt:2] forKey:@"terminalType"];
    [loginDic setObject:[[NSNumber alloc] initWithInt:2] forKey:@"vType"];
    [loginDic setObject:[tempPassword md5] forKey:@"password"];
    [loginDic setObject:[[PushConfiguration sharedInstance] getRegistrationID] forKey:@"registrationId"];
    [loginDic setObject:[[NSNumber alloc] initWithInt:EMUserRole_CarOwner] forKey:@"userRole"];
    
    //更换登录方式
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:loginDic urlSuffix:KUrl_Login requestType:KRequestType_Login];
    
    //车主端口登录
    //    [[ProtocolCarOwner sharedInstance] login:tempPhone code:@"" vType:2 password:[tempPassword md5] userRole:EMUserRole_CarOwner];
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

/**
 *  跳转到主页
 *
 *  @return
 */
-(void) jumpToMainViewController
{
    //获取storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //获取控制器
    UITabBarController *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainViewControllerIdent"];
    [self.navigationController pushViewController:mainViewController animated:YES];
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
    
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_Login:
        {
            if (resultParse.resultCode == 0)
            {
                NSString *token = [resultParse.data objectForKey:@"token"];
                NSString *userId = [resultParse.data objectForKey:@"id"];
                if (token && userId)
                {    //保存token
                    [[CarOwnerPreferences sharedInstance] setToken:token];
                    [[CarOwnerPreferences sharedInstance] setUserId:userId];
                    // 3 为车主
                    [[ProtocolCarOwner sharedInstance] setAuthorization:[NSString stringWithFormat:@"%@:%@:%d", userId,token, EMUserRole_CarOwner]];
                    //重新设置标签和别名
                    [[PushConfiguration sharedInstance] setTagAndAlias:feiniuBusOwenersTag alias:BossAlias userId:userId];
//                    //注册通知别名
//                    [[PushConfiguration sharedInstance] setAlias:BossAlias userId:userId];
//                    [[PushConfiguration sharedInstance] setTag:feiniuBusOwenersTag];
                }
                
                [self hideKeyboard];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else if (resultParse.resultCode  == 100002)
            {
                //账号或者密码错误
                [self showTipsView:@"账号或密码错误"];
            }
            else if (resultParse.resultCode  == 100006)
            {
                //账号或者密码错误
                [self showTipsView:@"电话号码格式错误"];
            }
            else if ( resultParse.resultCode == 100010)
            {
                //账号或者密码错误
                [self showTipsView:@"账号或密码错误"];
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


#pragma mark --- 通知注册
//- (void)setAlias:(NSString*)Alias {
//    [APService setTags:tags callbackSelector:@selector(tagsCallback:) object:self];
//    [APService setAlias:Alias callbackSelector:nil object:self];
//}
@end














