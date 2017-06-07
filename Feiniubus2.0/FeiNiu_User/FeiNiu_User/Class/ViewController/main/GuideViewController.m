//
//  GuideViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import "GuideViewController.h"
#import "MainViewController.h"
#import "ContainerViewController.h"

#import <FNUIView/UINavigationController+FDFullscreenPopGesture.h>

@interface GuideViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation GuideViewController


- (void)viewDidLoad{
    
    [_pageControl setCurrentPage:0];
    
    self.fd_interactivePopDisabled = YES;
}
-(void)dealloc
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)btnDone:(id)sender {
    //[self performSegueWithIdentifier:@"tomainview" sender:nil];
    
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ContainerViewController *mainController = [storyboard instantiateViewControllerWithIdentifier:@"ContainerViewController"];
    [viewControllers removeLastObject]; //移除当前的
    [viewControllers addObject:mainController];
    //页面跳转
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x == 0) {
        _pageControl.currentPage = 0;
    }else if (scrollView.contentOffset.x == self.view.frame.size.width){
        _pageControl.currentPage = 1;
    }else if (scrollView.contentOffset.x == 2 * self.view.frame.size.width){
        _pageControl.currentPage = 2;
    }
}


@end
