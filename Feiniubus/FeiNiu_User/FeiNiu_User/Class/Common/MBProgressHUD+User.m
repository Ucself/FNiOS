//
//  MBProgressHUD+User.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/12.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "MBProgressHUD+User.h"

@implementation MBProgressHUD (User)
+ (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type withDelay:(NSTimeInterval)delay{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithWindow:keyWindow];
    hud.mode = MBProgressHUDModeCustomView;
    
    UIImage *tipImage;
    switch (type) {
        case FNTipTypeFailure:{
            tipImage = [UIImage imageNamed:@"failure_icon"];
            break;
        }
        case FNTipTypeSuccess:{
            tipImage = [UIImage imageNamed:@"succeed_icon"];
            break;
        }
        case FNTipTypeWarning:{
            tipImage = [UIImage imageNamed:@"warning_icon"];
            break;
        }
        default:{
            hud.mode = MBProgressHUDModeText;
            break;
        }
    }
    if (tipImage) {
        hud.customView = [[UIImageView alloc]initWithImage:tipImage];
    }
    hud.detailsLabelText = tipMsg;
    hud.detailsLabelFont = [UIFont boldSystemFontOfSize:15];
    hud.removeFromSuperViewOnHide = YES;
    hud.animationType = MBProgressHUDAnimationZoom;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}
+ (void)showTip:(NSString *)tipMsg WithType:(FNTipType)type{
    [self showTip:tipMsg WithType:type withDelay:1.5];
}
@end
