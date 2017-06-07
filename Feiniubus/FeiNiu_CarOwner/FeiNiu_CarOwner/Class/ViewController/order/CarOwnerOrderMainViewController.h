//
//  CarOwnerOrderMainViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"

@interface CarOwnerOrderMainViewController : CarOwnerBaseViewController

//新订单
@property (nonatomic,strong) NSMutableArray *subOrder;
//支付订单
@property (nonatomic,strong) NSMutableArray *paySuccessSubOrder;
//未支付订单
@property (nonatomic,strong) NSMutableArray *stayPaySuborder;
//失败的订单
@property (nonatomic,strong) NSMutableArray *failSubOrder;

@end
