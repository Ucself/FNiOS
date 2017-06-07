//
//  CarpoolRefundConfirmViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/25.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolRefundConfirmViewController.h"
#import "CarpoolOrderItem.h"
#import "UIColor+Hex.h"
#import "UINavigationController+StackManage.h"
#import "UserWebviewController.h"
#import "TravelHistoryViewController.h"
#import "CarpoolCanceling/CarpoolTravelCancelingViewController.h"

@interface CarpoolRefundConfirmViewController (){
    CGFloat   _unitCharge;
    NSInteger   _adultTicketsNumber;
    NSInteger   _childTicketsNumber;
}
@property (weak, nonatomic) IBOutlet UILabel *lblAmountRefund;
@property (weak, nonatomic) IBOutlet UIButton *btnMinusAdult;
@property (weak, nonatomic) IBOutlet UIButton *btnMinusChild;
@property (weak, nonatomic) IBOutlet UIButton *btnAddAdult;
@property (weak, nonatomic) IBOutlet UIButton *btnAddChild;
//@property (weak, nonatomic) IBOutlet UIButton *btnMinusFree;
//@property (weak, nonatomic) IBOutlet UIButton *btnAddFree;

@property (weak, nonatomic) IBOutlet UITextField *tfAdult;
@property (weak, nonatomic) IBOutlet UITextField *tfChild;
//@property (weak, nonatomic) IBOutlet UITextField *tfFree;

@end

@implementation CarpoolRefundConfirmViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CarpoolRefundConfirmViewController"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"取消订单";
    _unitCharge = 10;
    self.tfAdult.text = @"0";
    self.tfChild.text = @"0";
    
    [self updateCharesOfRefund];
    self.tfAdult.text = @"1";
    
    UIBarButtonItem *rightItemRule = [[UIBarButtonItem alloc]initWithTitle:@"规则" style:UIBarButtonItemStylePlain target:self action:@selector(actionRightItemRule:)];
    self.navigationItem.rightBarButtonItem = rightItemRule;
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self requestChargeOfRefund];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethods
- (NSInteger)adultsNumber{
    return [self.tfAdult.text integerValue];
}
- (NSInteger)childrenNumber{
    return [self.tfChild.text integerValue];
}
- (void)updateCharesOfRefund{
    CGFloat price = _unitCharge * [self adultsNumber];
    NSString *refundChargeString = [NSString stringWithFormat:@"%.1f", price];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"违约%@元", refundChargeString]];
    [attString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:19], NSForegroundColorAttributeName:[UIColor colorWithHex:GloabalTintColor]} range:[attString.string rangeOfString:refundChargeString]];
    
    self.lblAmountRefund.attributedText = attString;
    
    UIColor *enableColor = [UIColor colorWithHex:GloabalTintColor];
    UIColor *disableColor = [UIColor colorWithHex:0xE0E0E0];
    BOOL isAddAdultsEnable = [self adultsNumber] < _adultTicketsNumber;
    BOOL isMinusAdultsEnable = [self adultsNumber] > 1;
    self.btnAddAdult.enabled = isAddAdultsEnable;
    self.btnAddAdult.backgroundColor = isAddAdultsEnable ? enableColor : disableColor;
    self.btnMinusAdult.enabled = isMinusAdultsEnable;
    self.btnMinusAdult.backgroundColor = isMinusAdultsEnable ? enableColor : disableColor;
    
    BOOL isAddChildEnable = [self childrenNumber] < _childTicketsNumber;
    BOOL isMinusChildEnable = [self childrenNumber] > 1;
    self.btnAddChild.enabled = isAddChildEnable;
    self.btnAddChild.backgroundColor = isAddChildEnable ? enableColor : disableColor;
    self.btnMinusChild.enabled = isMinusChildEnable;
    self.btnMinusChild.backgroundColor = isMinusChildEnable ? enableColor : disableColor;
}
#pragma mark - actions
- (IBAction)actionSubmit:(UIButton *)sender {
    if ([self adultsNumber] == 0 && [self childrenNumber] == 0) {
        [self showTip:@"请至少输入一张票！" WithType:FNTipTypeWarning];
        return;
    }
    [self requestRefund];
}
- (IBAction)actionMinusAdult:(UIButton *)sender {
    NSInteger num = [self adultsNumber];
    num --;
    if (num <= 1) {
        num = 1;
    }
    self.tfAdult.text = @(num).stringValue;
    [self updateCharesOfRefund];
}
- (IBAction)actionAddAdult:(UIButton *)sender {
    NSInteger num = [self adultsNumber];
    num ++;
    if (num >= _adultTicketsNumber) {
        num = _adultTicketsNumber;
    }
    self.tfAdult.text = @(num).stringValue;
    [self updateCharesOfRefund];
}
- (IBAction)actionMinusChild:(UIButton *)sender {
    NSInteger num = [self childrenNumber];
    num --;
    if (num <= 1) {
        num = 1;
    }
    self.tfChild.text = @(num).stringValue;
    [self updateCharesOfRefund];
}
- (IBAction)actionAddChild:(UIButton *)sender {
    NSInteger num = [self childrenNumber];
    num ++;
    if (num >= _childTicketsNumber) {
        num =_childTicketsNumber;
    }
    self.tfChild.text = @(num).stringValue;
    [self updateCharesOfRefund];
}

