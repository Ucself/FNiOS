//
//  PayTicketsHeadView.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/24.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTicket.h"

@interface PayTicketsHeadView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *startSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *endSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;


-(void)setOrderInfo:(OrderTicket*)orderInfo;
@end
