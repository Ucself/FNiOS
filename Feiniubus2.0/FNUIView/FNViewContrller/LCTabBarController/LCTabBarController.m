//
//  LCTabBarController.m
//  LuoChang
//
//  Created by Rick on 15/4/29.
//  Copyright (c) 2015年 Rick. All rights reserved.
//
#define  kContentFrame  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-kTabbarHeight)
#define  kDockFrame CGRectMake(0, self.view.frame.size.height-kTabbarHeight, self.view.frame.size.width, kTabbarHeight)

#define kCameraViewWidth 49
#define kCameraViewHeight 61
#define kCameraBtnWidth kCameraViewWidth
#define kCameraBtnHeight 50

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "LCTabBarController.h"
#import "LCTabbar.h"
@interface LCTabBarController ()<UINavigationControllerDelegate,LCTabBarDelegate>

@end

@implementation LCTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self setNavigationTheme];
    for (UINavigationController *navVC in self.viewControllers) {
        navVC.delegate = self;
    }
    
    self.tabBar.hidden = YES;
    LCTabbar *lctabBar = [[LCTabbar alloc]initWithFrame:self.tabBar.bounds];
    lctabBar.delegate = self;
    //    [self.tabBar addSubview:tabBar];
    CGRect frame = lctabBar.frame;
    lctabBar.frame = CGRectMake(0, self.view.frame.size.height-kTabbarHeight, frame.size.width, kTabbarHeight);
    self.mytabbar = lctabBar;
    //    lctabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TabBaBack"]];
    lctabBar.backgroundColor = [UIColor whiteColor];
    //设置一个上边框
    CALayer *upBorder = [CALayer layer];
    upBorder.frame = CGRectMake(0.0f, 0.0f, lctabBar.bounds.size.width, 1.0f);
    upBorder.backgroundColor = UIColorFromRGB(0xE1E0E0).CGColor;
    [lctabBar.layer addSublayer:upBorder];
    [self.view addSubview:lctabBar];
    
    
    _cameraView =[[UIView alloc]init];
    _cameraView.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-(kCameraViewHeight*0.5));
    _cameraView.bounds = CGRectMake(0, 0, kCameraViewWidth, kCameraViewHeight);
//    _cameraView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabMiddleBgIcon"]];
    //顶部供线
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabMiddleBgIcon"]];
    [topImageView setFrame:CGRectMake(-2, 0, kCameraViewWidth + 4, 13 )];
    [_cameraView addSubview:topImageView];
    //    _cameraView.backgroundColor = [UIColor blackColor];
    _cameraBtn = [[UIButton alloc]init];
    [_cameraBtn setBackgroundImage:[UIImage imageNamed:@"TabBarGrabOrder"] forState:UIControlStateNormal];
    [_cameraBtn setBackgroundImage:[UIImage imageNamed:@"TabBarGrabOrderSel"] forState:UIControlStateSelected];
    _cameraBtn.frame = CGRectMake(0, 7, kCameraBtnWidth, kCameraBtnHeight);
    _cameraBtn.tag = 2;
    [_cameraBtn addTarget:self action:@selector(cameraClick:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraView addSubview:_cameraBtn];
    [self.view addSubview:_cameraView];
    //默认选择中间的抢单
    [self cameraClick:_cameraBtn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//
///**
// *  设置导航栏以及信号栏主题样式
// */
//-(void) setNavigationTheme{
//
//    //操作整个应用中的所有导航栏，只需要给它设置就可以了
//    UINavigationBar *navBar = [UINavigationBar appearance];
//    navBar.tintColor = [UIColor whiteColor];
//    //设置导航栏标题颜色
//    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//
//}




-(void)cameraClick:(UIButton *)btn{
    
    [(LCTabbar*)self.mytabbar btnClick:btn];
    
    self.selectedIndex = btn.tag;
}

-(void)changeNav:(NSInteger)from to:(NSInteger)to{
    self.selectedIndex = to;
}
#pragma mark navVC代理
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *root = navigationController.viewControllers.firstObject;
    if (viewController != root) {
        //更改导航控制器的高度
        navigationController.view.frame = self.view.bounds;
        //从HomeViewController移除
        [_mytabbar removeFromSuperview];
        [_cameraView removeFromSuperview];
        // 调整tabbar的Y值
        CGRect dockFrame = _mytabbar.frame;
        CGRect cameraViewFrame = _cameraView.frame;
        if ([root.view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollview = (UIScrollView *)root.view;
            dockFrame.origin.y = scrollview.contentOffset.y + root.view.frame.size.height - kTabbarHeight;
            cameraViewFrame.origin.y = scrollview.contentOffset.y + root.view.frame.size.height -kTabbarHeight - (kCameraViewHeight - kCameraViewWidth);
        } else {
            // dockFrame.origin.y -= kDockHeight;
            cameraViewFrame.origin.y = root.view.frame.size.height -kCameraViewHeight;
            dockFrame.origin.y = root.view.frame.size.height - kTabbarHeight;
        }
        _mytabbar.frame = dockFrame;
        
        _cameraView.frame = cameraViewFrame;
        
        //添加dock到根控制器界面
        [root.view addSubview:_mytabbar];
        [root.view addSubview:_cameraView];
    }
}



-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *root = navigationController.viewControllers[0];
    if (viewController == root) {
        // 更改导航控制器view的frame
        navigationController.view.frame = kContentFrame;
        
        // 让Dock从root上移除
        [_mytabbar removeFromSuperview];
        [_cameraView removeFromSuperview];
        
        //_mytabbar添加dock到HomeViewController
        _mytabbar.frame = kDockFrame;
        [self.view addSubview:_mytabbar];
        
        _cameraView.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-(kCameraViewHeight*0.5));
        _cameraView.bounds = CGRectMake(0, 0, kCameraViewWidth, kCameraViewHeight);
        [self.view addSubview:_cameraView];
        //        [[UIApplication sharedApplication].keyWindow addSubview:_cameraView];
    }
    
}
@end
