//
//  MoreCarTableViewCell.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "MoreCarTableViewCell.h"
@interface MoreCarTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *carInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderButton;

@property (weak, nonatomic) IBOutlet UIButton *payButton;

@end
@implementation MoreCarTableViewCell

- (void)awakeFromNib {
    self.cancelOrderButton.layer.borderWidth = 1;
    self.cancelOrderButton.layer.borderColor = UIColorFromRGB(0xD7D7D7).CGColor;
    self.cancelOrderButton.layer.masksToBounds = YES;
    self.cancelOrderButton.backgroundColor = [UIColor whiteColor];
    self.cancelOrderButton.layer.cornerRadius = 4;
    self.payButton.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
