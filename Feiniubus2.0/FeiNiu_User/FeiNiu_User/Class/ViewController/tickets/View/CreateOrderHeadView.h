//
//  CreateOrderHeadView.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTicket.h"

@protocol CreateOrderHeadViewDelegate <NSObject>

-(void)headViewAddClickView;
-(void)headViewQRCodeClickView;

@end

@interface CreateOrderHeadView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *startSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *endSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberPeopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIView *clickViewBtn;
@property (weak, nonatomic) IBOutlet UIView *clickViewImg;


@property (nonatomic,assign) id<CreateOrderHeadViewDelegate> delegate;


-(void)setOrderInfo:(OrderTicket*)orderInfo;
@end
