//
//  CallCarStateTopView.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/RatingBar.h>

@interface CallCarTopDriverInfoView : UIView

/**
 * @breif 司机头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
/**
 * @breif 司机姓名 车牌号
 */
@property (weak, nonatomic) IBOutlet UILabel *driverInfoLab;
/**
 * @breif 小星星
 */
@property (weak, nonatomic) IBOutlet RatingBar *gradeView;
/**
 * @breif 评分
 */
@property (weak, nonatomic) IBOutlet UILabel *scoreLab;


@property(nonatomic,copy)void (^clickPhoneAction)();

@end
