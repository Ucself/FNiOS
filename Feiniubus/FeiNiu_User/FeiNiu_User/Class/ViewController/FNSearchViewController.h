//
//  FNInputLocationViewController.h
//  FNMap
//
//  Created by 易达飞牛 on 15/8/6.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//
// 地点输入选择controller

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@class FNLocation;
@class FNSearchViewController;

@protocol FNSearchViewControllerDelegate <NSObject>

- (void)searchViewController:(FNSearchViewController *)searchViewController didSelectLocation:(FNLocation *)location;
@end

@interface FNSearchViewController : BaseUIViewController

@property(nonatomic, assign) id fnSearchDelegate;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) BOOL isShowTopTableView;

//后添加
//@property (nonatomic,strong) AMapSearchAPI *search;

@end
