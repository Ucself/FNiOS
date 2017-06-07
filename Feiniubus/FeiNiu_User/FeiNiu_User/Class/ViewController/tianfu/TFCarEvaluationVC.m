//
//  TFCarEvaluationVC.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TFCarEvaluationVC.h"
#import "LoginViewController.h"
#import <FNNetInterface/PushConfiguration.h>
#import "TravelHistoryViewController.h"
#import "MainViewController.h"
#import "TravelViewController.h"
#import "RuleViewController.h"
#import "CarpoolTravelingViewController.h"

//#define ReviewsRequest [NSString stringWithFormat:@"%@FerryReviews",KServerAddr]
//
//#define RequestType_SendReviews    900
//#define RequestType_GetReviews     901

#define DefaultStr @"请输入评论内容，最多50个字。"



@interface TFCarEvaluationVC ()<UITextViewDelegate>
{
    int score;
    UIButton *btnLeft;
}
@property (strong, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (strong, nonatomic) IBOutlet UILabel  *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *detailButton;
@property (strong, nonatomic) IBOutlet UIButton *invoiceButton;
@property (strong, nonatomic) IBOutlet UILabel  *historyScoreLabel;
@property (strong, nonatomic) IBOutlet UITextView *evaluationContentText;

@property (strong, nonatomic) IBOutlet UIButton *submitEvaluationButton;

//starts buttons
@property (weak, nonatomic) IBOutlet UIView *viewStars;
@property (strong, nonatomic) IBOutlet UIButton *firstStar;
@property (strong, nonatomic) IBOutlet UIButton *secondStar;
@property (strong, nonatomic) IBOutlet UIButton *thirdStar;
@property (strong, nonatomic) IBOutlet UIButton *fourthStar;
@property (strong, nonatomic) IBOutlet UIButton *fivethStar;

@property (strong, nonatomic) NSArray *scrollImage;

@end

@implementation TFCarEvaluationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollImage = @[@"carLeft.jpg",@"carMiddle.jpg",@"carRight.jpg"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 64, ScreenW, ScreenH);
    
    score = 0;
    
    if (_isLook) {
//        score = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"scoreEvaluation_%@",_orderId]] intValue];
    }
    
    if (_orderDetailModel) {
        _orderId = _orderDetailModel.orderId;
        [self setOwerInformation];
    }else if(_orderId){
        [self requstFerryOrderCheckState];
    }

    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [self.view addGestureRecognizer:singleTap];
    
    _evaluationContentText.layer.borderColor = [UIColor colorWithWhite:.6 alpha:.4].CGColor;
    _evaluationContentText.layer.borderWidth = .5f;
    _evaluationContentText.delegate = self;
    _evaluationContentText.text = DefaultStr;

    for (UIButton* starBtn in self.viewStars.subviews) {
        if (starBtn.tag > 100 && starBtn.tag <= 105) {
            
            [starBtn setImage:[UIImage imageNamed:@"star_nor"] forState:0];
            [starBtn setImage:[UIImage imageNamed:@"star_press"] forState:UIControlStateSelected];
            starBtn.selected = NO;
            
            if (_isLook ) {
//                if (starBtn.tag <= 100 + score) {
//                    starBtn.selected = YES;
//                }
//                starBtn.userInteractionEnabled = NO;
            
            }
        }
    }
    
    if (_isLook) {
//        [_evaluationContentText setUserInteractionEnabled:NO];
//        _submitEvaluationButton.hidden = YES;
    }
    
    if (!_isTianFuCar) {
        _priceLabel.hidden = YES;
        _invoiceButton.hidden = YES;
        _detailButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
 
    [self initNavigationItems];
    [self initScrollView];
    
    [self requstGetFerryReviewsInfo];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    [self.navigationController.navigationBar setHidden:NO];
//    [self.navigationController.toolbar setHidden:NO];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
- (void)initScrollView{
    
    _topScrollView.frame = CGRectMake(0, 0, ScreenW, ScreenW/2);
    [_topScrollView setContentSize:CGSizeMake(3*self.view.frame.size.width, 0)];
    [_topScrollView setPagingEnabled:YES];
    [_topScrollView setContentMode:UIViewContentModeScaleAspectFill];
    [_topScrollView setBounces:NO];
    [_topScrollView setShowsHorizontalScrollIndicator:NO];
    [_topScrollView setShowsVerticalScrollIndicator:NO];
    [_topScrollView setAlwaysBounceHorizontal:YES];
//    [_topScrollView setContentOffset:CGPointMake(0, _topScrollView.frame.size.height)];
    
    for (int i = 0; i < _scrollImage.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectOffset(_topScrollView.bounds, i * _topScrollView.bounds.size.width, 0)];

        [imageView setContentMode:UIViewContentModeScaleToFill];

        [imageView setImage:[UIImage imageNamed:(NSString *)_scrollImage[i]]];
        [_topScrollView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_topScrollView.mas_width);
            make.height.equalTo(_topScrollView.mas_height);
            make.left.equalTo(_topScrollView).with.offset((i * _topScrollView.bounds.size.width));
            make.top.equalTo(_topScrollView);
        }];
    }
    
}

