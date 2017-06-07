//
//  UnionPayViewController.m
//  FNPayment
//
//  Created by tianbo on 2016/11/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UnionPayViewController.h"
#import <cmbkeyboard/CMBWebKeyboard.h>
#import <cmbkeyboard/NSString+Additions.h>

#import "FNPaymentManager.h"

@interface UnionPayViewController () <UIWebViewDelegate>
@property (nonatomic, strong)UIWebView *webView;

@property (nonatomic, strong)UIButton *btnBack;
@property (nonatomic, strong)UILabel *lbTitle;
@end

@implementation UnionPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    [self intInterface];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [request setHTTPMethod:@"POST"];
    request.HTTPBody = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    [self startWait];
    
    [self.view addSubview:self.webView];
    
    [self.webView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.right.equalTo(self.view.right);
        make.top.equalTo(64);
        make.bottom.equalTo(self.view.bottom);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CMBWebKeyboard shareInstance] hideKeyboard];
}

-(void)intInterface
{
    UIView *navView = [UIView new];
    navView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    [self.view addSubview:navView];
    
    [navView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.top.equalTo(0);
        make.right.equalTo(self.view.right);
        make.height.equalTo(64);
    }];
    
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBack.contentMode = UIViewContentModeScaleAspectFit;
    [_btnBack setImage:[UIImage imageNamed:@"btnback_n"] forState:UIControlStateNormal];
    [_btnBack setImage:[UIImage imageNamed:@"btnback_h"] forState:UIControlStateHighlighted];
    [_btnBack addTarget:self action:@selector(btnBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:_btnBack];
    
    [_btnBack makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(10);
        make.top.equalTo(27);
        make.width.equalTo(50);
        make.height.equalTo(30);
    }];
    
    _lbTitle = [[UILabel alloc] init];
    _lbTitle.textColor = UIColor_DefOrange;
    _lbTitle.font = [UIFont boldSystemFontOfSize:17];
    _lbTitle.textAlignment = NSTextAlignmentCenter;
    _lbTitle.backgroundColor = [UIColor clearColor];
    //_lbTitle.text = @"xxxxlll";
    [navView addSubview:_lbTitle];
    
    [_lbTitle makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(60);
        make.right.equalTo(navView.right).offset(-60);
        make.top.equalTo(20);
        make.bottom.equalTo(navView.bottom);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopWait];
    NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.lbTitle.text = title;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopWait];
    [self showTipsView:@"一网通页面加载失败"];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(request.URL.host);
    if ([request.URL.host isCaseInsensitiveEqualToString:@"cmbls"]) {//此处开始调用键盘
        CMBWebKeyboard *secKeyboard = [CMBWebKeyboard shareInstance];
        [secKeyboard showKeyboardWithRequest:request];
        secKeyboard.webView = _webView;
        //以下是实现点击键盘外地方，自动隐藏键盘
        UITapGestureRecognizer* myTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.view addGestureRecognizer:myTap]; //这个可以加到任何控件上,比如你只想响应WebView，我正好填满整个屏幕
        myTap.delegate = self;
        myTap.cancelsTouchesInView = NO;
        return NO;//调出密码键盘，拦截该请求
    }
    else if ([[request.URL absoluteString] isCaseInsensitiveEqualToString:KUnionPayCallbackURL]) {
        //点击返回商户 支付成功
        [self.navigationController popViewControllerAnimated:YES];
        self.successCallback(YES);
        return NO;
    }
    return YES;
}


#pragma mark -
-(void)btnBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    self.successCallback(NO);
}

-(void)handleSingleTap:(UITapGestureRecognizer*)gesture
{
    [[CMBWebKeyboard shareInstance] hideKeyboard];
}
@end
