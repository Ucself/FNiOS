//
//  OrderTableViewCell.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/21.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "OrderTableViewCell.h"

@interface OrderTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBK;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgStart;
@property (weak, nonatomic) IBOutlet UIImageView *imgEnd;
@property (weak, nonatomic) IBOutlet UILabel *labelStarr;
@property (weak, nonatomic) IBOutlet UILabel *labelEnd;
@property (weak, nonatomic) IBOutlet UILabel *labelStartSite;
@property (weak, nonatomic) IBOutlet UILabel *labelEndSite;

@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UIImageView *imgDetail;

@end

@implementation OrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellType:(int)cellType
{
    _cellType = cellType;
    if (cellType == EmCellType_Feiniu) {
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.imgBK.image = nil;
        self.imgStart.image = [UIImage imageNamed:@"star"];
        self.imgEnd.image = [UIImage imageNamed:@"end"];
        
        self.imgDetail.hidden = NO;
        self.labelPrice.hidden = YES;
    }
    else {
        self.containerView.backgroundColor = [UIColor clearColor];
        self.imgBK.image = [UIImage imageNamed:@"writeOrderBG"];
        self.imgStart.image = [UIImage imageNamed:@"ico_ticketstart"];
        self.imgEnd.image = [UIImage imageNamed:@"ico_ticketend"];
        
        self.imgDetail.hidden = YES;
        self.labelPrice.hidden = NO;
    }
}


-(void)setTicketOrderInfo:(OrderTicket*)order
{
    self.labelDate.text = order.createTime;
    self.labelStarr.text = order.startCity;
    self.labelEnd.text = order.endCity;
    self.labelStartSite.text = [NSString stringWithFormat:@"(%@)", order.startSite];
    self.labelEndSite.text = [NSString stringWithFormat:@"(%@)", order.endSite];
    
    if (_cellType == EmCellType_Tickets) {
        self.labelPrice.text = [NSString stringWithFormat:@"%.2f元", order.totalAmount/100];
        
        switch (order.orderState) {
            case EmOrderTicketStatus_Cancelled:
            {
                [self.btnStatus setTitle:@"订单取消" forState:UIControlStateNormal];
                [self.btnStatus setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                self.btnStatus.layer.borderWidth = 0;
                
                self.labelPrice.textColor = [UIColor darkGrayColor];
            }
                break;
            case EmOrderTicketStatus_Finished:
            {
                [self.btnStatus setTitle:@"订单完成" forState:UIControlStateNormal];
                [self.btnStatus setTitleColor:UIColor_DefGreen forState:UIControlStateNormal];
                self.btnStatus.layer.borderWidth = 0;
                
                self.labelPrice.textColor = [UIColor darkGrayColor];
            }
                break;
            case EmOrderTicketStatus_WaitPay:
            {
                [self.btnStatus setTitle:@"立即支付" forState:UIControlStateNormal];
                [self.btnStatus setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
                self.btnStatus.layer.borderWidth = 1;
                self.btnStatus.layer.borderColor = UIColor_DefOrange.CGColor;
                self.btnStatus.layer.cornerRadius = 5;
                
                self.labelPrice.textColor = UIColor_DefOrange;
            }
                break;
            case EmOrderTicketStatus_Refunding:
            {
                [self.btnStatus setTitle:@"退票中" forState:UIControlStateNormal];
                [self.btnStatus setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
                self.btnStatus.layer.borderWidth = 0;
                
                self.labelPrice.textColor = [UIColor darkGrayColor];
            }
                break;
            case EmOrderTicketStatus_RefundFinished:
            {
                [self.btnStatus setTitle:@"已退票" forState:UIControlStateNormal];
                [self.btnStatus setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
                self.btnStatus.layer.borderWidth = 0;
                
                self.labelPrice.textColor = [UIColor darkGrayColor];
            }
                break;
                
            default:
                break;
        }
    }
    else {
        self.labelPrice.text = @"";
    }
}

-(void)setShuttleOrderInfo:(ShuttleModel*)order
{
    self.labelDate.text = order.useDate;
    self.labelStarr.text = order.starting;
    self.labelEnd.text = order.destination;
    self.labelStartSite.text = @"";
    self.labelEndSite.text = @"";
    
    switch ([order.orderState intValue]) {
        case EmShuttleStatus_WaitAssgin:
        {
            [self.btnStatus setTitle:@"正在派车" forState:UIControlStateNormal];
            [self.btnStatus setTitleColor:UIColor_DefGreen forState:UIControlStateNormal];
        }
            break;
        case EmShuttleStatus_ReserveSuccess:
        {
            [self.btnStatus setTitle:@"预约成功" forState:UIControlStateNormal];
            [self.btnStatus setTitleColor:UIColor_DefGreen forState:UIControlStateNormal];
        }
            break;
        case EmShuttleStatus_Processing:
        {
            [self.btnStatus setTitle:@"进行中" forState:UIControlStateNormal];
        }
            break;
        case EmShuttleStatus_Finished1:
        case EmShuttleStatus_Finished2:
        {
            [self.btnStatus setTitle:@"已完成" forState:UIControlStateNormal];
            [self.btnStatus setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
            break;
        case EmShuttleStatus_WaitGetOn:
        {
            [self.btnStatus setTitle:@"等待上车" forState:UIControlStateNormal];
            [self.btnStatus setTitleColor:UIColor_DefGreen forState:UIControlStateNormal];
        }
            break;
        case EmShuttleStatus_Cancelled:
        {
            [self.btnStatus setTitle:@"已取消" forState:UIControlStateNormal];
            [self.btnStatus setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
        }
            break;


            
        default:
            break;
    }
}
@end