- (void)actionRightItemRule:(UIBarButtonItem *)sender{
    UserWebviewController *webVC = [[UserWebviewController alloc]initWithUrl:HTMLAddr_CharterRefundRule];
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark - RequestMethods
- (void)requestRefund{
    if (!self.orderItem || !self.orderItem.orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderCancel params:^(NetParams *params) {
        params.method = EMRequstMethod_DELETE;
        params.data = @{@"orderId": self.orderItem.orderId,
                        @"adultTicket": @([self adultsNumber]),        //全票张数
                        @"freeTicket": @([self childrenNumber])};       //免票张数
    }];
}
- (void)requestChargeOfRefund{
    if (!self.orderItem || !self.orderItem.orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolRefundCharge params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{@"orderId":self.orderItem.orderId};
    }];

}
#pragma mark - 
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    NSDictionary *result = resultData.data;
    
    if (type == FNUserRequestType_CarpoolRefundCharge) {
        _unitCharge = [result[@"price"] floatValue] / 100.0f ;
        _adultTicketsNumber = [result[@"adultTicket"] integerValue];
        _childTicketsNumber = [result[@"freeTicket"] integerValue];
//        self.tfAdult.text = [NSString stringWithFormat:@"%@", @(_adultTicketsNumber)];
        [self updateCharesOfRefund];
    }else if (type == FNUserRequestType_CarpoolOrderCancel){
        if (resultData.resultCode == 0) {
            if ([self adultsNumber] == _adultTicketsNumber) {
//                [self.navigationController popToViewControllerByClass:@"TravelHistoryViewController" animated:YES isNeedToRootWhenClassNotFound:YES];

//                [self.navigationController pushViewController:cancelingVC animated:YES];
//                for (UIViewController *vc in self.navigationController.viewControllers) {
//                    if ([vc isKindOfClass:[TravelHistoryViewController class]]) {
//                        [self.navigationController popToViewController:vc animated:YES];
//                        return;
//                    }
//                }
//                NSMutableArray *temp = [NSMutableArray arrayWithObject:[self.navigationController.viewControllers firstObject]];
//                [temp addObject:[TravelHistoryViewController instanceFromStoryboard]];
//                [self.navigationController setViewControllers:temp animated:YES];
                CarpoolTravelCancelingViewController *cancelingVC = [CarpoolTravelCancelingViewController instanceFromStoryboard];
                cancelingVC.carpoolOrderItem = self.orderItem;
                
                NSMutableArray *temp = [NSMutableArray arrayWithObject:[self.navigationController.viewControllers firstObject]];
                [temp addObject:[TravelHistoryViewController instanceFromStoryboard]];
                [temp addObject:cancelingVC];
                //        [temp addObject:];
                [self.navigationController setViewControllers:temp animated:YES];
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            [self showTip:resultData.message WithType:FNTipTypeFailure];
        }
    }
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
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
