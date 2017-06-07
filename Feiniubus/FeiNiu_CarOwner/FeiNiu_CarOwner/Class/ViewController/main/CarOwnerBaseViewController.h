//
//  CarOwnerBaseViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/11/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIViewController.h>

@interface CarOwnerBaseViewController : BaseUIViewController

#pragma mark --- 数据请求返回通知

-(void)httpRequestFinished:(NSNotification *)notification;
-(void)httpRequestFailed:(NSNotification *)notification;


@end
