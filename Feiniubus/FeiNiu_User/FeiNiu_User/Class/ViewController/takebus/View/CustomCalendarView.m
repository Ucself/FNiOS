//
//  CustomCalendarView.m
//  FeiNiu_User
//
//  Created by YiSiBo on 15/9/29.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CustomCalendarView.h"
#import <FNUIView/FNUIView.h>
#import "NSDate+FSExtension.h"
#import <FNUIView/DatePickerView.h>
#import "CustomCollectionViewCell.h"
#import "UINameView.h"
#import "CarpoolCustomCell.h"
#import "UIColor+Hex.h"

#define CalendarHeight            242
#define CalendarAnimationDuration 0.2
#define CalendarTitleSize         12
#define CalendarSubTitleSize      8
#define CalendarWeekTitleSize     14
#define CalendarHeaderTitleSize   14

#define ButtonWidth   self.frame.size.width * 0.2
#define ButtonHeight  30
#define ButtonLeading self.frame.size.width * 0.2
#define ButtonTop     60
#define ScreenWidth   self.frame.size.width
#define ScreenHeight  self.frame.size.height
#define PickerLineHeight 3

#define kCellConstHeight 90

#define SelectedColor [UIColor colorWithRed:254/255.0 green:113/255.0 blue:75/255.0 alpha:1]

@interface CustomCalendarView ()<FSCalendarDelegate, FSCalendarDelegateAppearance,FSCalendarDataSource,DatePickerViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDelegate,UITableViewDataSource,CarpoolCustomDelegate>{

    NSMutableArray *_leftDataSource;
    NSMutableArray *_rightDataSource;
    NSMutableArray *_buttonArray;
    NSMutableArray *_allDateArr;
    
    NSMutableDictionary *_scrollCarData;
    NSMutableArray *_timingCarData;
    NSMutableArray *_tempScrollCarData;
    NSMutableArray *_timingCarDataSource;
    
    NSMutableString *_leftTime;
    NSMutableString *_rightTime;
    NSMutableString *_selectedDate;
    
    NSIndexPath *_selectedIndex;
    NSUserDefaults *defaultValue;
    int temp;
    
    BOOL _isScrollCar;
    
    NSString *_tempPathId;
    NSString *_tempStartingName;
    NSString *_scrollStartTime;
    NSString *_scrollEndTime;
    
    UIButton *_scrollButton;
    UILabel  *_timeLabel;
    
    int _carState;
    
    BOOL _tempFlag;
}

@property (weak, nonatomic) IBOutlet UIPickerView *leftPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *rightPickerView;
@property (weak, nonatomic) IBOutlet UILabel      *pickerTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton     *pkerRightButton;
@property (weak, nonatomic) IBOutlet UIButton     *pkerLeftButton;
@property (weak, nonatomic) IBOutlet UIButton     *calendarOKButton;
@property (weak, nonatomic) IBOutlet UIView       *pkerView;
@property (weak, nonatomic) IBOutlet UIButton     *calendarCancelButton;

@property (nonatomic, strong) NSMutableString *calendarPathId;
@property (nonatomic, strong) NSMutableString *calendarTrainId;

//time view property
@property (strong, nonatomic) IBOutlet UIView  *customTimeView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) UICollectionView *timeCView;

@property (strong, nonatomic) IBOutlet UIView *costomline;
@property (strong, nonatomic) IBOutlet UIView *pickerline;
@property (strong, nonatomic) IBOutlet UIView *calendarline;

@end

@implementation CustomCalendarView

+ (instancetype)instance
{
    CustomCalendarView *view = [CustomCalendarView loadFromNIB];
    return view;
}

//initialized calendar view
- (void)initCalendarView{
    
    _miniDate = [NSDate dateFromString:[_calendDataSource firstObject][@"date"] format:@"yyyy-MM-dd HH:mm:ss"];
    
    _maxDate = [NSDate dateFromString:[_calendDataSource lastObject][@"date"] format:@"yyyy-MM-dd HH:mm:ss"];

    _allDateArr = [NSMutableArray array];
    
    for (int i = 0; i < _calendDataSource.count; i++) {

        NSDate *date = [NSDate dateFromString:_calendDataSource[i][@"date"] format:@"yyyy-MM-dd HH:mm:ss"];
        
        [_allDateArr addObject:date];
    }

    [self.calendarOKButton     setHidden:YES];
    [self.calendarCancelButton setHidden:YES];
    
    self.calendarView.delegate   = self;
    self.calendarView.dataSource = self;
    
    _calendarView.scope = FSCalendarScopeMonth;
    
    _calendarView.scrollDirection = FSCalendarScrollDirectionVertical;//Vertical Scroll

    [_calendarView setToday:[NSDate stringToDate:_selectedDate]];
    
    _calendarView.appearance.weekdayTextColor    = SelectedColor;
    _calendarView.appearance.headerTitleColor    = SelectedColor;
    _calendarView.appearance.selectionColor      = SelectedColor;
    _calendarView.appearance.titleTextSize       = CalendarTitleSize;
    _calendarView.appearance.subtitleTextSize    = CalendarSubTitleSize;
    _calendarView.appearance.weekdayTextSize     = CalendarWeekTitleSize;
    _calendarView.appearance.headerTitleTextSize = CalendarHeaderTitleSize;
    
    _calendarView.allowsMultipleSelection = NO;

}

