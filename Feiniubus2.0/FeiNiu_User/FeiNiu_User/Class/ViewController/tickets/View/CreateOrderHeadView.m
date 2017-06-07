//
//  CreateOrderHeadView.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CreateOrderHeadView.h"

@implementation CreateOrderHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    self.clipsToBounds = YES;
}
- (IBAction)tapAddPeopleClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(headViewAddClickView)]) {
        [self.delegate headViewAddClickView];
    }
}

- (IBAction)tapQRCodeClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(headViewQRCodeClickView)]) {
        [self.delegate headViewQRCodeClickView];
    }
}

-(void)setOrderInfo:(OrderTicket*)orderInfo
{
    self.startCityLabel.text = orderInfo.startCity;
    self.startSiteLabel.text = orderInfo.startSite;
    self.endCityLabel.text = orderInfo.endCity;
    self.endSiteLabel.text = orderInfo.endSite;
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f/张", orderInfo.ticketPrice/100];
    self.numberPeopleLabel.text = [NSString stringWithFormat:@"乘车人(共%d人)", orderInfo.peopleNumber];
    
    NSDate *date = [DateUtils stringToDate:orderInfo.date];
    NSString *week = [DateUtils weekFromDate:date];
    self.dateLabel.text = [NSString stringWithFormat:@"%@(%@)", [DateUtils formatDate:date format:@"yyyy-MM-dd"], week];
    
    if (orderInfo.type == EmOrderTicketType_FixTime) {
        self.typeLabel.text = orderInfo.time;
    }
    else {
        self.typeLabel.text = @"滚动班";
    }
    
    if (orderInfo.orderState == EmOrderTicketStatus_WaitPay) {
        self.clickViewBtn.hidden = YES;
        self.clickViewImg.hidden = YES;
    }
    else {
        self.clickViewBtn.hidden = YES;
        self.clickViewImg.hidden = NO;
    }
    
    self.timeLabel.text = @"";
}
@end
