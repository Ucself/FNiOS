//
//  CarpoolTravelStateViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "CarpoolTravelStatusProgressView.h"
@class CarpoolOrderItem;

@interface CarpoolTravelStateViewController : UserBaseUIViewController
+ (instancetype)instaceWithState:(OrderState)state;
@property (nonatomic, strong) CarpoolOrderItem *carpoolOrder;
@end

@interface CarpoolTravelWaitConfirmViewController : CarpoolTravelStateViewController

@end

@interface CarpoolTravelWaitPayViewController : CarpoolTravelStateViewController

@end

@interface CarpoolTravelIsPayViewController : CarpoolTravelStateViewController

@end

@interface CarpoolTravelPendingViewController : CarpoolTravelStateViewController

@end

// 评分（行程结束）
@interface CarpoolTravelRatingViewController : CarpoolTravelStateViewController

@end

// 已取消
@interface CarpoolTravelCancelViewController : CarpoolTravelStateViewController

@end