- (void)initPickerView{
    
    _leftTime     = [NSMutableString string];
    _rightTime    = [NSMutableString string];
    _selectedDate = [NSMutableString string];
    
    _leftDataSource  = [NSMutableArray array];
    _rightDataSource = [NSMutableArray array];
    
    [self.pickerTimeLabel setTextColor:SelectedColor];
    self.pickerTimeLabel.text = @"";
    
    [self.pkerLeftButton  setTitleColor:SelectedColor forState:UIControlStateNormal];
    [self.pkerRightButton setTitleColor:SelectedColor forState:UIControlStateNormal];

    [self.leftPickerView  setDelegate:self];
    [self.leftPickerView  setDataSource:self];

    [self.rightPickerView setDelegate:self];
    [self.rightPickerView setDataSource:self];
}

- (void)initGrayBackgroudView{
    
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grayViewClick)];
    
    [self.grayView addGestureRecognizer:recognizer];
}

- (void)initCustomTimeView{
    
    self.timeDataSource = [NSMutableArray array];
}

- (void)initTableView{
    
    [_customTableView setDelegate:self];
    [_customTableView setDataSource:self];
}

- (void)initCollectionView{
    
//    if (_timingCarData == nil || _timingCarData.count == 0) {
//        return;
//    }
//    
//    [_customScrollView setContentSize:CGSizeMake(0, 3*_customScrollView.frame.size.height/2)];
//    [_customScrollView setBounces:NO];
//    
//    if ([[_tempScrollCarData firstObject][@"type"] intValue] == 3) {
//        
//        UINameView *showScrollNameView = [UINameView sharedInstance];
//        
//        [showScrollNameView setFrame:CGRectMake(0, 0, self.frame.size.width*3/4, 30)];
//        
//        [showScrollNameView setCenter:CGPointMake(_customScrollView.center.x,20)];
//        
//        [showScrollNameView.nameLabel setText:[_tempScrollCarData firstObject][@"startingName"]];
//        [_customScrollView addSubview:showScrollNameView];
//        
//        _scrollButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _customScrollView.frame.size.width/3 - 40, 30)];
//        
//        [_scrollButton setCenter:CGPointMake(_customScrollView.center.x + _scrollButton.frame.size.width/2 - _customScrollView.frame.size.width*3/8,50)];
//        [_scrollButton setTitle:@"滚动班" forState:UIControlStateNormal];
//        [_scrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        _scrollButton.titleLabel.font = [UIFont systemFontOfSize: 15];
//        [_scrollButton.layer setCornerRadius:5];
//        [_scrollButton.layer setBorderColor:[UIColor grayColor].CGColor];
//        [_scrollButton.layer setBorderWidth:1];
//        [_scrollButton addTarget:self action:@selector(selectedScrollButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        if (_scrollButtonIsSelected == YES) {
//            [_scrollButton setSelected:YES];
//            [_scrollButton setTitleColor:SelectedColor forState:UIControlStateNormal];
//            [_scrollButton.layer setBorderColor:SelectedColor.CGColor];
//        }
//        
//        [_customScrollView addSubview:_scrollButton];
//        
//        _scrollStartTime = [(NSString *)([_tempScrollCarData firstObject][@"value"][@"startTime"]) substringToIndex:5];
//        _scrollEndTime = [(NSString *)[_tempScrollCarData firstObject][@"value"][@"endTime"] substringToIndex:5];
//        
//        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
//        [_timeLabel setCenter:CGPointMake(_customScrollView.center.x + 20, 50)];
//        [_timeLabel setText:[NSString stringWithFormat:@"%@-%@有效", _scrollStartTime , _scrollEndTime]];
//        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
//        [_timeLabel setTextColor:[UIColor grayColor]];
//        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
//        [_customScrollView addSubview:_timeLabel];
//        
//        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100,30)];
//        [tipsLabel setCenter:CGPointMake(_customScrollView.center.x + 50 + _timeLabel.frame.size.width/2, 50)];
//        [tipsLabel setText:@"(半小时一班)"];
//        [tipsLabel setTextColor:[UIColor grayColor]];
//        [tipsLabel setTextAlignment:NSTextAlignmentLeft];
//        [tipsLabel setFont:[UIFont systemFontOfSize:14]];
//        [_customScrollView addSubview:tipsLabel];
//        
//        //以下为定时
//        UINameView *showNameView = [UINameView sharedInstance];
//        
//        [showNameView setFrame:CGRectMake(0, 0, self.frame.size.width*3/4, 30)];
//        [showNameView setCenter:CGPointMake(_customScrollView.center.x,90)];
//        
//        [showNameView.nameLabel setText:_tempStartingName];
//        [_customScrollView addSubview:showNameView];
//        
//        
//        _selectedIndex = [NSIndexPath indexPathForRow:[_timingCarData count] inSection:1];
//        
//        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//        
//        _timeCView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width * 3/4, self.frame.size.height) collectionViewLayout:flowLayout];
//        [_timeCView setCenter:CGPointMake(self.center.x, self.center.y + 105)];
//        [_timeCView setBackgroundColor:[UIColor clearColor]];
//        [_timeCView setDelegate:self];
//        [_timeCView setDataSource:self];
//        
//        [_timeCView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell"
//                                               bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier:@"collectcell"];
//        
//        [_customScrollView addSubview:_timeCView];
//
//        
//    }else{
//        
//        //以下为定时
//        UINameView *showNameView = [UINameView sharedInstance];
//        
//        [showNameView setFrame:CGRectMake(0, 0, self.frame.size.width*3/4, 30)];
//        [showNameView setCenter:CGPointMake(_customScrollView.center.x,20)];
//        
//        [showNameView.nameLabel setText:_tempStartingName];
//        [_customScrollView addSubview:showNameView];
//        
//        
//        _selectedIndex = [NSIndexPath indexPathForRow:[_timingCarData count] inSection:1];
//        
//        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//        
//        _timeCView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width * 3/4, self.frame.size.height) collectionViewLayout:flowLayout];
//        [_timeCView setCenter:CGPointMake(self.center.x, self.center.y + 35)];
//        [_timeCView setBackgroundColor:[UIColor clearColor]];
//        [_timeCView setDelegate:self];
//        [_timeCView setDataSource:self];
//        
//        [_timeCView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell"
//                                               bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier:@"collectcell"];
//        
//        [_customScrollView addSubview:_timeCView];
//
//        
//    }
    
    
}


