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
#import <FNNetInterface/ProtocolBase.h>
#import <FNDataModule/ResultDataModel.h>
#import <FNDataModule/EnvPreferences.h>
#import <FNCommon/FNCommon.h>
#import <FNUIView/NetPrompt.h>

@class Reachability;

//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND
//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS
//#import "Masonry.h"
#import <FNUIView/Masonry.h>

#define KWindow [[UIApplication sharedApplication] keyWindow]

#define onePageNumber 7

@class BaseUIViewController;
@protocol BaseUIViewControllerDelegate <NSObject>

-(void)controllerBack:(BaseUIViewController*)controller data:(id)data;

@end

@interface BaseUIViewController : UIViewController
{
    NetPrompt * netPrompt;
    BOOL isShowNetPrompt;
    BOOL isShowRequestPrompt;
}
@property(nonatomic, assign) id delegate;

//返回顶部按钮
@property(nonatomic, strong) UIButton *btnGotoTop;

//提示信息
- (void) showTipsView:(NSString*)tips;
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
