//
//  CharterCarTableViewCell.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/18.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CharterCarTableViewCell.h"

@implementation CharterCarTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.addButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
}

@end
