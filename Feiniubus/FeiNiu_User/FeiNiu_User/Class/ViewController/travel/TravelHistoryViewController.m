//
//  TravelHistoryViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "TravelHistoryViewController.h"
#import "CharterOrderItem.h"
#import "CharteredTravelingViewController.h"
#import "CharterListViewController.h"
#import "CarpoolListViewController.h"
#import "CityCarpoolListViewController.h"
#import "UIColor+Hex.h"
#import "MainViewController.h"
#import "UserCustomAlertView.h"

@interface TravelHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblCreateDate;
@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblEndName;
@property (nonatomic, strong) CharterOrderItem *orderItem;
@end

@implementation TravelHistoryCell

- (void)setOrderItem:(CharterOrderItem *)orderItem{
    _orderItem = orderItem;
    self.lblCreateDate.text = [orderItem.createTime timeStringByDefault];
    self.lblStartName.text = orderItem.startingName;
    self.lblEndName.text = orderItem.destinationName;
}

@end



@interface TravelHistoryViewController ()<UIScrollViewDelegate, UserCustomAlertViewDelegate>
{
    BOOL bEdit;
}

@property (weak, nonatomic) IBOutlet UIView *slider;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnCityCarpool;

@property (weak, nonatomic) IBOutlet UIButton *btnCarpool;
@property (weak, nonatomic) IBOutlet UIButton *btnChartered;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSlider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBtmCons;
@end

@implementation TravelHistoryViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"TravelHistoryViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self carpoolListVC] refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForLoginSuccess) name:@"LoginSuccessNotification" object:nil];

    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btnRight setTitle:@"编辑" forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRight.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnRight addTarget:self action:@selector(btnEditClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = item;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnBackClick:(id)sender{
    
    UIViewController *target = nil;
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MainViewController class]]) {
            target = controller;
        }
    }
    if (target) {
        
//        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.navigationController popToViewController:target animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbkgreen"] forBarMetrics:UIBarMetricsDefault];
//    [self.tableViewChartered.header beginRefreshing];;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self scrollViewDidEndDecelerating:self.scrollView];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if ([self currentPage] == 0) {
//        [[self cityCarpooListVC] refresh];
//    }
//    else if ([self currentPage] == 1) {
//        [[self carpoolListVC] refresh];
//    }else {
//        [[self charterListVC] refresh];
//    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - PrivateMethods
- (CharterListViewController *)charterListVC{
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[CharterListViewController class]]) {
            return (CharterListViewController *)vc;
        }
    }
    return nil;
}
- (CarpoolListViewController *)carpoolListVC{
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[CarpoolListViewController class]]) {
            return (CarpoolListViewController *)vc;
        }
    }
    return nil;
}
- (CityCarpoolListViewController *)cityCarpooListVC{
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[CityCarpoolListViewController class]]) {
            return (CityCarpoolListViewController *)vc;
        }
    }
    return nil;
}
- (NSInteger)currentPage{
    return self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}
- (NSArray<UIButton *> *)naviButtons{
    NSArray *array;
    @try {
        array = @[self.btnCarpool, self.btnCityCarpool, self.btnChartered];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        return array;
    }
}

- (IBAction)btnDeleteClick:(id)sender {
    UserCustomAlertView *alertView = [UserCustomAlertView alertViewWithTitle:@"删除订单" message:@"您是否确定删除选的订单?" delegate:self buttons:@[@"确定删除", @"我再想想"]];
    
    [alertView showInView:self.view];
}

-(void)btnEditClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    bEdit = !bEdit;
    if (bEdit) {
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        if ([self currentPage] == 0) {
            [[self carpoolListVC] setEditMode:bEdit];
        }else if([self currentPage] == 1){
            //[[self cityCarpooListVC] refresh];
        }
        
        [UIView animateWithDuration:.6 animations:^{
            _viewBtmCons.constant = 0;
        }];
    }
    else {
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
        
        if ([self currentPage] == 0) {
            [[self carpoolListVC] setEditMode:bEdit];
        }else if([self currentPage] == 1){
            //[[self cityCarpooListVC] refresh];
        }
        
        [UIView animateWithDuration:.6 animations:^{
            _viewBtmCons.constant = 45;
        }];
    }
    
}

- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (btnIndex == 0) {
        switch ([self currentPage]) {
            case 0:
                [[self carpoolListVC] deleteAction];
                break;
            case 1:
                [[self cityCarpooListVC] deleteAction];
                break;
            case 2:
                [[self charterListVC] deleteAction];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - RequestMethods
// 获取拼车订单列表
- (void)requestCarpoolList{
    
}

- (void)requestForLoginSuccess{
    [[self carpoolListVC] refresh];
}


#pragma mark-
- (IBAction)btnCityCarpoolClick:(UIButton *)sender {
    NSInteger index = 1;
    [self moveSlider:self.view.frame.size.width / 2 * index];

    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width* index, 0) animated:YES];

//    [self.scrollView scrollRectToVisible:self.scrollView.bounds animated:YES];
}

- (IBAction)btnCarpoolClick:(id)sender {
    NSInteger index = 0;
    [self moveSlider:self.view.frame.size.width / 2 * index];
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width* index, 0) animated:YES];
}

- (IBAction)btnCharteredClick:(id)sender {
    NSInteger index = 1;
    [self moveSlider:self.view.frame.size.width / 3 * index];
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width* index, 0) animated:YES];

//    [self.scrollView scrollRectToVisible:CGRectOffset(self.scrollView.bounds, self.scrollView.bounds.size.width * 2, 0) animated:YES];
}

-(void)moveSlider:(int)x{    
    [UIView animateWithDuration:0.4 animations:^{
        self.leadingSlider.constant = x;
        [self.slider.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        if ([self currentPage] == 0) {
            if ([self carpoolListVC].dataList.count <= 0) {
                [[self carpoolListVC] refresh];
            }
        }else if([self currentPage] == 1){
            if ([self cityCarpooListVC].dataList.count <= 0) {
                [[self cityCarpooListVC] refresh];
            }
        }else{
            if ([self charterListVC].dataList.count <= 0) {
                [[self charterListVC] refresh];
            }
        }
        [[self naviButtons] enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == [self currentPage]) {
                [obj setTitleColor:[UIColor colorWithHex:GloabalTintColor] forState:UIControlStateNormal];
            }else{
                [obj setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
            }
        }];
    }];
    
}

#pragma mark --- UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.view.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //NSLog(@"page=%d", page);
    
    [self moveSlider:self.view.frame.size.width / 2 * page];
}

@end
