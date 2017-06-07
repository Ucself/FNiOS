//
//  RefundApplyViewCell.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/28.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "RefundApplyViewCell.h"

@implementation RefundApplyViewCell

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isSelect = YES;
    }
    return self;
}
-(void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    if (_isSelect) {
        [_img setImage:[UIImage imageNamed:@"checkbox_check"]];
    }
    else {
        [_img setImage:[UIImage imageNamed:@"checkbox"]];
    }
}
@end
