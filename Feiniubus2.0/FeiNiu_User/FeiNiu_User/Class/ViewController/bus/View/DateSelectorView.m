//
//  DateSelectorVV.m
//  FeiNiu_User
//
//  Created by CYJ on 16/4/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "DateSelectorView.h"

@interface DateSelectorView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    __weak IBOutlet UIView *mainView;
    __weak IBOutlet NSLayoutConstraint *mainViewBottom;
    __weak IBOutlet UIPickerView *myPickerView;
    
    NSMutableArray *yearsArray;
    
    NSMutableArray *hourArray;
    NSMutableArray *currentDayHourArray;
    
    NSMutableArray *timeArray;
    NSMutableArray *currentTimeArray;

    NSInteger seleYearIndex,seleHourIndex,seleMinuteIndex;  //当前选中index
    
    BOOL currentTime;       //选择现在
    
}
@end

@implementation DateSelectorView

- (instancetype)initWithFrame:(CGRect)frame starTime:(NSString *) starTime endTime:(NSString *)endTime minuteInterval:(NSInteger) minuteInterval
{
    if (self = [super initWithFrame:frame]) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"DateSelectorView" owner:self options:nil][0];
        self.frame = frame;
        self.backgroundColor = UITranslucentBKColor;;
        myPickerView.delegate = self;
        myPickerView.dataSource = self;
        
        self.starTime = starTime;
        self.endTime = endTime;
        self.minuteInterval = minuteInterval;
        
        [self initializeDates];
        
        //初始化默认值
        seleYearIndex = 0;
        seleHourIndex = 0;
        seleMinuteIndex= 0;
        currentTime = YES;
        
        [self pickerView:myPickerView didSelectRow:0 inComponent:0];
        [self pickerView:myPickerView didSelectRow:0 inComponent:1];
    }
    return self;
}

- (void)initializeDates
{
    timeArray = @[].mutableCopy;
    hourArray = @[].mutableCopy;
    currentDayHourArray = @[].mutableCopy;
    currentTimeArray = @[].mutableCopy;
    
    //初始化 今天  明天 后天
    NSDate *now = [NSDate date];
    NSString *currentYear = [DateUtils formatDate:now format:@"yyyy-MM-dd"];
    
    NSDate *tomorrow = [DateUtils addDate:now interval:24*3600];
    NSString *tomorrowYear = [DateUtils formatDate:tomorrow format:@"yyyy-MM-dd"];
    
    NSDate *afterTomorrow = [DateUtils addDate:now interval:24*3600*2];
    NSString *afterTomorrowYear = [DateUtils formatDate:afterTomorrow format:@"yyyy-MM-dd"];
    
    yearsArray = @[currentYear,tomorrowYear,afterTomorrowYear].mutableCopy;
    
    
    //生成范围Date
    NSDate *starDate = [DateUtils stringToDate:[NSString stringWithFormat:@"%@ %@",[DateUtils today],_starTime]];
    NSDate *endDate  = [DateUtils stringToDate:[NSString stringWithFormat:@"%@ %@",[DateUtils today],_endTime]];
    
    
    //小时
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH"];
    NSInteger starHour = [[NSString stringWithFormat:@"%@",
                           [formatter stringFromDate:starDate]] integerValue];
    NSInteger endHour = [[NSString stringWithFormat:@"%@",
                          [formatter stringFromDate:endDate]] integerValue];
    
    //初始化范围可选小时数组     默认
    NSInteger hour = starHour;
    while (hour <= endHour) {
        [hourArray addObject:@(hour)];
        hour += 1;
    }
    
    //初始化范围可选分钟数组     默认
    int minutes = 0;
    while (minutes < 60) {
        [timeArray addObject:@(minutes)];
        minutes += _minuteInterval;
    }
    
    //---------------------------生成当天数据---------------------------------------
    //延后3小时 取小时
    NSDate *delayDate = [DateUtils addDate:now interval:60*180];     //延迟3小时以后
    NSInteger delayHour = [[NSString stringWithFormat:@"%@",
                            [formatter stringFromDate:delayDate]] integerValue];
    //取分钟
    [formatter setDateFormat:@"mm"];
    NSInteger delayminutes = [[NSString stringWithFormat:@"%@",
                               [formatter stringFromDate:delayDate]] integerValue];
    
    //大于50分钟 进入下一个小时  分钟重00开始
    if (delayminutes >= 50) {
        delayHour += 1;
        delayminutes = 0;
    }else{
        delayminutes = delayminutes/10*10 + _minuteInterval;    //去掉尾数分钟，同时进入下一个可选时间
    }
    
    //初始化当天可选小时
    NSInteger currentHour = delayHour;
//    if (currentHour <= endHour) {//在范围内才加
//         [currentDayHourArray addObject:@(currentHour)];     //添加
//    }
    while (currentHour <= endHour) {
        [currentDayHourArray addObject:@(currentHour)];
        currentHour += 1;
    }
    
    NSInteger currentMinute = delayminutes;
    while (currentMinute < 60) {
        [currentTimeArray addObject:@(currentMinute)];
        currentMinute += _minuteInterval;
    }
    
    //如果今天没有可选时间 删除今天
    [formatter setDateFormat:@"HH"];
    NSInteger nowHour = [[NSString stringWithFormat:@"%@",
                            [formatter stringFromDate:now]] integerValue];
    if (nowHour+2 >= 24) {
        [yearsArray removeObjectAtIndex:0];
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
    
    //如果选择当前直接返回------ ‘现在’ 取消2016年5月12
//    if (seleYearIndex == 0 && seleHourIndex == 0) {
//        NSDate *now = [NSDate date];
//        NSString *currentDate = [DateUtils formatDate:[DateUtils addDate:now interval:60*2] format:@"yyyy-MM-dd hh:mm:ss"];
//        if (_clickCompleteBlock) _clickCompleteBlock(@"现在",currentDate,YES);
//        return;
//    }
    
    NSString *yearStr,*hourStr,*minuteStr;
    if (yearsArray.count == 2) {
        switch (seleYearIndex) {
        case 0:
            yearStr = @"明天";
            break;
        case 1:
            yearStr = @"后天";
            break;
            
        default:
            break;
        }
    }else{
        switch (seleYearIndex) {
            case 0:
                yearStr = @"今天";
                break;
            case 1:
                yearStr = @"明天";
                break;
            case 2:
                yearStr = @"后天";
                break;
                
            default:
                break;
        }
    }
    
    //是否选择今天
    if (seleYearIndex == 0) {
        hourStr = [NSString stringWithFormat:@"%.2ld",[currentDayHourArray[seleHourIndex] integerValue]];
        if (seleHourIndex == 0) {
            minuteStr = [NSString stringWithFormat:@"%.2ld",[currentTimeArray[seleMinuteIndex] integerValue]];
        }else{
            minuteStr = [NSString stringWithFormat:@"%.2ld",[timeArray[seleMinuteIndex] integerValue]];
        }
        
    }else{
        hourStr = [NSString stringWithFormat:@"%.2ld",[hourArray[seleHourIndex] integerValue]];
        minuteStr = [NSString stringWithFormat:@"%.2ld",[timeArray[seleMinuteIndex] integerValue]];
    }
    
    
    NSString *seleterDate = [NSString stringWithFormat:@"%@ %@:%@:00",yearsArray[seleYearIndex],hourStr,minuteStr];
    NSString *seleterDateString = [NSString stringWithFormat:@"%@ %@:%@:00",yearStr,hourStr,minuteStr];
    
    if (_clickCompleteBlock) _clickCompleteBlock(seleterDateString,seleterDate,NO);
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = 0;
        [view layoutIfNeeded];
    }];
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
            return yearsArray.count;
            break;
        case 1:
            if (seleYearIndex == 0) {
                 return currentDayHourArray.count;
            }else{
                return hourArray.count;
            }
            break;
        case 2:
