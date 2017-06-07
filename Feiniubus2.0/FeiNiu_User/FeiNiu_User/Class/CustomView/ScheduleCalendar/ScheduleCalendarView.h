//
//  ScheduleCalendarView.h
//  FeiNiu_User
//
//  Created by tianbo on 16/5/26.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

@protocol ScheduleCalendarViewDelegate <NSObject>

-(void) calendarViewSelectItems:(NSArray*)items;

@end

@interface ScheduleCalendarView : BaseUIView

@property (nonatomic, assign) id<ScheduleCalendarViewDelegate> delegate;
@property (nonatomic, strong) NSArray *arTickets;

-(NSArray*) getSelectDays;
-(NSArray*) getSelectItems;
@end
