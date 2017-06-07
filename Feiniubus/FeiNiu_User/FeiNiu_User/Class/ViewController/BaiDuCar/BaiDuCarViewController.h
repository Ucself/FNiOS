//
//  BaiDuCarViewController.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalloutView.h"
#import "CarpoolOrderItem.h"
#import "UserBaseUIViewController.h"

@interface BaiDuCarViewController : UserBaseUIViewController

@property (nonatomic, strong) CalloutView *calloutView;
//@property (nonatomic, strong) NSString *baiducarOrderId;
//@property (nonatomic, strong) NSString *virtualId;
@property (nonatomic, strong) CarpoolOrderItem *orderDetail;

@end
