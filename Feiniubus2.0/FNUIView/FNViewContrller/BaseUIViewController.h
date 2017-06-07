//
//  BaseUIViewController.h
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
//
//  UIViewController基础类

#import <UIKit/UIKit.h>


//#import "NetInterfaceManager.h"
#import <FNNetInterface/NetInterfaceManager.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
//#import <FNDataModule/ResultDataModel.h>
#import <FNCommon/FNCommon.h>

#import <FNUIView/TipsView.h>

@class Reachability;

//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND
//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS
#import <FNUIView/Masonry.h>

@class BaseUIViewController;
@protocol BaseUIViewControllerDelegate <NSObject>

-(void)controllerBack:(BaseUIViewController*)controller data:(id)data;

@end

@interface BaseUIViewController : UIViewController

@property(nonatomic, assign) id delegate;
//返回顶部按钮
@property(nonatomic, strong) UIButton *btnGotoTop;

/**
 *  实例从storyboard初始化方法, 类名必须与storyboardIdentifier相同
 *
 *  @param storyboardName storyboard文件名
 *
 *  @return viewcontroller实例
 */
+ (instancetype)instanceWithStoryboardName:(NSString*)storyboardName;

-(void)popViewController;

//提示信息
- (void) showTipsView:(NSString*)tips;
- (void) showTipsView:(NSString*)tips alignment:(ShowAlignment)alignment;

- (void) showAlertWithTitle:(NSString*)title msg:(NSString*)msg;
- (void) showAlertWithTitle:(NSString*)title msg:(NSString*)msg showCancel:(BOOL)showCancel;

- (void) startWait;
- (void) stopWait;

-(void)httpRequestFinished:(NSNotification *)notification;
-(void)httpRequestFailed:(NSNotification *)notification;

#pragma mark- system notification
-(void)onApplicationEnterBackGround;
-(void)onApplicationBecomeActive;

-(void)btnBackClick:(id)sender;
-(void)addGotoTopButton:(UIView*)blowView;
-(void)showGotoTopButton:(BOOL)show;
-(void)showGotoTopButton:(BOOL)show offset:(int)offset;
@end
