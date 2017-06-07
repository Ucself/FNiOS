//
//  FeedbackViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "FeedbackViewController.h"
#import <FNUIView/CPTextViewPlaceholder.h>

#import "FNCommon/JsonUtils.h"
#import <FNUIView/MBProgressHUD.h>

#define PostRequest_Complaints_Suggest [NSString stringWithFormat:@"%@Complaints",KServerAddr]


@interface FeedbackViewController ()<UITextViewDelegate,UIGestureRecognizerDelegate>
{
    UILabel* statusLabel;
}
@property (strong, nonatomic) IBOutlet CPTextViewPlaceholder *textContent;
@property (strong, nonatomic) IBOutlet CPTextViewPlaceholder *textContact;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;

@property (assign, nonatomic) BOOL contentChanged;
@property (assign, nonatomic) BOOL contactChanged;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- initialized
-(void)initUI
{
    self.textContact.placeholder = @"请填写您的邮箱或手机号码方便我们联系您";
    if (self.feedType == FeedbackType_Complain) {
        self.title = @"我要投诉";
        self.textContent.placeholder = @"请输入您要投诉的内容, 我们会在第一时间处理";

        [_label1  setHidden:YES];
        [_label2  setHidden:NO];
        [_telephoneButton setHidden:NO];


    }

    else {
        self.title = @"意见建议";

        self.textContent.placeholder = @"请输入您的建议, 我们会积极采纳";
        
        [_label1  setHidden:NO];
        [_label2  setHidden:YES];
        [_telephoneButton setHidden:YES];

    }
    
    [self initNavigationItems];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW - 100, CGRectGetMaxY(self.textContent.frame) - 30, 90, 20)];
    statusLabel.text = @"0/200";
    statusLabel.textAlignment = NSTextAlignmentRight;
    statusLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
    statusLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:statusLabel];

//    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW - 100, CGRectGetMaxY(self.textContent.frame) - 30, 90, 20)];
//    statusLabel.text = @"0/200";
//    statusLabel.textAlignment = NSTextAlignmentRight;
//    statusLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
//    statusLabel.font = [UIFont systemFontOfSize:14];
//    [self.view addSubview:statusLabel];
}



- (void)initNavigationItems{
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setFrame:CGRectMake(0, 0, 44, 44)];
    [submitBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:submitBtn];    
}

#pragma mark-- button event

- (IBAction)clickTelephone:(id)sender {
    
    UIWebView *callWebView = [[UIWebView alloc] init];
    
    NSURL *telURL = [NSURL URLWithString:@"tel:4000820112"];
    
    [callWebView loadRequest:[NSURLRequest requestWithURL:telURL]];
    
    [self.view addSubview:callWebView];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",@"40000129348"]]];
    
}

- (void)btnBackClick:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jumpToMainInterface{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitButtonClick{
    
    if (_feedType == FeedbackType_Complain) {
        [self.textContent resignFirstResponder];
        [self.textContact resignFirstResponder];
        [self submitData:1];//complain
        
    }else{
        [self.textContent resignFirstResponder];
        [self.textContact resignFirstResponder];
        [self submitData:2];//suggest
        
    }
}

#pragma mark-- submit data

- (void)submitData:(NSInteger)type{
    
    
    if(([self.textContent.placeholder length] == [self.textContent.text length]) ||
       ([self.textContact.placeholder length] == [self.textContact.text length])) {
        
        [self popPromptView:@"内容或联系方式不正确"];
        
    }else{
        
        [self startWait];
        [NetManagerInstance sendRequstWithType:KRequestType_complaints params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            params.data = @{@"phone": self.textContact.text,
                            @"content": self.textContent.text,
                            @"type": @(type)};
        }];
    }
}

#pragma mark -- Animation

- (void)popPromptView:(NSString *)text{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [hud setLabelText:text];
    [hud setMode:MBProgressHUDModeText];
    [hud hide:YES afterDelay:2];
    if (hud.hidden == YES) {
        [hud removeFromSuperview];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == KRequestType_complaints) {
        if (resultData.resultCode == 0) {
            
            [self showTipsView:@"提交成功"];
            
            [self performSelector:@selector(jumpToMainInterface) withObject:nil afterDelay:1];
            
            //                [self.navigationController popViewControllerAnimated:YES];
            
            //                [[NSNotificationCenter defaultCenter] postNotificationName:@"showPrompt" object:@{@"content":@"提交成功"}];
            
        }else{
            [self popPromptView:@"提交失败"];
        }
    }
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
    
    int type = [[notification.object objectForKey:@"type"] intValue];
    
    if(type == KRequestType_complaints){
        [self popPromptView:@"提交失败"];
    }
}

#pragma mark -- textview delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView isEqual:_textContact]) {
       
        [UIView animateWithDuration:0.5 animations:^{
            
            [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y - 30)];
        }];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    if ([textView isEqual:_textContact]) {

        [UIView animateWithDuration:0.1 animations:^{
            
            [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y + 30)];
        }];
    }
    
    [textView resignFirstResponder];
    return YES;
}



- (void)textViewDidChange:(UITextView *)textView {

    if (statusLabel) {
        NSInteger number = [textView.text length];
        if (number > 200) {
            textView.text = [textView.text substringToIndex:200];
            number = 200;
        }
        if ([textView.text hasSuffix:self.textContent.placeholder]) {
            statusLabel.text = @"1/200";
        }else{
            statusLabel.text = [NSString stringWithFormat:@"%ld/200",number];
        }
    }


}


@end
