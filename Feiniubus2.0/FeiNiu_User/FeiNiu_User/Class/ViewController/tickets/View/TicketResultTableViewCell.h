//
//  TicketResultTableViewCell.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/21.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueryTicketResultModel.h"

@protocol TicketResultTableViewCellDelegate <NSObject>

-(void)reservationButtonClick:(QueryTicketResultModel*)cellData;

@end

@interface TicketResultTableViewCell : UITableViewCell

@property (strong,nonatomic) QueryTicketResultModel *queryTicketResultModel;

//公用属性
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainedTicketLabel;
@property (weak, nonatomic) IBOutlet UILabel *endSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *reservationButton;


//有优惠的属性
@property (weak, nonatomic) IBOutlet UIImageView *couponIocImageView;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;

@property (assign,nonatomic) id<TicketResultTableViewCellDelegate> delegate;

@end
