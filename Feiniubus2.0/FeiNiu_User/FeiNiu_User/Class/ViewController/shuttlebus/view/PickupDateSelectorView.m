//
//  DateSelectorVV.m
//  FeiNiu_User
//
//  Created by CYJ on 16/4/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "PickupDateSelectorView.h"

@interface PickupDateSelectorView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    __weak IBOutlet UIView *mainView;
    __weak IBOutlet NSLayoutConstraint *mainViewBottom;
    __weak IBOutlet UIPickerView *myPickerView;
    
    NSMutableArray *dayArray;       //天
    NSMutableArray *hourArray;      //小时
    NSMutableArray *minuteArray;      //分钟

    NSInteger seleDayIndex,seleHourIndex,seleMinuteIndex;  //当前选中index
}
@end

@implementation PickupDateSelectorView

- (instancetype)initWithFrame:(CGRect)frame starTime:(NSDate *) starTime endTime:(NSDate *)endTime minuteInterval:(NSInteger) minuteInterval
{
    if (self = [super initWithFrame:frame]) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"PickupDateSelectorView" owner:self options:nil][0];
        self.frame = frame;
        self.backgroundColor = UITranslucentBKColor;
        myPickerView.delegate = self;
        myPickerView.dataSource = self;
        [self resetDateSource:starTime endTime:endTime minuteInterval:minuteInterval];

    }
    return self;
}

- (void)resetDateSource:(NSDate*)starTime endTime:(NSDate*)endTime minuteInterval:(NSInteger) minuteInterval{
    
    self.starTime = [starTime dateByAddingTimeInterval:minuteInterval * 60]; //加10分钟
    self.endTime = endTime;
    self.minuteInterval = minuteInterval;
    
    [self initiDay];
    [self initHour];
    [self initMinute];
    
    //初始化默认值
    seleDayIndex = 0;
    seleHourIndex = 0;
    seleMinuteIndex= 0;
    
    //指定显示时间
    if (self.specTime) {
        NSString *day = [DateUtils formatDate:self.specTime format:@"yyyy-MM-dd"];
        NSString *hour = [DateUtils formatDate:self.specTime format:@"H"];
        NSString *minute = [DateUtils formatDate:self.specTime format:@"mm"];
        
        for (int i=0; i<dayArray.count; i++) {
            NSString *item = dayArray[i];
            if ([day isEqualToString:item]) {
                seleDayIndex = i;
                break;
            }
        }
        
        for (int i=0; i<hourArray.count; i++) {
            NSString *item = hourArray[i];
            if ([hour isEqualToString:item]) {
                seleHourIndex = i;
                break;
            }
        }
        
        for (int i=0; i<minuteArray.count; i++) {
            NSString *item = minuteArray[i];
            if ([minute isEqualToString:item]) {
                seleMinuteIndex = i;
                break;
            }
        }
    }
    
    [myPickerView reloadAllComponents];
    [myPickerView selectRow:seleDayIndex inComponent:0 animated:YES];
    [myPickerView selectRow:seleHourIndex inComponent:1 animated:YES];
    [myPickerView selectRow:seleMinuteIndex inComponent:2 animated:YES];
    
    [self layoutIfNeeded];
}

- (void)initiDay
{
    dayArray = @[].mutableCopy;
    
    //天数时间
    NSString *start = [DateUtils formatDate:self.starTime format:@"yyyy-MM-dd"];
    NSString *end = [DateUtils formatDate:self.endTime format:@"yyyy-MM-dd"];
    
    do{
        [dayArray addObject:start];
        start = [DateUtils afterDays:1 date:start format:@"yyyy-MM-dd"];  //加一天
    }while ( [[DateUtils dateFromString:start format:@"yyyy-MM-dd"] compare:[DateUtils dateFromString:end format:@"yyyy-MM-dd"]] < 1 );
}

