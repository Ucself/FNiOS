//
//  CallCarInfoView.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>
@interface CallCarInfoView : BaseUIView

/**
 *  变换颜色位置<MYRange class>
 */
@property(nonatomic, retain)NSArray *rangs;

/**
 *  显示字符串
 */
@property(nonatomic, copy) NSString *infoString;

@end
