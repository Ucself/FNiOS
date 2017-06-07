//
//  RefundTipsView.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

typedef void (^doneBlock)();

@interface RefundTipsView : BaseUIView

+(void)showInfoView:(UIView*)view tips:(NSString*)tips;
+(void)showInfoView:(UIView*)view tips:(NSString*)tips done:(doneBlock)doneBlock;
@end