- (void)initNavigationItems{
    
    btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLeft setFrame:CGRectMake(0, 0, 20, 15)];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];

    self.navigationItem.title = @"评价";
    
//    [self.navigationController.navigationBar setHidden:YES];
//    [self.navigationController.toolbar setHidden:YES];
}


#pragma mark - http requst
-(void)requstGetFerryReviewsInfo{
    if (!_orderId || ![_orderId isKindOfClass:[NSString class]]) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:KRequestType_FerryReviewsGet params:^(NetParams *params) {
        params.data = @{@"orderId":_orderId};
    }];
}




- (void)requestSubmitReviews{
    if (!_orderId || ![_orderId isKindOfClass:[NSString class]]) {
        return;
    }
    

    if (_evaluationContentText.text.length == 0 || [_evaluationContentText.text isEqualToString:DefaultStr]) {
        _evaluationContentText.text = @"";
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryReviewsPost params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"orderId":_orderId,
                        @"score":@(score),
                        @"content":_evaluationContentText.text};
    }];
}


#pragma mark - http requst
-(void)requstFerryOrderCheckState{
    
    if(!_orderId){
        return;
    }
    
    [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
        params.data = @{@"orderId": _orderId};
    }];
}


- (void)setOwerInformation{
    if (!_orderDetailModel) {
        return;
    }
    
    _historyScoreLabel.text = [NSString stringWithFormat:@"历史评分:%.1f",_orderDetailModel.driverScore];
    
    if (_orderDetailModel.price) {
        NSString* string = [NSString stringWithFormat:@"%.2f元",[_orderDetailModel.price floatValue]/100.f];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttribute:NSFontAttributeName value:Font(13) range:[string rangeOfString:@"元"]];
        _priceLabel.attributedText = attrString;
    }
}


#pragma mark - 点击事件

- (IBAction)customBackBtn:(id)sender {
    
    [self backButtonClick];
}


