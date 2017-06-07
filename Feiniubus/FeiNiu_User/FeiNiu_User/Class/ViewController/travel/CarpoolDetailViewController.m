//
//  CarpoolDetailViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolDetailViewController.h"
#import <FNUIView/RatingBar.h>
#import <FNUIView/CPTextViewPlaceholder.h>

@interface CarpoolDetailViewController () <RatingBarDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet RatingBar *ratingCar;
@property (weak, nonatomic) IBOutlet RatingBar *ratingDriver;

@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *textView;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end

@implementation CarpoolDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initUI];
}

-(void)initUI
{
    
    [_ratingCar setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    [_ratingDriver setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    
    _textView.placeholder = @"请输入评价内容, 最多50字";
    _textView.clipsToBounds = YES;
    _textView.layer.cornerRadius = 3;
    _textView.layer.masksToBounds = YES;
    _textView.layer.borderWidth = 0.6;
    _textView.layer.borderColor = [UIColorFromRGB(0xFF9E05) CGColor];
    
    _btnSubmit.clipsToBounds = YES;
    _btnSubmit.layer.cornerRadius = 3;
    _btnSubmit.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbktrans"] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbkgreen"] forBarMetrics:UIBarMetricsDefault];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)btnTest:(id)sender {
    

}

#pragma mark-
- (void)ratingBar:(RatingBar*)ratingBar newRating:(float)newRating
{
    
}

- (IBAction)btnInvoiceClick:(id)sender {
    [self performSegueWithIdentifier:@"toinvoice" sender:nil];
}
- (IBAction)btnDetailListClick:(id)sender {
    [self performSegueWithIdentifier:@"toDetailList" sender:nil];
}
@end
