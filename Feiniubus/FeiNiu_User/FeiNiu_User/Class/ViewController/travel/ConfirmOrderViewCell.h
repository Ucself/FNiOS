//
//  ConfirmOrderViewCell.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharterOrderPrice.h"
#import "PingPPayUtil.h"

@class CharterSuborderItem;

@interface UserTableViewCell : UITableViewCell
+ (NSString *)identifier;
@end

typedef enum{
    OrderInfoCellTypeTime,
    OrderInfoCellTypeStart,
    OrderInfoCellTypeCover,
    OrderInfoCellTypeEnd,
    OrderInfoCellTypeBus,
}OrderInfoCellType;

@interface OrderInfoCell : UserTableViewCell
@property (nonatomic, assign) OrderInfoCellType type;
@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIView *splitTop;
@property (weak, nonatomic) IBOutlet UIView *splitBottom;

+ (NSString *)identifier;
@end

@interface ConfirmOrderViewCell : UserTableViewCell<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CharterSuborderItem *suborder;
+ (CGFloat)heightForRow;
@end



@interface PayInfoCell : UserTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (nonatomic, assign) PaymentChannel paymentType;
@end