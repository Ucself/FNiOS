//
//  CharterDetailPayViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/14.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterDetailPayTipsViewController.h"
#import "CharterOrderItem.h"
#import "CharterPayViewController.h"
#import "PushNotificationAdapter.h"


@implementation CharterDetailPayTipsViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.lblPrice.text = @(self.suborder.price / 100.0f).stringValue;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentBottom.constant = 0;
        [self.view layoutIfNeeded];
//        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            CGRect frame = obj.frame;
//            frame.origin.y = self.view.frame.size.height - obj.frame.size.height;
//            obj.frame = frame;
//        }];
    }completion:^(BOOL finished) {
        //        self.contentBottom.constant = 0;
        //        [self.view layoutIfNeeded];
        
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}
- (IBAction)actionPay:(UIButton *)sender {
    

    [UIView animateWithDuration:0.25 animations:^{
        self.contentBottom.constant = -120;
        [self.view layoutIfNeeded];

//        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            CGRect frame = obj.frame;
//            frame.origin.y = self.view.frame.size.height;
//            obj.frame = frame;
//        }];
    }completion:^(BOOL finished) {
        CharterPayViewController *payVC = [CharterPayViewController instanceFromStoryboard];
        payVC.suborderItem = self.suborder;
        [self.navigationController pushViewController:payVC animated:YES];
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
- (IBAction)actionCancel:(UIButton *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentBottom.constant = -120;
        [self.view layoutIfNeeded];
//        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            CGRect frame = obj.frame;
//            frame.origin.y = self.view.frame.size.height;
//            obj.frame = frame;
//        }];
    }completion:^(BOOL finished) {
        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
    }];
}


@end

@interface CharterPayTipSegue : UIStoryboardSegue

@end
@implementation CharterPayTipSegue

- (void)perform{
    [self.sourceViewController addChildViewController:self.destinationViewController];

    [self.sourceViewController.view addSubview:self.destinationViewController.view];
    self.destinationViewController.view.frame = self.sourceViewController.view.bounds;
//    self.destinationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end