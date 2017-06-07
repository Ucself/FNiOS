//
//  EditCharterViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/18.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNUIView/BaseUIViewController.h>
#import <FNUIView/HMSegmentedControl.h>
@interface EditCharterViewController : BaseUIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (strong, nonatomic)UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet HMSegmentedControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;
@property (strong, nonatomic)NSMutableArray *pages;
- (void)setupPagesFromStoryboardWithIdentifiers:(NSArray *)identifiers;
- (void)setPageControlHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setSelectedPageIndex:(NSUInteger)index animated:(BOOL)animated;
- (UIViewController *)selectedController;
- (void)updateTitleLabels;
@end
