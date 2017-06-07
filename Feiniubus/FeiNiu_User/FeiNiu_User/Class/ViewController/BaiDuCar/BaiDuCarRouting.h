//
//  BaiDuCarRouting.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/25.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "TFCarOrderDetailModel.h"

@interface BaiDuCarRouting : UserBaseUIViewController

@property (nonatomic,strong)NSString* orderId;
@property (nonatomic,strong)TFCarOrderDetailModel* orderDetailModel;
@property (nonatomic,assign) int routingTypeId;


@end