- (void)initProperty{
    
    _scrollCarData       = [NSMutableDictionary dictionary];
    _timingCarData       = [NSMutableArray array];
    _tempScrollCarData   = [NSMutableArray array];
    _timingCarDataSource = [NSMutableArray array];
}

#pragma mark -- function methods
//Add calendar view to parentView
- (void)showInView:(UIView *)view
{
    self.sView = view;
    self.tag = 134;
    if ([self.sView  viewWithTag:134]) {
        return;
    }

    [self.sView  addSubview:self];
    
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sView);
    }];
    
    [self.sView  layoutIfNeeded];
    
    [self initProperty];
    [self calendarAnimation:YES];
    [self initCalendarView];
    [self initGrayBackgroudView];
    [self initPickerView];
    [self initCustomTimeView];
    [self initTableView];
}

//Date transform nongli
- (NSString*)getChineseDayWithDate:(NSDate *)date{
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",@"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",@"三十一", nil];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    NSDateComponents *todayComp = [localeCalendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *tomorrowComp = [localeCalendar components:unitFlags fromDate:[[NSDate date] dateByAddingTimeInterval:24*60*60]];
    NSDateComponents *afterTomorrowComp = [localeCalendar components:unitFlags fromDate:[[NSDate date] dateByAddingTimeInterval:24*60*60*2]];


    NSString *dayStr = [chineseDays objectAtIndex:localeComp.day-1];

    if (localeComp.year == todayComp.year && localeComp.month == todayComp.month && localeComp.day == todayComp.day) {
        dayStr = @"今天";
    }else if(localeComp.year == tomorrowComp.year && localeComp.month == tomorrowComp.month && localeComp.day == tomorrowComp.day){
        dayStr = @"明天";
    }else if(localeComp.year == afterTomorrowComp.year && localeComp.month == afterTomorrowComp.month && localeComp.day == afterTomorrowComp.day){
        dayStr = @"后天";
    }
    
    return dayStr;
}

