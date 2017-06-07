
//
//  TicketRefundApplytViewController.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/28.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNUIView/FNUIView.h>
#import "UserBaseUIViewController.h"

#import "OrderTicket.h"


@protocol TicketRefundApplyViewControllerDelegate <NSObject>

-(void) ticketRefundApplyRefresh;

@end

@interface TicketRefundApplyViewController : UserBaseUIViewController

@property (nonatomic, strong) OrderTicket *orderTicket;
@property (nonatomic, strong) NSArray     *arTickets;
@end
