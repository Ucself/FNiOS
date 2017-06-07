//
//  SelectDestViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIViewController.h>
#import "UserBaseUIViewController.h"

@protocol SelectDestViewControllerDelegate <NSObject>

- (void)chooseAddressClick:(int)pageId selectInfor:(id)selectInfor;

@end

@interface SelectDestViewController : UserBaseUIViewController

@property (nonatomic, assign)   int pageId;             //0代码查找起点城市 1代表查询终点城市
@property (nonatomic, strong)   NSString *adCodeId;     //起始城市的code 只有在选择终点的时候才用
@property (nonatomic, strong)   NSString* defaultName;  //已选的城市名称
@property (nonatomic ,assign)   id<SelectDestViewControllerDelegate> delegate;

@end
