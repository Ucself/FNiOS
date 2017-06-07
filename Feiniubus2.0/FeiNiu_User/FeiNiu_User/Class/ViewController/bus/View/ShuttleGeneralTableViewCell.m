//
//  ShuttleGeneralTableViewCell.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ShuttleGeneralTableViewCell.h"

@interface ShuttleGeneralTableViewCell()
{
    __weak IBOutlet UIView *myContentView;
}
@end

@implementation ShuttleGeneralTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
