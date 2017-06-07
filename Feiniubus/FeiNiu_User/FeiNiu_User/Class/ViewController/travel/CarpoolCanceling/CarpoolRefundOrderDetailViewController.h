//
//  CarpoolRefundOrderDetailViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"

@class CarpoolOrderItem;

@interface CarpoolRefundOrderDetailViewController : UserBaseUIViewController
@property (nonatomic, strong) CarpoolOrderItem *carpoolOrderItem;
@end
