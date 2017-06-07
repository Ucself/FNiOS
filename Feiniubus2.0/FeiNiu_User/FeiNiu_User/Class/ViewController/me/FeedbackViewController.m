//
//  FeedbackViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "FeedbackViewController.h"
#import <FNUIView/PlaceHolderTextView.h>

#import "FNCommon/JsonUtils.h"
#import <FNUIView/MBProgressHUD.h>

#define PostRequest_Complaints_Suggest [NSString stringWithFormat:@"%@Complaints",KServerAddr]


@interface FeedbackViewController ()<UITextViewDelegate,UIGestureRecognizerDelegate>
{
    UILabel* statusLabel;
}
@property (strong, nonatomic) IBOutlet PlaceHolderTextView *textContent;
@property (strong, nonatomic) IBOutlet PlaceHolderTextView *textContact;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *btnCommit;

@property (assign, nonatomic) BOOL contentChanged;
@property (assign, nonatomic) BOOL contactChanged;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    _feedType = FeedbackType_Suggest;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- initialized
-(void)initUI
{
    self.textContact.placeHolder = @"请填写您的邮箱或手机号码方便我们联系您";
    self.textContent.numberLimit = 50;
    if (self.feedType == FeedbackType_Complain) {
        self.title = @"我要投诉";
        self.textContent.placeHolder = @"智慧交通, 有待改进";

        [_label1  setHidden:YES];
        [_label2  setHidden:NO];
        [_telephoneButton setHidden:NO];


    }

    else {
        self.title = @"意见建议";

        self.textContent.placeHolder = @"智慧交通, 有待改进";
        
        [_label1  setHidden:NO];
        [_label2  setHidden:YES];
        [_telephoneButton setHidden:YES];

    }

//    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW - 100, CGRectGetMaxY(self.textContent.frame) - 30, 90, 20)];
//    statusLabel.text = @"0/200";
//    statusLabel.textAlignment = NSTextAlignmentRight;
//    statusLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
//    statusLabel.font = [UIFont systemFontOfSize:14];
//    [self.view addSubview:statusLabel];

//    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenW - 100, CGRectGetMaxY(self.textContent.frame) - 30, 90, 20)];
//    statusLabel.text = @"0/200";
//    statusLabel.textAlignment = NSTextAlignmentRight;
//    statusLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
//    statusLabel.font = [UIFont systemFontOfSize:14];
//    [self.view addSubview:statusLabel];
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

- (IBAction)submitButtonClick{
    
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
    
    
    if(self.textContent.text.length == 0) {
        [self popPromptView:@"请填写内容"];
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_Feedback params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"content": self.textContent.text};
    }];
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
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.code == EmCode_Success) {
        if (result.type == EmRequestType_Feedback) {
            [self showTip:@"提交成功" WithType:FNTipTypeSuccess];
            
            [self performSelector:@selector(jumpToMainInterface) withObject:nil afterDelay:1];
        }
    }
    else {
        [self showTip:@"提交失败" WithType:FNTipTypeFailure];
    }
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

#pragma mark -- textview delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView isEqual:_textContact]) {
       
//        [UIView animateWithDuration:0.5 animations:^{
//            
//            [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y - 30)];
//        }];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    if ([textView isEqual:_textContact]) {

//        [UIView animateWithDuration:0.1 animations:^{
//            
//            [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y + 30)];
//        }];
    }
    
    [textView resignFirstResponder];
    return YES;
}



- (void)textViewDidChange:(UITextView *)textView {

//    if (textView.text.length == 0) {
//        [self.btnCommit setBackgroundColor:[UIColor lightGrayColor]];
//    }
//    else {
//        [self.btnCommit setBackgroundColor:UIColor_DefOrange];
//    }

}


@end