- (void)backButtonClick{
    
    if (_evaluationTypeId == 3) {
        
        CarpoolTravelingViewController *travelVC = nil;
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            
            if ([vc isKindOfClass:[CarpoolTravelingViewController class]]) {
                
                travelVC = (CarpoolTravelingViewController *)vc;
            }
        }
        if (travelVC) {
            [self.navigationController popToViewController:travelVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        
        TravelHistoryViewController *travelVC = nil;
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            
            if ([vc isKindOfClass:[TravelHistoryViewController class]]) {
                
                travelVC = (TravelHistoryViewController *)vc;
            }
        }
        
        if (travelVC) {
            
            [self.navigationController popToViewController:travelVC animated:YES];
        }else{
            [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
        }

    }
   
}

- (void)singleTap{
    [_evaluationContentText resignFirstResponder];
}


- (IBAction)onClickSubmitBtn:(id)sender {
    [self requestSubmitReviews];
}


- (IBAction)onClickDetailBtn:(id)sender {
    
    RuleViewController *rule = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    rule.vcTitle = @"明细";
    rule.urlString = @"www.baidu.com";
    
    [self.navigationController pushViewController:rule animated:YES];
}

- (IBAction)onClickInvoiceBtn:(id)sender {
    
    RuleViewController *rule = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
    rule.vcTitle = @"发票";
    rule.urlString = @"www.baidu.com";
    
    [self.navigationController pushViewController:rule animated:YES];
}


- (IBAction)onClickStarBtn:(UIButton*)sender {
    score = (int)sender.tag - 100;
    
    for (UIButton* starBtn in self.viewStars.subviews) {
        if (starBtn.tag > 100 && starBtn.tag <= 105) {
            if (starBtn.tag <= sender.tag) {
                starBtn.selected = YES;
            }else{
                starBtn.selected = NO;
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(score) forKey:[NSString stringWithFormat:@"scoreEvaluation_%@",_orderId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- Http Response

- (void)httpRequestFinished:(NSNotification *)notification{
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    int type = resultData.requestType;
    [self stopWait];
    NSDictionary* dataDic = resultData.data;
    
    if (type == KRequestType_FerryReviewsGet) {
        
        if (resultData.resultCode == 0) {
        
            NSArray *listArr = dataDic[@"list"];
            
            NSLog(@"list arr = %lu", (unsigned long)listArr.count);
            
            if ([listArr count] > 0) {
                
                [_evaluationContentText setUserInteractionEnabled:NO];
                
                [_evaluationContentText setText:[listArr firstObject][@"content"]];
                [_submitEvaluationButton setHidden:YES];

                score = [[listArr firstObject][@"score"] intValue];
                
                for (UIButton* starBtn in self.viewStars.subviews) {
                    if (starBtn.tag > 100 && starBtn.tag <= 105) {
                        
                        [starBtn setImage:[UIImage imageNamed:@"star_nor"] forState:0];
                        [starBtn setImage:[UIImage imageNamed:@"star_press"] forState:UIControlStateSelected];
                        starBtn.selected = NO;
                        
                        if (starBtn.tag <= 100 + score) {
                            starBtn.selected = YES;
                        }
                        
                        starBtn.userInteractionEnabled = NO;
                    }
                }

            }else{
                
                [_evaluationContentText setUserInteractionEnabled:YES];
                [_submitEvaluationButton setHidden:NO];
                
                score = 0;
                
                for (UIButton* starBtn in self.viewStars.subviews) {
                    if (starBtn.tag > 100 && starBtn.tag <= 105) {
                        
                        [starBtn setImage:[UIImage imageNamed:@"star_nor"] forState:0];
                        [starBtn setImage:[UIImage imageNamed:@"star_press"] forState:UIControlStateSelected];
                        starBtn.selected = NO;
                        
                        starBtn.userInteractionEnabled = YES;
                        
                    }
                }
            }
        }
    }

    else if (type == KRequestType_FerryReviewsPost) {
        
        if (resultData.resultCode == 0) {
            [_evaluationContentText resignFirstResponder];
            
            [MBProgressHUD showTip:@"提交评价成功" WithType:FNTipTypeSuccess];
            
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:[NSString stringWithFormat:@"HaveEvaluation_%@",_orderId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (_evaluationTypeId == 3) {
                
                CarpoolTravelingViewController *travelVC = nil;
                
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    
//                    NSLog(@"NSStringFromClass=%@",NSStringFromClass([vc class]));
                    
                    if ([vc isKindOfClass:[CarpoolTravelingViewController class]]) {
                        
                        travelVC = (CarpoolTravelingViewController *)vc;
                    }
                }
                if (travelVC) {
                    [self.navigationController popToViewController:travelVC animated:YES];
                }else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }else{
                [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
            }
        }
    }else if (type == KRequestType_FerryOrderCheck){
        
        if ([resultData.data[@"resultState"] intValue] == 1) { //订单是否提交成功 resultState=1成功 0 不成功
            
            _orderDetailModel = [[TFCarOrderDetailModel alloc] initWithDictionary:resultData.data[@"order"]];
            [self setOwerInformation];
            
            //            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[dic[@"order"][@"state"] intValue]);
        }
    }
}

- (void)httpRequestFailed:(NSNotification *)notification{
    
//    [super httpRequestFailed:notification];
    
    [self stopWait];
    
    NSDictionary *dict = notification.object;
    
    NSError *error = [dict objectForKey:@"error"];
    int type = [[dict objectForKey:@"type"] intValue];
    
    DBG_MSG(@"httpRequestFailed: error = %@", error);
    
    if (type != KRequestType_FerryOrderCheck) {
        if (error.code == 401 || error.code == 403) {
            //        [self showTipsView:@"鉴权失效，请登录！"];
            //鉴权失效重置token
            [[UserPreferences sharedInstance] setToken:nil];
            [[UserPreferences sharedInstance] setUserId:nil];
            
            // 进入登录界面
            [LoginViewController presentAtViewController:self completion:^{
                [self showTip:@"请登录！" WithType:FNTipTypeFailure];
            }callBalck:^(BOOL isSuccess, BOOL needToHome) {
                if (!isSuccess && [self isKindOfClass:NSClassFromString(@"TravelHistoryViewController")]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else if(isSuccess){
                    if (type == KRequestType_FerryReviewsGet) {
                        [self requstGetFerryReviewsInfo];
                    }else if(type == KRequestType_FerryReviewsPost){
                        [self requestSubmitReviews];
                    }
                }
                
            }];
            
            //重置别名
            [[PushConfiguration sharedInstance] resetAlias];
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:DefaultStr]) {
        textView.text = @"";
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notif {

    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    CGRect rectForSelfView = self.view.frame;
    rectForSelfView.origin.y = -rect.size.height + 64;
    self.view.frame = rectForSelfView;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notif {

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    CGRect rectForSelfView = self.view.frame;
    rectForSelfView.origin.y = 64;
    self.view.frame = rectForSelfView;
    [UIView commitAnimations];
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
