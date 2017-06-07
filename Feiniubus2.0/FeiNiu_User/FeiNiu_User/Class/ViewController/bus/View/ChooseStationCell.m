//
//  ChooseStationCell.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ChooseStationCell.h"

@interface ChooseStationCell()

@end

@implementation ChooseStationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _chooseImg.image = selected ? [UIImage imageNamed:@"checkbox_check"] : [UIImage imageNamed:@"checkbox"];
}

@end
