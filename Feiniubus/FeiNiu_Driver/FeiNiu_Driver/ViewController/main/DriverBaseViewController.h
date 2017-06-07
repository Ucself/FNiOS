//
//  DriverBaseViewController.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/9/24.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIViewController.h>

@interface DriverBaseViewController : BaseUIViewController

#pragma mark --- 数据请求返回通知

-(void)httpRequestFinished:(NSNotification *)notification;
-(void)httpRequestFailed:(NSNotification *)notification;

@end
