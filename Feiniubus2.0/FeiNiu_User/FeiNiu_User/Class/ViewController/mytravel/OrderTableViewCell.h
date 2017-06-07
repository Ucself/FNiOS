//
//  OrderTableViewCell.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/21.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/SWTableViewCell.h>

#import "OrderTicket.h"
#import "ShuttleModel.h"

typedef NS_ENUM(int, EmCellType)
{
    EmCellType_Tickets = 0,
    EmCellType_Feiniu,
};

@interface OrderTableViewCell : SWTableViewCell

@property (nonatomic, assign) int cellType;


-(void)setTicketOrderInfo:(OrderTicket*)order;
-(void)setShuttleOrderInfo:(ShuttleModel*)order;
@end
