//
//  BaseUIViewController.m
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import "BaseUIViewController.h"
#import <FNUIView/MBProgressHUD.h>
#import <FNUIView/UIView+Frame.h>


@interface BaseUIViewController ()

@property(nonatomic, weak)UIView *blowView;

@end

@implementation BaseUIViewController

/**
 *  实例从storyboard初始化方法, 类名必须与storyboardIdentifier相同
 *
 *  @param storyboardName storyboard文件名
 *
 *  @return viewcontroller实例
 */
+ (instancetype)instanceWithStoryboardName:(NSString*)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    NSString *ident = NSStringFromClass([self class]);
    
    //{{兼容swift返回的ident格式projectname.classname
    NSRange range = [ident rangeOfString:@"."];
    if (range.location!= NSNotFound) {
        ident = [ident substringFromIndex:range.location+1];
    }
    //}}
    
    return [storyboard instantiateViewControllerWithIdentifier:ident];
}

-(void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    DBG_MSG(@"enter");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotifyEnterBackGround object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotifyBecomeActive object:nil];
}

-(void)loadView{
    [super loadView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //注册系统通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationEnterBackGround) name:KNotifyEnterBackGround object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationBecomeActive) name:KNotifyBecomeActive object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //注册网络请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear: (BOOL)animated
{
    [super viewWillDisappear: animated];
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_RequestFailed object:nil];
}



#pragma mark-
-(void)setNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    UIImage *image = [UIImage imageNamed:@"backbtn"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(btnBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
    
}

-(void)btnBackClick:(id)sender
{
    [self popViewController];
}

-(void)addGotoTopButton:(UIView*)blowView
{
    self.btnGotoTop = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnGotoTop.backgroundColor = [UIColor clearColor];
    [self.btnGotoTop setBackgroundImage:[UIImage imageNamed:@"icon_backtop"] forState:UIControlStateNormal];
    [self.btnGotoTop addTarget:self action:@selector(btnGotoTopClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.blowView = blowView;
    if (blowView) {
        [self.view insertSubview:self.btnGotoTop belowSubview:blowView];
    }
    else {
        [self.view addSubview:self.btnGotoTop];
    }
    
    [self.btnGotoTop makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(40);
        make.height.equalTo(40);
        make.left.equalTo(self.view.right).offset(-50);
        
        if (self.blowView) {
            make.top.equalTo(self.blowView).offset(0);
        }
        else {
            make.top.equalTo(self.view.bottom).offset(0);
        }
        
    }];
}

-(void)showGotoTopButton:(BOOL)show
{
    [self showGotoTopButton:show offset:-50];
}

-(void)showGotoTopButton:(BOOL)show offset:(int)offset
{
    if (self.btnGotoTop.tag == show) {
        return;
    }
    
    int yOffset = 0;
    if (show) {
        yOffset = offset;
    }
    
    
    [self.btnGotoTop remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(40);
        make.height.equalTo(40);
        make.left.equalTo(self.view.right).offset(-50);
        if (self.blowView) {
            make.top.equalTo(self.blowView.top).offset(yOffset);
        }
        else {
            make.top.equalTo(self.view.bottom).offset(yOffset);
        }
        
    }];
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    self.btnGotoTop.tag = show;
}

- (IBAction)btnGotoTopClick:(id)sender {
}

#pragma mark- system notification
-(void)onApplicationEnterBackGround
{
    DBG_MSG(@"Enter");
}

-(void)onApplicationBecomeActive
{
    DBG_MSG(@"Enter");
}


#pragma mark - show alert view
-(void) showAlertWithTitle:(NSString*)title msg:(NSString*)msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    alert.delegate = self;
    [alert show];
}

- (void) showAlertWithTitle:(NSString*)title msg:(NSString*)msg showCancel:(BOOL)showCancel
{
    if (!showCancel) {
        [self showAlertWithTitle:title msg:msg];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定", nil];
        alert.delegate = self;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)showTipsView:(NSString*)tips
{
    [[TipsView sharedInstance] showTips:tips];
}

- (void)showTipsView:(NSString*)tips alignment:(ShowAlignment)alignment
{
    [[TipsView sharedInstance] showTips:tips alignment:alignment];
}

- (void) startWait
{
    [self stopWait];
    //防止程序还未启动的时候就调用产生错误
    if ([[UIApplication sharedApplication] keyWindow]) {
        [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
    }
    
}

- (void) stopWait
{
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

#pragma mark- http request handler

-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [self stopWait];
//    NSDictionary *dict = notification.object;
//    
//    NSError *error = [dict objectForKey:@"error"];
//    int type = [[dict objectForKey:@"type"] intValue];
//    ResultDataModel *result = [[ResultDataModel alloc] initWithErrorInfo:error reqType:type];
//    
//    DBG_MSG(@"httpRequestFailed: resultcode= %d", result.code);
//    [self showTipsView:result.message];
}


@end



