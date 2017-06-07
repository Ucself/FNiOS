//
//  CallCarTopPlaceView.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallCarTopPlaceView : UIView

/**
 * @breif 开始地点
 */
@property (weak, nonatomic) IBOutlet UILabel *startAddressLab;
/**
 * @breif 目的地
 */
@property (weak, nonatomic) IBOutlet UILabel *endAddressLab;
/**
 * @breif 大约时间
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
/**
 * @breif 大约里程
 */
@property (weak, nonatomic) IBOutlet UILabel *mileageLab;

@end
