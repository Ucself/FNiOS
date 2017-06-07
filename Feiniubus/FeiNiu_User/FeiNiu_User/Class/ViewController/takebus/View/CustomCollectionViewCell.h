//
//  CustomCollectionViewCell.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/15.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) int cellState;


@end
