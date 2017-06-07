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

@property(nonatomic, assign) id searchMapViewDelegate;  //从地图页进来专用delegate

@property(nonatomic,copy) NSString *navTitle;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *city;

@property(nonatomic, assign) BOOL isShuttleBus;      //YES接送车, NO通勤车
//@property (nonatomic, assign) BOOL isShowTopTableView;

//后添加
//@property (nonatomic,strong) AMapSearchAPI *search;

@end
