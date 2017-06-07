//
//  CanceledViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CancelledViewController.h"
#import "CancelledSeasonViewController.h"

@interface CancelledViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgState;
@property (weak, nonatomic) IBOutlet UILabel *labelHanding;
@property (weak, nonatomic) IBOutlet UILabel *labelSuccess;
@property (weak, nonatomic) IBOutlet UILabel *reasonLab;


@property (strong, nonatomic) NSDictionary *dict;
@end

@implementation CancelledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicateRefundPace params:^(NetParams *params) {
        params.data = @{@"orderId": self.orderId};
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetUI
{
    _labelHanding.text = [NSString stringWithFormat:@"飞牛巴士已将您的退款提交至%@", _dict[@"channel"]];
    _labelSuccess.text = [NSString stringWithFormat:@"飞牛巴士已将您的退款提交至%@", _dict[@"channel"]];
    _reasonLab.text = _dict[@"reason"];
    
    switch ([_dict[@"state"] intValue]) {
        case 1:        //已申请
        {
            [_imgState setImage:[UIImage imageNamed:@"refundprocess1"]];
        }
            break;
        case 2:        //飞牛巴士处理成功
        {
            [_imgState setImage:[UIImage imageNamed:@"refundprocess2"]];
        }
            break;
        case 3:        //退款成功
        {
            [_imgState setImage:[UIImage imageNamed:@"refundprocess3"]];
        }
            break;
            
        default:
            break;
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

#pragma mark -
-(void)navigationViewRightClick
{
    CancelledSeasonViewController *c = [CancelledSeasonViewController instanceWithStoryboardName:@"FeiniuOrder"];
    c.isComplain = YES;
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)noReciveRefund:(id)sender {
    UserCustomAlertView *view = [UserCustomAlertView alertViewWithTitle:@"联系客服" message:@"400-0820-112" delegate:self buttons:@[@"取消",@"呼叫"]];
    [view showInView:self.view];
}

#pragma mark - UserAlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (btnIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://400-0820-112"]];
    }
}

#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.type == EmRequestType_GetDedicateRefundPace) {
        self.dict = result.data;
        [self resetUI];
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification{
    return [super httpRequestFailed:notification];
}
@end
