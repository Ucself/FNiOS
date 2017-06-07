//
//  DriverTableViewCell.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/28.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverTableViewCell.h"


@implementation DriverTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _smallSating.isIndicator = YES;
    [_smallSating setImageDeselected:@"small_star_nor" halfSelected:@"small_star_half" fullSelected:@"small_star_press" andDelegate:self];
    [_lagreSating setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    
    _textView.placeholder = @"请输入评价内容, 最多50字";
    _textView.clipsToBounds = YES;
    _textView.layer.cornerRadius = 3;
    _textView.layer.masksToBounds = YES;
    _textView.layer.borderWidth = 0.6;
    _textView.layer.borderColor = [UIColorFromRGB(0xFF9E05) CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)ratingBar:(RatingBar*)ratingBar newRating:(float)newRating
{
    if ([self.delegate respondsToSelector:@selector(tableViewCell:newRating:)]) {
        [self.delegate tableViewCell:self newRating:newRating];
    }
    
}
@end
