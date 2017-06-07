//
//  UnionPayViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"

@interface UnionPayViewController : UserBaseUIViewController
//@property (nonatomic, assign) CGFloat price;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *couponId;
@property (nonatomic, assign) NSInteger payOrderType;
@property (nonatomic, assign) NSInteger chargeType;
@end
