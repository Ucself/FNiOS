//
//  DateSelectorVV.h
//  FeiNiu_User
//
//  Created by CYJ on 16/4/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateSelectorView : UIView

@property (nonatomic,assign) NSInteger minuteInterval;

@property (nonatomic,copy) NSString *starTime;

@property (nonatomic,copy) NSString *endTime;

/**
 * @breif showDateString显示字符串 useDate 上传接口所用
 */
@property (nonatomic,copy) void(^clickCompleteBlock)(NSString *showDateString,NSString *useDate,BOOL isReal); //是否是当前用车

- (void)showInView:(UIView *) view;

- (instancetype)initWithFrame:(CGRect)frame starTime:(NSString *) starTime endTime:(NSString *)endTime minuteInterval:(NSInteger) minuteInterval;



@end
