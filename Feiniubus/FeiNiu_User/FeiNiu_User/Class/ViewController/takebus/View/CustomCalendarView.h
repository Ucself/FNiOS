//
//  CustomCalendarView.h
//  FeiNiu_User
//
//  Created by YiSiBo on 15/9/29.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface CustomCalendarView : UIView

@property (strong, nonatomic) IBOutlet FSCalendar *calendarView;
@property (nonatomic, assign) BOOL cellIsSelected;
@property (nonatomic, assign) BOOL scrollButtonIsSelected;

@property (nonatomic, strong) UIView *sView;
@property (nonatomic, strong) NSDate *miniDate;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSMutableArray *calendDataSource;
@property (strong, nonatomic) IBOutlet UIView *grayView;
@property (nonatomic, strong) NSMutableArray *timeDataSource;
@property (nonatomic, strong) NSString *selectedDate;
@property (nonatomic, assign) int leftTimeIndex;
@property (nonatomic, assign) int rightTimeIndex;
@property (nonatomic, assign) int indexRow;
@property (nonatomic, strong) NSIndexPath *flagIndex;
@property (nonatomic, assign) int scrollButtonTag;
@property (strong, nonatomic) IBOutlet UIScrollView *customScrollView;

@property (strong, nonatomic) IBOutlet UITableView *customTableView;
@property (strong, nonatomic) NSIndexPath *customIndexPath;
@property (strong, nonatomic) NSIndexPath *customCollectionIndexPath;

+ (instancetype)instance;

- (void)showInView:(UIView *)view;
@end
