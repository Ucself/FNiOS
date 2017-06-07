//
//  TFCarEvaluationVC.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "TFCarOrderDetailModel.h"


@interface TFCarEvaluationVC : UserBaseUIViewController

@property (nonatomic,strong)NSString* orderId;
@property (nonatomic,strong)TFCarOrderDetailModel* orderDetailModel;
@property (nonatomic,assign)BOOL isLook;
@property (nonatomic,assign)BOOL isTianFuCar;
@property (nonatomic,assign)int evaluationTypeId;

@end
