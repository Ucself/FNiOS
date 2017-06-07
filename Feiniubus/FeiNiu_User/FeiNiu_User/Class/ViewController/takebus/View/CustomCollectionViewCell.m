//
//  CustomCollectionViewCell.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/15.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"CustomCollectionViewCell" owner:self options:nil] firstObject];

    }
    
    return self;
}

@end
