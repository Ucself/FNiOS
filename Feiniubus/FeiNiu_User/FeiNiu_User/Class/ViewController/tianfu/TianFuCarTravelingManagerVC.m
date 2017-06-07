//
//  TianFuCarTravelingManagerVC.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/9.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TianFuCarTravelingManagerVC.h"

@interface TianFuCarTravelingManagerVC ()

@property (strong, nonatomic) IBOutlet UIView *travelDetailView;

@property (strong, nonatomic) IBOutlet UIView *travelCancelView;

@end

@implementation TianFuCarTravelingManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showStatusView];//根据status来显示不同的状态
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Function Methods

- (void)showStatusView{
    
    switch (_status) {
        case TianFuCarOrderStatusCancel:
            self.navigationItem.title = @"取消订单";
            [_travelDetailView setHidden:YES];
            [_travelCancelView setHidden:NO];
            break;
            
        case TianFuCarOrderStatusEnd:
            self.navigationItem.title = @"订单详情";
            [_travelDetailView setHidden:NO];
            [_travelCancelView setHidden:YES];
            break;
            
        default:
            break;
    }
}

@end
