//
//  LoadingViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/30.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "LoadingViewController.h"
//#import "UIView+Size.h"

@interface LoadingViewController()
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIImageView *ivCloud;
@property (weak, nonatomic) IBOutlet UIImageView *ivWheelLeft;
@property (weak, nonatomic) IBOutlet UIImageView *ivWheelRight;
@property (weak, nonatomic) IBOutlet UIImageView *ivBus;
- (void)showInVC:(UIViewController *)vc;
- (void)hide;
@end
NSInteger loadingTag = 0x1001;

@implementation LoadingViewController
+ (void)showInWindow{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *loadingView = [window viewWithTag:loadingTag];
    if (loadingView) {
        return;
    }
    LoadingViewController *loading = [[[NSBundle mainBundle] loadNibNamed:@"LoadingViewController" owner:self options:nil] firstObject];
    loading.view.frame = window.bounds;
    loading.view.tag = loadingTag;
    UIView *hud = nil;
    for (UIView *subView in window.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"MBProgressHUD")]) {
            hud = subView;
            break;
        }
    }
    if (hud) {
        [window insertSubview:loading.view belowSubview:hud];
    }else{
        [window addSubview:loading.view];
    }
    [loading beginAnimate];
}
+ (void)hideLoadingViewInWindow{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *loadingView = [window viewWithTag:loadingTag];
    if (loadingView) {
        [loadingView removeFromSuperview];
    }
}
+ (void)showInViewController:(UIViewController *)vc{
    __block BOOL showing = NO;
    [vc.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LoadingViewController class]]) {
            showing = YES;
            *stop = YES;
        }
    }];
    if (showing) {
        return;
    }
    LoadingViewController *loading = [[[NSBundle mainBundle] loadNibNamed:@"LoadingViewController" owner:self options:nil] firstObject];
    if (loading) {
        [loading showInVC:vc];
    }
}

+ (void)hideLoadingViewInViewController:(UIViewController *)vc{
    [vc.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LoadingViewController class]]) {
            [(LoadingViewController *)obj hide];
        }
    }];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.viewContent.layer.cornerRadius = self.viewContent.frame.size.height / 2;
    self.viewContent.backgroundColor = [UIColor clearColor];
    self.viewContent.clipsToBounds = YES;
    
}

- (void)beginAnimate{
//    CABasicAnimation *contentAnimate = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    contentAnimate.fromValue = @(0.5);
//    contentAnimate.toValue = @1;
//    contentAnimate.duration = 0.15;
//    [self.viewContent.layer addAnimation:contentAnimate forKey:@"BusAnimate"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hide) withObject:nil afterDelay:30];
    
    CABasicAnimation *busAnimate = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    busAnimate.fromValue = @0;
    busAnimate.toValue = @1;
    busAnimate.duration = 0.2;
    busAnimate.autoreverses = YES;
    busAnimate.repeatCount = INT32_MAX;
    [self.ivBus.layer addAnimation:busAnimate forKey:@"BusAnimate"];
    
    CABasicAnimation *cloudAnimate = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    cloudAnimate.fromValue = @0;
    cloudAnimate.toValue = @(-self.viewContent.frame.size.width - 20);
    cloudAnimate.duration = 4;
    cloudAnimate.repeatCount = INT32_MAX;
    [self.ivCloud.layer addAnimation:cloudAnimate forKey:@"CloudAnimate"];
}

- (void)showInVC:(UIViewController *)vc{
    self.view.frame = vc.view.bounds;
    [vc.view addSubview:self.view];
    [vc addChildViewController:self];
    [self beginAnimate];
}
- (void)hide{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.ivBus.layer removeAllAnimations];
        [self.ivWheelRight.layer removeAllAnimations];
        [self.ivWheelLeft.layer removeAllAnimations];
        [self.ivCloud.layer removeAllAnimations];
        [UIView animateWithDuration:0.2 animations:^{
//            self.viewContent.transform = CGAffineTransformMakeScale(0.3, 0.3);
            self.viewContent.alpha = 0;
        }completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    });
}
@end
