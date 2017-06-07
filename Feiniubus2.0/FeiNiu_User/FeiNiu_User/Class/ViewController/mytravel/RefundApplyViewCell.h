//
//  RefundApplyViewCell.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/28.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RefundApplyViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelType;
@property (weak, nonatomic) IBOutlet UILabel *labelIdCard;
@property (weak, nonatomic) IBOutlet UILabel *labelState;
@property (weak, nonatomic) IBOutlet UIImageView *img;


@property (assign, nonatomic) BOOL isSelect;
@end