//pop next view : pickerview or timeview
- (void)jumpToNextView:(UIView *)view{
    
    [UIView animateWithDuration:CalendarAnimationDuration animations:^{
        
        [self.calendarView setFrame:CGRectMake(0, self.frame.size.height + CalendarHeight, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
        [_pickerline setFrame:CGRectMake(0, self.frame.size.height + CalendarHeight+PickerLineHeight, self.calendarView.frame.size.width, PickerLineHeight)];
        
        [self.grayView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + CalendarHeight)];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:CalendarAnimationDuration animations:^{
            
            [view setFrame:CGRectMake(0, self.frame.size.height - CalendarHeight, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
            
            [_pickerline setFrame:CGRectMake(0, self.frame.size.height - CalendarHeight-PickerLineHeight, self.calendarView.frame.size.width, PickerLineHeight)];
            
            [self.grayView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - CalendarHeight)];
        }];
    }];
}

- (void)createTimeDataSource:(NSString *)startTime EndTime:(NSString *)endTime{

    //left pickerview datasource
    for (int i = [startTime intValue]; i < [endTime intValue]; i++) {
        
        [_leftDataSource addObject:[NSString stringWithFormat:@"%d:00", i]];
    }
    
    //right pikerview datasource
    for (int i = [startTime intValue] + 1; i <= [endTime intValue]; i++) {
        
        [_rightDataSource addObject:[NSString stringWithFormat:@"%d:00", i]];
    }
    
    [_leftPickerView  reloadAllComponents];
    [_rightPickerView reloadAllComponents];
}

#pragma mark -- Button Event

- (void)selectedScrollButtonClick:(UIButton *)sender{
    
    _cellIsSelected = NO;
    _scrollButtonIsSelected = YES;
    
    if (_scrollButton.selected == NO) {
        
        _scrollButton.selected = YES;
        
        [_scrollButton setTitleColor:SelectedColor forState:UIControlStateNormal];
        [_scrollButton.layer setBorderColor:SelectedColor.CGColor];
    
        _calendarPathId =  [_tempScrollCarData firstObject][@"pathId"];
        _calendarTrainId = [_tempScrollCarData firstObject][@"value"][@"trainId"];
        
        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[_timeCView cellForItemAtIndexPath:_selectedIndex];
        [cell.layer setBorderColor:[UIColor grayColor].CGColor];
        [cell.timeLabel setTextColor:[UIColor grayColor]];
    }
}

- (void)grayViewClick{
    
    [self calendarAnimation:NO];
}

- (IBAction)timeViewCancelButtonPressed:(id)sender {
    
    [self calendarAnimation:NO];
}

- (IBAction)timeViewOKButtonPressed:(id)sender {
    
    if ((_calendarPathId == nil) || (_calendarTrainId == nil)) {

        [self popPromptView:@"选择一个有效的时间"];
//        [self calendarAnimation:NO];
        return;
    }
    
    if (_scrollButtonIsSelected == YES) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timelabel"
                                                            object:@{@"starttime":_scrollStartTime,
                                                                     @"endtime":_scrollEndTime,
                                                                     @"pathid":_calendarPathId,
                                                                     @"trainid":_calendarTrainId,
                                                                     @"indexRow":@(_indexRow),
                                                                     @"isSelected":@(_cellIsSelected),
                                                                     @"scrollButtonSelected":@(_scrollButtonIsSelected),
                                                                     @"talbeIndex":_customIndexPath,
                                                                     @"collectionIndex":_customCollectionIndexPath,
                                                                     @"flagIndex":_flagIndex}
                                                          userInfo:@{@"time":_timeLabel.text,
                                                                     @"type":@"10",
                                                                     @"date":_selectedDate}];
        
         [self calendarAnimation:NO];
        
        return;
    }
    
    //班次状态，1为正常，2为班次已出发
    if (_carState != 1){
        [self calendarAnimation:NO];
        return;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"timelabel"
     object:@{@"starttime":_leftTime,
              @"endtime":_rightTime,
              @"pathid":_calendarPathId,
              @"trainid":_calendarTrainId,
              @"indexRow":@(_indexRow),
              @"isSelected":@(_cellIsSelected),
              @"scrollButtonSelected":@(_scrollButtonIsSelected),
              @"talbeIndex":_customIndexPath,
              @"collectionIndex":_customCollectionIndexPath,
              @"flagIndex":_flagIndex}
     userInfo:@{@"time":[NSString stringWithFormat:@"%@ %@", _selectedDate, self.pickerTimeLabel.text]}];
    
    [self calendarAnimation:NO];
}

//- (void)timeButtonPressed:(UIButton *)sender{
//    
//    for (UIButton *button in _buttonArray) {
//        
//        [button.layer setBorderColor:[UIColor grayColor].CGColor];
//        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [button setSelected:NO];
//    }
//    
//    [sender.layer setBorderColor:[UIColor greenColor].CGColor];
//    [sender setTitleColor:UIColor_DefGreen forState:UIControlStateNormal];
//    [sender setTag:100];
//    
//    NSInteger index = [_buttonArray indexOfObject:sender];
//    _timeLabel.text  = sender.titleLabel.text;
//    
//    self.pickerTimeLabel.text = sender.titleLabel.text;
//    
//    @try {
//        _calendarTrainId = _timeDataSource[index][@"id"];
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//}

