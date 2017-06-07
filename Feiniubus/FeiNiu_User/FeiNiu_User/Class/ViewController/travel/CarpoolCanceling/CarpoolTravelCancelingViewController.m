//
//  CarpoolTravelCancelingViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolTravelCancelingViewController.h"
#import "CarpoolTravelStatusProgressView.h"
#import "CarpoolRefundOrderDetailViewController.h"
#import "CarpoolOrderItem.h"
#import "UserWebviewController.h"

@interface CarpoolTravelCancelingViewController ()
@property (weak, nonatomic) IBOutlet CarpoolTravelStatusProgressView *progressView;

@end

@implementation CarpoolTravelCancelingViewController

+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"CarpoolTravelCanceling" bundle:nil];
    return [storyboad instantiateInitialViewController];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订单取消";
    [self requestCarpoolOrderDetail];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"查看规则" style:UIBarButtonItemStylePlain target:self action:@selector(actionRule:)];
    [rightItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setCarpoolOrderItem:(CarpoolOrderItem *)carpoolOrderItem{
#if DEBUG
//    carpoolOrderItem.payStatus = CarpoolOrderPayStatusRefundDone;
#endif
    switch (carpoolOrderItem.payStatus) {
        case CarpoolOrderPayStatusApplyForRefund:
        case CarpoolOrderPayStatusRefunding:{
            self.progressView.state = 1;
            break;
        }
            case CarpoolOrderPayStatusRefundReject:
            case CarpoolOrderPayStatusRefundFail:
        case CarpoolOrderPayStatusRefundDone:{
            self.progressView.state = 2;
            break;
        }
        default:{
            self.progressView.state = 1;

            break;
        }
    }
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CarpoolRefundOrderDetailViewController class]]) {
            ((CarpoolRefundOrderDetailViewController *)obj).carpoolOrderItem = carpoolOrderItem;
        }
    }];
    _carpoolOrderItem = carpoolOrderItem;
}
- (void)actionRule:(UIBarButtonItem *)sender{
    UserWebviewController *webVC = [UserWebviewController instanceFromStoryboard];
    webVC.url = HTMLAddr_CharterRefundRule;
    [self.navigationController pushViewController:webVC animated:YES];
}
- (void)requestCarpoolOrderDetail{
    if (!self.carpoolOrderItem || !self.carpoolOrderItem.orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId":self.carpoolOrderItem.orderId};
    }];
}

- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    NSDictionary *result = resultData.data;
    
    if (type == FNUserRequestType_CarpoolOrderDetail) {
        if (resultData.resultCode == 0) {
            // 查询状态成功
            self.carpoolOrderItem = [[CarpoolOrderItem alloc]initWithDictionary:result[@"data"]];
        }
    }
    DBG_MSG(@"%@", notification.object);
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *destinationVC = segue.destinationViewController;
    if ([destinationVC isKindOfClass:[CarpoolRefundOrderDetailViewController class]]) {
        ((CarpoolRefundOrderDetailViewController *)destinationVC).carpoolOrderItem = self.carpoolOrderItem;
    }
}


@end
