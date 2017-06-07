//
//  CarpoolRefundConfirmViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/25.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"

@class CarpoolOrderItem;

@interface CarpoolRefundConfirmViewController : UserBaseUIViewController
@property (nonatomic, strong) CarpoolOrderItem *orderItem;
@end