//pkerView OK Button
- (IBAction)pkerRightButton:(id)sender {
    
    if (_leftTimeIndex == 0) {
        _leftTime  = _leftDataSource[0];
        _rightTime = _rightDataSource[0];
    }
    
    if ((_calendarPathId == nil) || (_calendarTrainId == nil)) {
        _calendarPathId = self.calendDataSource[0][@"pathId"];
        _calendarTrainId = self.calendDataSource[0][@"trainId"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"timelabel"
                                                        object:@{@"starttime":_leftTime,
                                                                 @"endtime":_rightTime,
                                                                 @"pathid":_calendarPathId,
                                                                 @"trainid":_calendarTrainId,
                                                                 @"leftrow":@(_leftTimeIndex),
                                                                 @"rightrow":@(_rightTimeIndex)}
                                                      userInfo:@{@"time":[NSString stringWithFormat:@"%@ %@", _selectedDate, self.pickerTimeLabel.text]}];
    
    [self calendarAnimation:NO];

}

//pkerView Cancle Button
- (IBAction)pkerLeftButton:(id)sender {
    
    [self calendarAnimation:NO];
}

#pragma mark -- animation

//Pop Calendar Animation
- (void)calendarAnimation:(BOOL)isPop{
    
    if (!isPop){
        
        [UIView animateWithDuration:CalendarAnimationDuration animations:^{
            
            [self.calendarView setFrame:CGRectMake(0, self.frame.size.height + CalendarHeight, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
            
            [self.pkerView setFrame:CGRectMake(0, self.frame.size.height + CalendarHeight, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
            
            [self.customTimeView setFrame:CGRectMake(0, self.frame.size.height + CalendarHeight, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
            
            [_pickerline setFrame:CGRectMake(0, self.frame.size.height + CalendarHeight + PickerLineHeight, self.calendarView.frame.size.width,PickerLineHeight)];
            
            [self.grayView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + CalendarHeight)];
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
        
    }else{
        
        //pop calendar animation
        [UIView animateWithDuration:CalendarAnimationDuration animations:^{
            
            [self.calendarView setFrame:CGRectMake(0, self.frame.size.height - CalendarHeight, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
            
            [_pickerline setFrame:CGRectMake(0, self.frame.size.height - CalendarHeight - PickerLineHeight, self.calendarView.frame.size.width, PickerLineHeight)];
            
            [self.grayView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - CalendarHeight)];
        }];
    }
}


#pragma mark -- UICollectionViewDataSource

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    
//    return [_timingCarData count];
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    static NSString *cellId = @"collectcell";
//    
//    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
//    
//    [cell.timeLabel setText:[_timingCarData[indexPath.row][@"time"] substringToIndex:5]];
//    [cell.layer setMasksToBounds:YES];
//    [cell.layer setCornerRadius:5];
//    [cell.layer setBorderWidth:1];
//    [cell.layer setBorderColor:[UIColor grayColor].CGColor];
//    [cell setCellState:[_timingCarData[indexPath.row][@"state"] intValue]];
//    
//    if (_cellIsSelected == YES && indexPath.row == _indexRow && cell.cellState == 1) {
//        _selectedIndex = indexPath;
//        [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
//        [cell.timeLabel setTextColor:SelectedColor];
//        [cell.layer setBorderColor:SelectedColor.CGColor];
//        [cell.layer setBorderWidth:1];
//        self.pickerTimeLabel.text = cell.timeLabel.text;
//        return cell;
//    }
//    return cell;
//}
//
//
//#pragma mark -- UICollectionViewDelegate
//
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return CGSizeMake(collectionView.frame.size.width/3 - 10, 30);
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSLog(@"timedata = %@", _timingCarData);
//    
//    CustomCollectionViewCell *cell1 = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//   
//    _carState = cell1.cellState;
//    
//    if (cell1 == nil) {
//        return;
//    }
//    
//    if (cell1.cellState != 1){
//        
//        cell1.timeLabel.textColor = [UIColor grayColor];
//        [cell1.layer setBorderColor:[UIColor grayColor].CGColor];
//        [cell1.layer setBorderWidth:1];
//
//        [self popPromptView:@"该班次已发车"];
//        
//        [self calendarAnimation:NO];
//        return;
//    }
//    
//    _cellIsSelected = YES;
//    _scrollButtonIsSelected = NO;
//    
//    if (_scrollButton.selected == YES) {
//        
//        [_scrollButton setSelected:NO];
//        [_scrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [_scrollButton.layer setBorderColor:[UIColor grayColor].CGColor];
//    }
//    
//    if (_selectedIndex.row != indexPath.row) {
//
//        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:_selectedIndex];
//        
//        if (cell == nil) {
//            cell = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
//        }
//        
//        cell.timeLabel.textColor = [UIColor grayColor];
//        [cell.layer setBorderColor:[UIColor grayColor].CGColor];
//        [cell.layer setBorderWidth:1];
// 
//        CustomCollectionViewCell *cellNew = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//        
//        cellNew.timeLabel.textColor = SelectedColor;
//        
//        [cellNew.layer setBorderColor:SelectedColor.CGColor];
//        [cellNew.layer setBorderWidth:1];
//        
//        _selectedIndex = indexPath;
//        
//        _indexRow = (int)_selectedIndex.row;
//        
//        self.pickerTimeLabel.text = cellNew.timeLabel.text;
//        
//        @try {
//            _calendarPathId  = (NSMutableString *)_tempPathId;
//            _calendarTrainId = _timingCarData[_selectedIndex.row][@"id"];
//        }
//        @catch (NSException *exception) {
//            
//        }
//        @finally {
//            
//        }
//    }else {
//        
//        @try {
//            _calendarPathId  = (NSMutableString *)_tempPathId;
//            _calendarTrainId = _timingCarData[indexPath.row][@"id"];
//        }
//        @catch (NSException *exception) {
//            
//        }
//        @finally {
//            
//        }
//        
//        self.pickerTimeLabel.text = cell1.timeLabel.text;
//    }
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}

#pragma mark -- FSCalendarDataSource

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date{

//    NSString * todayString = [[[NSDate date] description] substringToIndex:10];
//    NSString * dateString = [[date description] substringToIndex:10];
//
//    if ([todayString isEqualToString:dateString]) {
//        return @"今天";
//    }
//    if ([date isEqualToDate:[calendar.today dateByAddingTimeInterval:24*60*60]]) {
//        return @"明天";
//    }
//    if ([date isEqualToDate:[calendar.today dateByAddingTimeInterval:24*60*60*2]]) {
//        return @"后天";
//    }
    return [self getChineseDayWithDate:date];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date{
    
    for (NSDate *dt in _allDateArr) {
        
        if (date.fs_day == dt.fs_day && date.fs_month == dt.fs_month) {
            
            return YES;
            
        }
    }
    
    return YES;

    
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    
    int flag = NO;
    
    for (NSDate *dt in _allDateArr) {
        
        if ([date compare:dt] == NSOrderedSame) {
            
            flag = YES;
            break;
        }
    }
    
    if (flag == NO) {
        [self popPromptView:@"请选择有效日期"];
        return;
    }
    
    if ([_calendarView.today compare:date] != NSOrderedSame) {
        
        _cellIsSelected = NO;
        _scrollButtonIsSelected = NO;
    }
    
    defaultValue = [NSUserDefaults standardUserDefaults];
    
    if ([_miniDate compare:date] == NSOrderedDescending) {
        
        return;
    }
    
    if ([_miniDate compare:date] == NSOrderedSame) {
        
        _tempFlag = YES;
    }else{
        _tempFlag = NO;
    }
    
    for (int i = 0; i < _calendDataSource.count; i++) {
        
        NSDate *tempDate = [NSDate dateFromString:_calendDataSource[i][@"date"] format:@"yyyy-MM-dd HH:mm:ss"];
        
        if ([tempDate isEqualToDate:date]) {
            
            if ([[defaultValue valueForKey:@"savevalue"] intValue] != i) {
                [defaultValue setValue:@(i) forKey:@"savevalue"];
                _indexRow = 0;
            }
            
            _selectedDate = (NSMutableString *)[NSDate formatDate:date format:@"yyyy年MM月dd日"];

            _timeDataSource = nil;
            
            NSArray *itemsArray = _calendDataSource[i][@"items"];
            
            for (int k = 0; k < itemsArray.count; k++) {
                
                if ([itemsArray[k][@"type"] intValue] == 1 ) {
                    _isScrollCar = YES;
                    break;
                }
            }
            
            //滚动发车
            if (_isScrollCar == YES){
                
                _scrollCarData = [_calendDataSource[i][@"items"] firstObject];
                
                [self createTimeDataSource:_scrollCarData[@"value"][@"startTime"]
                                   EndTime:_scrollCarData[@"value"][@"endTime"]];
                
                [self.pickerTimeLabel setText:[NSString stringWithFormat:@"%@-%@",_leftDataSource[_leftTimeIndex],_rightDataSource[_leftTimeIndex]]];
                
                [self.leftPickerView  selectRow:_leftTimeIndex inComponent:0 animated:YES];
                [self.rightPickerView selectRow:_rightTimeIndex inComponent:0 animated:YES];
                _calendarTrainId = _scrollCarData[@"value"][@"trainId"];
                _calendarPathId  = _scrollCarData[@"pathId"];
        
            }else{
            
                _timingCarDataSource = [NSMutableArray arrayWithArray:itemsArray];
                
                //定时发车(type = 2 定时发车，type =3 滚动发车)
//                NSArray<NSDictionary *> *tempCar = _calendDataSource[i][@"items"];
                
//                NSMutableArray *timeTempDataSource = [NSMutableArray array];
//                
//                [tempCar enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    
//                    [timeTempDataSource addObject:obj];
//                    
//                }];
                
//                NSMutableArray *timingCarData = [NSMutableArray array];
                
//                for (NSDictionary *dictionary in tempCar) {
//                    
//                    if ([dictionary[@"type"] intValue] == 3) {
//                        
//                        [_tempScrollCarData addObject:dictionary];
//                    }
//                    
//                    if ([dictionary[@"type"] intValue] == 2) {
//                        
//                        [_timingCarDataSource addObject:dictionary];
//                    }
//                }
                
//                _tempStartingName = [timingCarData firstObject][@"startingName"];
//                _tempPathId       = [timingCarData firstObject][@"pathId"];
//                [_timingCarData setArray: [timingCarData firstObject][@"value"][@"list"] ];
//          

//                [_timingCarDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                   
//                    [_timingCarData addObject:obj[@"value"][@"list"]];
//                }];
                
                //排序时间（小到大）
//                [_timingCarData sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//                    
//                    int firstValue  = [obj1[@"time"] intValue];
//                    int secondVlaue = [obj2[@"time"] intValue];
//                    
//                    if (firstValue > secondVlaue) {
//                        return NSOrderedDescending;
//                    }else if (firstValue < secondVlaue){
//                        return NSOrderedAscending;
//                    }else{
//                        return NSOrderedSame;
//                    }
//                }];
                
//                [self initButton];


            }
        }
    }

    //车子的state=0，无车
    if (_timingCarDataSource == nil || _timingCarDataSource.count == 0) {
        
        [self jumpToNextView:_pkerView];//弹出滚动发车view
        
        return;
    }
    
    
    if ([_selectedDate isEqualToString:@""]) {
        
        _selectedDate = (NSMutableString *)[NSDate formatDate:_calendarView.today format:@"yyyy年MM月dd日"];
    }
    
//    [self initCollectionView];
    [_customTableView reloadData];
    
    if (_timingCarDataSource && ![_timingCarDataSource isKindOfClass:[NSNull class]]) {
        
        [self jumpToNextView:_customTimeView];//弹出定时发车view
        
    }
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date{
    
    for (NSDate *dt in _allDateArr) {
        
        if (date.fs_day == dt.fs_day && date.fs_month == dt.fs_month && _calendarView.today.fs_day == dt.fs_day) {
            return [UIColor whiteColor];
        
        }
        
        if (date.fs_day == dt.fs_day && date.fs_month == dt.fs_month){
            
            return [UIColor blackColor];
        }
    }
    
    return [UIColor colorWithWhite:.7 alpha:1];
}


- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date{
    for (NSDate *dt in _allDateArr) {
        
        if (date.fs_day == dt.fs_day && date.fs_month == dt.fs_month && _calendarView.today.fs_day == dt.fs_day) {
            return [UIColor whiteColor];
            
        }
        
        if (date.fs_day == dt.fs_day && date.fs_month == dt.fs_month){
            
            return [UIColor blackColor];
        }
    }
    
    return [UIColor colorWithWhite:.7 alpha:1];
}


- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date{
    
    for (NSDate *dt in _allDateArr) {
        
        if (date.fs_day == dt.fs_day && date.fs_month == dt.fs_month) {
            
            return [UIColor blackColor];
            
        }
    }
    
    return [UIColor colorWithWhite:.7 alpha:1];
}

- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date{

//    for (NSDate *dt in _allDateArr) {
//        
//        if (date.fs_day == dt.fs_day) {
//            return YES;
//        }
//    }
//    
    return NO;
}


#pragma mark -- UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView.tag == 10) {
        
        _leftTime       = _leftDataSource[row];
        _leftTimeIndex  = (int)row;
        
        if ((int)row >= _rightTimeIndex) {
           
            [self.rightPickerView selectRow:row inComponent:0 animated:YES];
            _rightTime      = _rightDataSource[row];
            _rightTimeIndex = (int)row;
            
        }
        
    }else if(pickerView.tag == 11){
        
        _rightTime      = _rightDataSource[row];
        _rightTimeIndex = (int)row;
        
        _leftTime = _leftDataSource[_leftTimeIndex];
        
        if ((int)row <= _leftTimeIndex) {
        
            [self.leftPickerView selectRow:row inComponent:0 animated:YES];
            
            _leftTime       = _leftDataSource[row];
            _leftTimeIndex  = (int)row;
            
        }

    }
    
    [self.pickerTimeLabel setText:[NSString stringWithFormat:@"%@-%@",_leftTime,_rightTime]];
}

#pragma mark -- UIPickerViewDataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (pickerView.tag == 10) {
        
        return _leftDataSource.count;
        
    }else{
        
        return _rightDataSource.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *name = @"";
    
    if (pickerView.tag == 10) {
        
        name = _leftDataSource[row];
    
    }else{
        
        name = _rightDataSource[row];
    }
    
    return name;
}

#pragma mark -- tips 

- (void)popPromptView:(NSString *)text{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.superview];
    [self.superview addSubview:hud];
    [hud show:YES];
    [hud setLabelText:text];
    [hud setMode:MBProgressHUDModeText];
    [hud hide:YES afterDelay:2];
    if (hud.hidden == YES) {
        [hud removeFromSuperview];
    }
}

#pragma mark -- talbe view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_timingCarDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"customcellid";
    
    CarpoolCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        
        cell = [[CarpoolCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setCellType:[_timingCarDataSource[indexPath.row][@"type"] intValue]];
    
    if ([_timingCarDataSource[indexPath.row][@"type"] intValue] == 3) {
        
        [cell setScrollDic:_timingCarDataSource[indexPath.row][@"value"]];
        [cell setTrainId  :_timingCarDataSource[indexPath.row][@"value"][@"trainId"]];
        
        
    }else{

        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_timingCarDataSource[indexPath.row][@"value"][@"list"]];
        
        //排序时间（小到大）
        [tempArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            int firstValue  = [obj1[@"time"] intValue];
            int secondVlaue = [obj2[@"time"] intValue];
            
            if (firstValue > secondVlaue) {
                return NSOrderedDescending;
            }else if (firstValue < secondVlaue){
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
            
        }];
        
        [cell setTimingArr:tempArr];
    }
    
    [cell setIndexPath:indexPath];
    [cell setBusStopText:_timingCarDataSource[indexPath.row][@"startingName"]];
    [cell setPathId:_timingCarDataSource[indexPath.row][@"pathId"]];
    [cell setCellIsSelected:_cellIsSelected];
    [cell setScrollButtonSelected:_scrollButtonIsSelected];
    [cell setMyDelegate:self];
    [cell setSameDay:_tempFlag];
    
    
    if (_customIndexPath == indexPath) {

        if (_cellIsSelected) {
            
            cell.collectionViewIndexPath = _customCollectionIndexPath;
        }
        
        return cell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_timingCarDataSource[indexPath.row][@"type"] intValue] == 3) {
        
        return kCellConstHeight;
        
    }else{
        
        NSArray *tempArr = (NSArray *)_timingCarDataSource[indexPath.row][@"value"][@"list"];
        
        return kCellConstHeight + (tempArr.count - 1)/3 * 60;
        
        
//        for (int i = 1; ; i++) {
//            
//            if (tempArr.count/3.0 <= i) {
//                
//                return kCellConstHeight+ (i-1)*60;
//            }
//        }
    }
}


#pragma mark -- carpool custom delegate

- (void)CarpoolCustomCellCallBack:(NSString *)pathId
                          trainId:(NSString *)trainId
                        startTime:(NSString *)startTime
                          endTime:(NSString *)endTime
                         cellType:(int)type
                          timeStr:(NSString *)timeStr
                        cellState:(int)cellState
                        indexPath:(NSIndexPath *)indexPath
                  collectionIndex:(NSIndexPath *)collectionIndexPath
                   buttonSelected:(BOOL)buttonSelected
                     cellSelected:(BOOL)cellSelected{
    
    
    if (_flagIndex == nil) {
        _flagIndex = indexPath;
    }
    
    if (_flagIndex != indexPath) {
        
         CarpoolCustomCell *carpoolCell = (CarpoolCustomCell *)[_customTableView cellForRowAtIndexPath:_flagIndex];

        [carpoolCell.scrollButton.layer setBorderColor:[UIColor colorWithHex:[@(0xefefef) integerValue]].CGColor];
        [carpoolCell.scrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        [carpoolCell setCellIsSelected:NO];
        
        NSLog(@"address = %@", carpoolCell.collectionViewIndexPath);
        
        CustomCollectionViewCell * cell = (CustomCollectionViewCell *)[carpoolCell.timeCollectionView cellForItemAtIndexPath:carpoolCell.collectionViewIndexPath];
        
        [cell.timeLabel setTextColor:[UIColor grayColor]];
        [cell.layer setBorderColor:[UIColor colorWithHex:[@(0xefefef) integerValue]].CGColor];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changecellcolor" object:@{@"index":indexPath}];
        
        _flagIndex = indexPath;
        
    }
    
    switch (type) {
         //定时发车
        case 2:{
        
            [_pickerTimeLabel setText:timeStr];
          
        }
            break;
        //滚动发车
        case 3:{
            
            _scrollStartTime = startTime;
            _scrollEndTime   = endTime;

            [_timeLabel setText:[NSString stringWithFormat:@"%@-%@有效", _scrollStartTime , _scrollEndTime]];
            
        }
            break;
            
        default:
            break;
    }
    
    _carState        = cellState;
    _calendarPathId  = [NSMutableString stringWithString:pathId];
    _calendarTrainId = [NSMutableString stringWithString:trainId];
    _customIndexPath = indexPath;
    _customCollectionIndexPath = collectionIndexPath;
    _scrollButtonIsSelected = buttonSelected;
    _cellIsSelected         = cellSelected;
    
    if (indexPath == nil) {
        _customIndexPath = [[NSIndexPath alloc] init];
    }
    
    if (_customCollectionIndexPath == nil) {
        _customCollectionIndexPath = [[NSIndexPath alloc] init];
    }

//    [_customTableView reloadData];
}


@end
