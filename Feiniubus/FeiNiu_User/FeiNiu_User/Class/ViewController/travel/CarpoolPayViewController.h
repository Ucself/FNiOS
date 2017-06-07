//
//  CarpoolPayViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
@class CarpoolOrderItem;

@interface CarpoolPayViewController : UserBaseUIViewController
@property (nonatomic, strong) CarpoolOrderItem *carpoolOrder;
@end
