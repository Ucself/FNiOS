//
//  UserTicketsViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "BusTicket.h"

@interface UserTicketsViewController : UserBaseUIViewController
@property (nonatomic, strong) NSArray<BusTicket *> *tickets;
- (void)showInViewController:(UIViewController *)vc;
- (void)hide;

@end
