//
//  CreateOrderFootView.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTicket.h"
@protocol CreateOrderFootViewDelegate <NSObject>

-(void)addressBookLookingClick;
-(void)ticketsInstructionsClick;

@end

@interface CreateOrderFootView : UIView


@property (weak, nonatomic) IBOutlet UITextField *phoneNumberLabel;
@property (nonatomic,assign) id<CreateOrderFootViewDelegate> delegate;


@property (weak, nonatomic) IBOutlet UILabel *labelOrderNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelCreateTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UIView *viewAddrBook;


-(void)setOrderInfo:(OrderTicket*)orderInfo;
@end
