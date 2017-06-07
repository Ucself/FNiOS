//
//  TicketResultTableViewCell.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/21.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "TicketResultTableViewCell.h"

@implementation TicketResultTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(reservationButtonClick:)]) {
        [self.delegate reservationButtonClick:_queryTicketResultModel];
    }
    
}


@end
