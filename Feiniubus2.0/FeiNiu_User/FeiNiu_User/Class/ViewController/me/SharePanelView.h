//
//  SharePanelViewController.h
//  FeiNiu_User
//
//  Created by tianbo on 16/5/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNUIView/FNUIView.h>
#import <FNUIView/FXBlurView.h>

typedef NS_ENUM(int, ActionType)
{
    Action_Wx = 0,
    Action_Circles,
    Action_Sina,
    Action_QQ,
    Action_Kongjian,
    Action_Tencent,
    Action_Close,
};

#define kShareUrl         @"target_url"
#define kShareTitle       @"title"
#define kShareImageUrl    @"image_url"
#define kShareDescription @"message"
#define kShareLocImage    @"locImage"
#define kShareLocDesc     @"locDesc"


@interface SharePanelView: BaseUIView


@property (strong, nonatomic) FXBlurView *panel;
@property (copy, nonatomic) void (^clickAction)(int params);
@end
