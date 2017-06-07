//
//  CanceledSeasonViewController.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@interface CancelledSeasonViewController : UserBaseUIViewController

/**
 * @breif 订单ID
 */
@property(nonatomic,copy) NSString *orderID;


@property(nonatomic, assign) BOOL isComplain;    //是否投诉页面

@end
