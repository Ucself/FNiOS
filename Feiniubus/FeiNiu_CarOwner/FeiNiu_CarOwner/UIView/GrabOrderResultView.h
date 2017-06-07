//
//  GrabOrderResultView.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

//时间类型
typedef NS_ENUM(int, DisplayType)
{
    DisplayTypeSuccess = 1,
    DisplayTypeFailure,
};

@protocol GrabOrderResultViewDelegate <NSObject>

-(void)submitButtonClick:(id)sender;

@end

@interface GrabOrderResultView : BaseUIView


@property (nonatomic,assign) id<GrabOrderResultViewDelegate> delegate;
@property (nonatomic,assign) DisplayType displayType;

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *tipFirstInfor;
@property (weak, nonatomic) IBOutlet UILabel *tipSecondInfor;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@property (weak, nonatomic) IBOutlet UIView *contentView;

- (void)showInView:(UIView *) view;
- (void)cancelSelect:(UIView *) view;

@end



