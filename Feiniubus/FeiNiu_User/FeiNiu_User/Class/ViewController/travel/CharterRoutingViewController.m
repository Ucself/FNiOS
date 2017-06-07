//
//  CharterRoutingViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/25.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterRoutingViewController.h"
#import "CharterOrderItem.h"
#import <WebImage/WebImage.h>
#import "OrderReview.h"

@interface CharterRoutingViewController ()<RatingBarDelegate, UITextViewDelegate>{
    OrderReview *_suborderReview;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivBusIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblBusLisence;
@property (weak, nonatomic) IBOutlet UILabel *lblSeatNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblBuslevel;
@property (weak, nonatomic) IBOutlet RatingBar *routingBusHistory;
@property (weak, nonatomic) IBOutlet UILabel *lblBusScore;
@property (weak, nonatomic) IBOutlet RatingBar *rateBarBus;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *tvRateBus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightRateBus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *ivDriverIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverPhone;
@property (weak, nonatomic) IBOutlet RatingBar *ratingDriverHistory;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverScore;
@property (weak, nonatomic) IBOutlet RatingBar *rateBarDriver;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *tvRateDriver;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightRateDriver;

@end

@implementation CharterRoutingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评价";
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(actionSubmit:)];
    self.navigationItem.rightBarButtonItem = submitItem;
    
    [self setupUI];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestReviewsList];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    
    [self.routingBusHistory setImageDeselected:@"small_star_nor" halfSelected:@"small_star_half" fullSelected:@"small_star_press" andDelegate:nil];
    self.routingBusHistory.isIndicator = YES;
    [self.ratingDriverHistory setImageDeselected:@"small_star_nor" halfSelected:@"small_star_half" fullSelected:@"small_star_press" andDelegate:nil];
    self.ratingDriverHistory.isIndicator = YES;

    [self.rateBarBus setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    [self.rateBarDriver setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    
    self.tvRateBus.placeholder = @"请输入评价内容, 最多50字";
    self.tvRateBus.clipsToBounds = YES;
    self.tvRateBus.layer.cornerRadius = 3;
    self.tvRateBus.layer.masksToBounds = YES;
    self.tvRateBus.layer.borderWidth = 0.6;
    self.tvRateBus.layer.borderColor = [UIColorFromRGB(0xFF9E05) CGColor];
    
    self.tvRateDriver.placeholder = @"请输入评价内容, 最多50字";
    self.tvRateDriver.clipsToBounds = YES;
    self.tvRateDriver.layer.cornerRadius = 3;
    self.tvRateDriver.layer.masksToBounds = YES;
    self.tvRateDriver.layer.borderWidth = 0.6;
    self.tvRateDriver.layer.borderColor = [UIColorFromRGB(0xFF9E05) CGColor];
    
    self.lblBusLisence.text = self.suborder.bus.licensePlate;
    self.lblBuslevel.text = [NSString stringWithFormat:@"%@%@", self.suborder.bus.typeName, self.suborder.bus.levelName];
    self.lblSeatNumber.text = [NSString stringWithFormat:@"%@座", @(self.suborder.bus.seat)];
    self.lblBusScore.text = [NSString stringWithFormat:@"%@分", @(self.suborder.bus.score)];
    [self.routingBusHistory displayRating:self.suborder.bus.score];
    
    self.lblDriverName.text = self.suborder.driver.driverName;
    self.lblDriverPhone.text = self.suborder.driver.driverPhone;
    [self.ratingDriverHistory displayRating:self.suborder.driver.driverScore];
    self.lblDriverScore.text = [NSString stringWithFormat:@"%d分", (int)self.suborder.driver.driverScore];
    
    [self.ivDriverIcon sd_setImageWithURL:[NSURL URLWithString:self.suborder.driver.driverAvtar] placeholderImage:[UIImage imageNamed:@"driver_def"]];
}

- (void)setupReviewContent{
    if (_suborderReview && _suborderReview.vehicleAppraises && _suborderReview.vehicleAppraises.count > 0) {
        ReviewItem *busReview = _suborderReview.vehicleAppraises[0];
        
        [self.rateBarBus displayRating:busReview.appraiseLevel];
        self.rateBarBus.isIndicator = YES;
        self.tvRateBus.text = busReview.content;
        self.tvRateBus.editable = NO;
        self.heightRateBus.constant = 100;
        [self.view layoutIfNeeded];
    }
    
    if (_suborderReview && _suborderReview.driverAppraises && _suborderReview.driverAppraises.count > 0) {
        ReviewItem *driverReview = _suborderReview.driverAppraises[0];
        
        [self.rateBarDriver displayRating:driverReview.appraiseLevel];
        self.rateBarDriver.isIndicator = YES;
        self.tvRateDriver.text = driverReview.content;
        self.tvRateDriver.editable = NO;
        self.heightRateDriver.constant = 100;
        [self.view layoutIfNeeded];
    }
    
    if (_suborderReview.isAppraiseDriver && _suborderReview.isAppraiseVehicle) {
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"已评价";
    }
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        [textView resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomScrollView.constant = 0;
            [self.view layoutIfNeeded];
        }];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomScrollView.constant = 200;
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        if (textView == self.tvRateDriver) {
            [self.scrollView scrollRectToVisible:self.tvRateDriver.superview.superview.frame animated:YES];
        }
    }];
}
#pragma mark - Http Request
- (void)requestReviewsList{
    if (!self.suborder || !self.suborder.subOrderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderReviewsList params:^(NetParams *params) {
        params.data = @{@"type":@1,
                        @"orderId":self.suborder.subOrderId};
    }];
}
#pragma mark - 
- (void)actionSubmit:(UIBarButtonItem *)sender{
    
    if (!self.suborder || !self.suborder.subOrderId) {
        return;
    }
    NSMutableDictionary *dic = [@{@"driverScores" : @(self.rateBarDriver.rating),
                                 @"vehicleScores" : @(self.rateBarBus.rating)} mutableCopy];
    if (self.tvRateBus.text && ![self.tvRateBus.text isEqualToString:self.tvRateBus.placeholder]) {
        [dic setObject:self.tvRateBus.text forKey:@"vehicleContent"];
    }else{
        [self showTip:@"对该BUS说点什么吧～" WithType:FNTipTypeWarning hideDelay:1.5];
    }
    if (self.tvRateDriver.text && ![self.tvRateDriver.text isEqualToString:self.tvRateDriver.placeholder]) {
        [dic setObject:self.tvRateDriver.text forKey:@"driverContent"];
    }else{
        [self showTip:@"对司机说点什么吧～" WithType:FNTipTypeWarning hideDelay:1.5];
    }
    [dic setObject:@(1) forKey:@"orderType"];
    [dic setObject:self.suborder.subOrderId forKey:@"orderId"];
    

    [NetManagerInstance sendRequstWithType:FNUserRequestType_Rating params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = dic;
    }];
}
#pragma mark - 
- (void)ratingBar:(RatingBar*)ratingBar newRating:(float)newRating{
    if (ratingBar == self.rateBarBus) {
        [UIView animateWithDuration:0.25 animations:^{
            self.heightRateBus.constant = 100;
            [self.view layoutIfNeeded];
        }];
    }else if (ratingBar == self.rateBarDriver){
        [UIView animateWithDuration:0.25 animations:^{
            self.heightRateDriver.constant = 100;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - 
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_Rating) {
        NSInteger code = [resultData.data[@"code"] integerValue];
        if (code == 0) {
            [self showTip:@"评论成功" WithType:FNTipTypeSuccess];
        }else{
            NSString *msg = resultData.data[@"message"];
            [self showTip:msg WithType:FNTipTypeFailure];
        }
    }else if (type == FNUserRequestType_CharterOrderReviewsList){
        NSInteger code = [resultData.data[@"code"] integerValue];
        if (code == 0) {
            _suborderReview = [[OrderReview alloc]initWithDictionary:resultData.data];
            [self setupReviewContent];
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
