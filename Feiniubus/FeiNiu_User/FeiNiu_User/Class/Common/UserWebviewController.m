//
//  UserWebviewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserWebviewController.h"

@implementation UserWebviewController
- (id)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    _webView.delegate = self;
    
    NSURL *requestUrl = [NSURL URLWithString:self.url];
    [_webView loadRequest:[NSURLRequest requestWithURL:requestUrl]];
    [self startWait];
}

#pragma mark - WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopWait];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopWait];
    [self showTip:error.localizedDescription WithType:FNTipTypeFailure];
}
@end