//            if (currentTime) {
//                return 0;
//            }
//            if (!currentDayHourArray || currentDayHourArray.count == 0) {
//                return 0;
//            }
//            
            if (seleHourIndex == 0 && seleYearIndex == 0) {     //未取消'现在' seleHourIndex == 1，
                return currentTimeArray.count;
            }
            return timeArray.count;
            break;
            
        default:
            break;
    }
    return 0;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            if (yearsArray.count == 2) {
                switch (row) {
                    case 0:
                        return @"明天";
                        break;
                    case 1:
                        return @"后天";
                        break;

                    default:
                        break;
                }
            }
            switch (row) {
                case 0:
                    return @"今天";
                    break;
                case 1:
                    return @"明天";
                    break;
                case 2:
                    return @"后天";
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            if (seleYearIndex == 0) {
//                if (row == 0) {
//                    return @"现在";
//                }else{
                    return [NSString stringWithFormat:@"%@点",currentDayHourArray[row]];
//                }
            }else{
                return [NSString stringWithFormat:@"%@点",hourArray[row]];
            }
            break;
        case 2:
            if (seleHourIndex == 0 && seleYearIndex == 0) {     ////未取消'现在' seleHourIndex == 1，
                return [NSString stringWithFormat:@"%@分",currentTimeArray[row]];
            }
            return [NSString stringWithFormat:@"%@分",timeArray[row]];
            break;
            
        default:
            break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            seleYearIndex = row;
//            if (seleHourIndex == 0 && row == 0) {
//                currentTime = YES;
//            }else{
//                currentTime = NO;
//            }
        }
            break;
        case 1:
        {
            seleHourIndex = row;
//            if (seleYearIndex == 0 && row == 0) {
//                currentTime = YES;
//            }else{
//                currentTime = NO;
//            }
        }
            break;
        case 2:
        {
            seleMinuteIndex = row;
//            currentTime = NO;
        }
            break;
        default:
            break;
    }
    [myPickerView reloadAllComponents];
}

@end
