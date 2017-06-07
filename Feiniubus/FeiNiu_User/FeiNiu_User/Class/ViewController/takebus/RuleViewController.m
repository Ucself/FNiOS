//
//  RuleViewController.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/12.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "RuleViewController.h"
#import <FNUIView/MBProgressHUD.h>

@interface RuleViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *ruleWebView;

@end

@implementation RuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigationItems];
    [self initWebView];
    
}

- (void)initWebView{
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self startWait];
    NSURLRequest *reuqest = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [self.ruleWebView loadRequest:reuqest];
}

- (void)initNavigationItems{
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLeft setFrame:CGRectMake(0, 0, 20, 15)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    self.navigationItem.title = _vcTitle;
}

- (void)backButtonClick{
    if (self.navigationController.viewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopWait];
    
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopWait];
    
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
