//
//  TicketsMainViewController.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/10.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"
//#import <FNUIView/FSCalendar.h>

@interface TicketsMainViewController : UserBaseUIViewController

//订票时间范围
@property(nonatomic,strong) NSDictionary *ticketTimeRange;
//日历
//@property(nonatomic,strong) FSCalendar *mainCalendar;

@end
