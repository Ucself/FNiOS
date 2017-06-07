//
//  CalloutView.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalloutViewDelegate <NSObject>

- (void)jumpAction;

@end

@interface CalloutView : UIView

@property (strong, nonatomic)  UILabel *addressLabel;
@property (strong, nonatomic)  UIButton *backButton;
@property (strong, nonatomic)  UILabel *minuteLabel;
@property (strong, nonatomic)  UIButton *backgroundButton;
@property (assign, nonatomic) id<CalloutViewDelegate>delegate;

- (void)setMinuteWithString:(NSString*)_str;

+ (instancetype)sharedInstance;

@end
