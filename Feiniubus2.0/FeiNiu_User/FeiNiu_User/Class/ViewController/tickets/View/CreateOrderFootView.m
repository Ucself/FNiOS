//
//  CreateOrderFootView.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CreateOrderFootView.h"

@interface CreateOrderFootView ()
@property (weak, nonatomic) IBOutlet UIView *viewCover;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneViewTopCons;

@property (weak, nonatomic) IBOutlet UIView *orderViewCancel;
@property (weak, nonatomic) IBOutlet UIView *orderViewNormal;

@property (weak, nonatomic) IBOutlet UILabel *labCancelId;
@property (weak, nonatomic) IBOutlet UILabel *labCancelTotal;

@property (weak, nonatomic) IBOutlet UILabel *labSalePrice;
@property (weak, nonatomic) IBOutlet UILabel *labRealPrice;

@end

@implementation CreateOrderFootView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)addressBookClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(addressBookLookingClick)]) {
        [self.delegate addressBookLookingClick];
    }
}

- (IBAction)ticketsViewClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(ticketsInstructionsClick)]) {
        [self.delegate ticketsInstructionsClick];
    }
}

-(void)setOrderInfo:(OrderTicket*)orderInfo
{
    if (orderInfo.orderState == EmOrderTicketStatus_Cancelled) {
        self.viewCover.hidden = YES;
        self.orderViewNormal.hidden = YES;
        self.orderViewCancel.hidden = NO;
        self.phoneViewTopCons.constant = -15;
        
        
        self.labCancelId.text = orderInfo.orderId;
        self.labCancelTotal.text = [NSString stringWithFormat:@"%.2f元", orderInfo.totalAmount/100];
        self.phoneNumberLabel.text = orderInfo.contactPhone;
    }
    else {
        self.viewCover.hidden = NO;
        self.orderViewNormal.hidden = NO;
        self.orderViewCancel.hidden = YES;
        self.phoneViewTopCons.constant = 10;
        
        self.labelOrderNumber.text = orderInfo.orderId;
        self.labelCreateTime.text = orderInfo.createTime;
        self.labelTotal.text = [NSString stringWithFormat:@"%.2f元", orderInfo.totalAmount/100];
        self.phoneNumberLabel.text = orderInfo.contactPhone;
        
        
        self.labRealPrice.text = [NSString stringWithFormat:@"%.2f元", orderInfo.amount/100];
    
        float sale = 0;
        if (orderInfo.orderState != EmOrderTicketStatus_WaitPay) {
            sale = (orderInfo.totalAmount-orderInfo.amount)/100;
        }
        
        self.labSalePrice.text = [NSString stringWithFormat:@"-%.2f元", sale];

    }
    
}
@end
