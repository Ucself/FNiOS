//
//  CalloutView.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalloutSearchView : UIView
{
    __weak IBOutlet UILabel *descLab;
    __weak IBOutlet UILabel *timeLab;
}

@property (copy, nonatomic) NSAttributedString *attributdesStr;
@property (copy, nonatomic) NSString *desStr;
@property (copy, nonatomic) NSString *timeStr;

//- (void)setMinuteWithString:(NSString*)_str;

@end
