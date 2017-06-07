//
//  GuideViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import "GuideViewController.h"

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
}

- (IBAction)btnDone:(id)sender {
    [self performSegueWithIdentifier:@"tomainview" sender:nil];
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
