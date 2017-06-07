//
//  UserTicketsViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "Ticket.h"

@interface UserTicketsViewController : UserBaseUIViewController
@property (nonatomic, strong) NSArray<Ticket *> *tickets;
@property (nonatomic, assign) NSInteger selcetIndex;

- (void)showInViewController:(UIViewController *)vc;
- (void)hide;

@end
