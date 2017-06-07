//
//  TicketDetailViewController.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"


@interface TicketDetailViewController : UserBaseUIViewController

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSString *orderId;
@end
