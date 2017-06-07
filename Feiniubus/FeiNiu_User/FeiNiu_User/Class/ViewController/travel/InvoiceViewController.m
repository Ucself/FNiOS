//
//  InvoiceViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "InvoiceViewController.h"

@interface InvoiceViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfInvoiceHeader;

@end

@implementation InvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationBar];
    self.lblPrice.text = [self.price.stringValue stringByAppendingString:@" 元"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigationBar
{
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(actionSubmit:)];
    self.navigationItem.rightBarButtonItem = item;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)actionSubmit:(UIBarButtonItem *)sender{
    if (!self.orderId || self.orderId.length <= 0) {
        [self showTip:@"订单号为空" WithType:FNTipTypeWarning];
        return;
    }
    if (!self.price || self.price.integerValue <= 0 ) {
        [self showTip:@"价格错误" WithType:FNTipTypeWarning];
        return;
    }
    if (self.tfName.text.length <= 0) {
        [self showTip:@"请输入姓名" WithType:FNTipTypeWarning];
        return;
    }
    if (self.tfPhone.text.length <= 0) {
        [self showTip:@"请输入手机号" WithType:FNTipTypeWarning];
        return;
    }
    if (self.tfAddress.text.length <= 0) {
        [self showTip:@"请输入地址" WithType:FNTipTypeWarning];
        return;
    }
    if (self.tfInvoiceHeader.text.length <= 0) {
        [self showTip:@"请输入发票抬头" WithType:FNTipTypeWarning];
        return;
    }

    [NetManagerInstance sendRequstWithType:FNUserRequestType_Invoince params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"subOrderId" :self.orderId,
                        @"name"       :self.tfName.text,
                        @"phone"      :self.tfPhone.text,
                        @"address"    :self.tfAddress.text,
                        @"header"     :self.tfInvoiceHeader.text,
                        };
    }];
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.tfName) {
        [self.tfPhone becomeFirstResponder];
    }else if (textField == self.tfPhone){
        [self.tfAddress becomeFirstResponder];
    }else if (textField == self.tfAddress){
        [self.tfInvoiceHeader becomeFirstResponder];
    }else if (textField == self.tfInvoiceHeader){
        [self.tfInvoiceHeader resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0, 64) ;
        }];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect = [textField.superview convertRect:textField.frame toView:self.view];
    CGFloat bottom = CGRectGetMaxY(rect);
    CGFloat delta = self.view.frame.size.height - bottom - 290;
    if (delta < 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0, delta + 64);
        }];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (![touch.view isKindOfClass:[UITextField class]]) {
        [self.tfPhone resignFirstResponder];
        [self.tfName resignFirstResponder];
        [self.tfAddress resignFirstResponder];
        [self.tfInvoiceHeader resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0, 64) ;
        }];
    }
}
#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
    [self showTip:@"发票申请已提交" WithType:FNTipTypeSuccess];
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:1];
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
    
}
@end
