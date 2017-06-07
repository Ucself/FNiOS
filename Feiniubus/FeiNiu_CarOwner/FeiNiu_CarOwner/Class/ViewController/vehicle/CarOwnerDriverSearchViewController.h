//
//  CarOwnerCompanySearchViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"

@protocol CarOwnerDriverSearchViewControllerDelegate <NSObject>

-(void)seachSelected:(NSObject*)Infor;

@end

@interface CarOwnerDriverSearchViewController : CarOwnerBaseViewController

@property(nonatomic, assign) id<CarOwnerDriverSearchViewControllerDelegate> delegate;

@end
