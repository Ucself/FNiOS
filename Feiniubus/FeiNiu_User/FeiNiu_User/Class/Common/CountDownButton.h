//
//  CountDownButton.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountDownButton : UIButton

- (void)startAutoCountDownByInitialCount:(NSInteger)index;
- (void)stopAutoCount;

@end
