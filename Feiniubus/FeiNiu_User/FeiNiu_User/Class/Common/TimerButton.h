//
//  TimerButton.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "SubmitStyleButton.h"


@interface TimerButton : SubmitStyleButton
@property (nonatomic, assign) NSInteger startTime;

- (void)startTimerAtTime:(NSTimeInterval)seconds;
- (void)stopTimer;
@end
