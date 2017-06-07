//
//  MBProgressHUD+User.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/12.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNUIView/FNUIView.h>

typedef enum{
    FNTipTypeNone,
    FNTipTypeFailure,
    FNTipTypeWarning,
    FNTipTypeSuccess,
}FNTipType;

@interface MBProgressHUD (User)
+ (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type;
+ (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type withDelay:(NSTimeInterval)delay;

@end
