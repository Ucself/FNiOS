//
//  InvoiceViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@interface InvoiceViewController : UserBaseUIViewController
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *orderId;
@end