-(void)initHour {
    
    //hourArray = @[].mutableCopy;
    
    NSMutableArray *tempArray = @[].mutableCopy;
    //小时  如果天选择的是第一个
    int startHour = 0;
    int endHour = 23;
    if (seleDayIndex == 0) {
        NSString *hourString = [DateUtils formatDate:self.starTime format:@"HH"];
        startHour = [hourString intValue];
    }
    if (seleDayIndex == dayArray.count - 1) {
        NSString *hourString = [DateUtils formatDate:self.endTime format:@"HH"];
        endHour = [hourString intValue];
    }
    while (startHour <= endHour) {
        [tempArray addObject:[[NSString alloc] initWithFormat:@"%d",startHour]];
        startHour ++;
    }
    
    if (hourArray && tempArray.count != hourArray.count) {
        hourArray = tempArray.mutableCopy;
        seleHourIndex = 0;
        [myPickerView reloadComponent:1];
        [myPickerView selectRow:seleHourIndex inComponent:1 animated:YES];
    }
    else {
        hourArray = tempArray.mutableCopy;
    }
    
}

-(void)initMinute {
    //minuteArray = @[].mutableCopy;
    
    NSMutableArray *tempArray = @[].mutableCopy;
    //分钟 如果天和小时都选择的第一个
    int startMinute = 0;
    int endMinute = 60 - (int)self.minuteInterval;
    if (seleDayIndex == 0 && seleHourIndex == 0) {
        NSString *startMinuteString = [DateUtils formatDate:self.starTime format:@"mm"];
        int minute = [startMinuteString intValue] % (int)self.minuteInterval;
        //取整
        startMinute = [startMinuteString intValue] - minute;
        
    }
    if (seleDayIndex == dayArray.count - 1 && seleHourIndex == hourArray.count - 1) {
        NSString *endMinuteString = [DateUtils formatDate:self.endTime format:@"mm"];
        int minute = [endMinuteString intValue] % (int)self.minuteInterval;
        //取整
        endMinute = [endMinuteString intValue] - minute;
    }
    while (startMinute <= endMinute) {
        [tempArray addObject:[[NSString alloc] initWithFormat:@"%d",startMinute]];
        startMinute = startMinute + (int)self.minuteInterval;
    }
    
    if (minuteArray && tempArray.count != minuteArray.count) {
        minuteArray = tempArray.mutableCopy;
        seleMinuteIndex = 0;
        [myPickerView reloadComponent:2];
        [myPickerView selectRow:seleMinuteIndex inComponent:2 animated:YES];
    }
    else {
        minuteArray = tempArray.mutableCopy;
    }
}


- (IBAction)cancleAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = - self.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)clickCompleteAction:(UIButton *)sender
{
    [self cancleAction:nil];
    
    NSString *dayStr,*hourStr,*minuteStr;
    
    dayStr = dayArray[seleDayIndex];
    hourStr = hourArray[seleHourIndex];
    minuteStr = minuteArray[seleMinuteIndex];

    NSString *seleterDateString = [NSString stringWithFormat:@"%@ %@:%@:00",dayStr,hourStr,minuteStr];
    NSDate *seleterDate = [DateUtils dateFromString:seleterDateString format:@"yyyy-MM-dd HH:mm:ss"];
    
    if (_clickCompleteBlock) _clickCompleteBlock(seleterDateString,seleterDate,NO);
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = 0;
        [view layoutIfNeeded];
    }];
}

//-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [self cancleAction:nil];
//}

- (IBAction)tapGestrue:(id)sender {
    [self cancleAction:nil];
}

#pragma mark -- UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return dayArray.count;
        case 1:
            return hourArray.count;
        case 2:
            return minuteArray.count;
        default:
            break;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return pickerView.bounds.size.width/2.2;
    }
    else{
        return (pickerView.bounds.size.width - pickerView.bounds.size.width/2.2)/2.0;
    }
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 24.f;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    
    switch (component) {
        case 0:
            returnStr = dayArray[row];
            break;
        case 1:
            returnStr = [NSString stringWithFormat:@"%@点",hourArray[row]];
            break;
        case 2:
            returnStr = [NSString stringWithFormat:@"%@分",minuteArray[row]];
            break;
            
        default:
            break;
    }
    return returnStr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            seleDayIndex = row;
            [self initHour];
            [self initMinute];

        }
            break;
        case 1:
        {
            seleHourIndex = row;
            [self initMinute];
        }
            break;
        case 2:
        {
            seleMinuteIndex = row;
        }
            break;
        default:
            break;
    }
   
    [myPickerView reloadAllComponents];
}

@end
