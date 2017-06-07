//
//  TianFuCarPayVC.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/30.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "TFCarOrderDetailModel.h"

@interface TianFuCarPayVC : UserBaseUIViewController


//@property (nonatomic,strong)NSDictionary* userInfo;
@property (nonatomic,strong)TFCarOrderDetailModel* orderDetailModel;
@property (nonatomic,strong)NSString* orderId;
@end
