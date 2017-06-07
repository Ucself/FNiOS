//
//  PayTicketsHeadView.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/24.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "PayTicketsHeadView.h"

@implementation PayTicketsHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



-(void)setOrderInfo:(OrderTicket*)orderInfo
{
    self.startCityLabel.text = orderInfo.startCity;
    self.startSiteLabel.text = orderInfo.startSite;
    self.endCityLabel.text = orderInfo.endCity;
    self.endSiteLabel.text = orderInfo.endSite;
    self.priceLabel.text = [NSString stringWithFormat:@"%d张共%.0f元", orderInfo.peopleNumber,orderInfo.ticketPrice/100.f];
    self.dateLabel.text = orderInfo.date;
    
    if (orderInfo.type == EmOrderTicketType_FixTime) {
        self.typeLabel.text = @"定时班";
    }
    else {
        self.typeLabel.text = @"滚动班";
    }
    
    self.timeLabel.text = orderInfo.time;
}

@end
