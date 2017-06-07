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
{
    __weak IBOutlet UILabel *descLab;
    __weak IBOutlet UILabel *timeLab;
}

@property (copy, nonatomic) NSAttributedString *attributdesStr;
@property (copy, nonatomic) NSString *desStr;
@property (copy, nonatomic) NSString *timeStr;
@property (assign, nonatomic) id<CalloutViewDelegate>delegate;

//- (void)setMinuteWithString:(NSString*)_str;

@end
