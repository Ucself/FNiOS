//
//  FNSearchMapViewController.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/23.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNUIView/FNUIView.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@class FNLocation;
@class FNSearchMapViewController;

@protocol FNSearchMapViewControllerDelegate <NSObject>

- (void)searchMapViewController:(FNSearchMapViewController *)searchMapViewController didSelectLocation:(FNLocation *)location;
@end

@interface FNSearchMapViewController : BaseUIViewController

@property(nonatomic, copy) NSString *adcode;                       //城市编码
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;    //需要显示的位置坐标

@property(nonatomic, assign) id fnMapSearchDelegate;

@property(nonatomic,copy) NSString *navTitle;

@property(nonatomic, assign) int type;  //1,3,5为接,,,2,4,6为送

@property(nonatomic, assign) BOOL isShuttleBus;      //YES接送车, NO通勤车

@end
