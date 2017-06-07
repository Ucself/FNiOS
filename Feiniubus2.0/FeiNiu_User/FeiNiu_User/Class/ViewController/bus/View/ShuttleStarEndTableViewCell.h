//
//  ShuttleStarEndTableViewCell.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShuttleStarEndTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startLab;

@property (weak, nonatomic) IBOutlet UILabel *endLab;

/**
 *  tag =0  or  1
 */
//@property (nonatomic,copy) void (^clickStartOrEndAction)(BOOL tag, NSString *startString,NSString *endString);

@property (nonatomic,copy) void (^clickStartAction)(NSInteger tag, NSString *startString);

@property (nonatomic,copy) void (^clickEndAction)(NSInteger tag,NSString *endString);

//@property (nonatomic,copy) void (^clickChangeAction)(NSInteger tag);

@end
