//
//  DateUtils.m
//  H8
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import "DateUtils.h"

NSString *const defaultDateFormat = @"yyyy-MM-dd HH:mm:ss";

@implementation DateUtils

+(NSDateFormatter*)dateFormatterInstance
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    
    return formatter;
}

+ (BOOL) beforeNow:(NSString *)date{
    NSDate *now = [NSDate date];
    
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *time = [formatter dateFromString:date];
    
    NSComparisonResult result = [now compare:time];
    if(result<0){
        return FALSE;
    }else{
        return TRUE;
    }
}

+ (NSString *) now{
    NSDate *now = [NSDate date];  
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  
    NSString *time = [formatter stringFromDate:now];
    return time;
}


+ (NSString *) today{
    NSDate *now = [NSDate date];  
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *time = [formatter stringFromDate:now];
    return time;
}

+ (NSString *) todayfmtDDMM
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"dd/MM月"];
    NSString *time = [formatter stringFromDate:now];
    return time;
}

+ (NSString *) afterDays:(int)days date:(NSString *)date format:(NSString*)format{

    //获取时间Time
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    if (format && format.length!= 0) {
        [formatter setDateFormat:format];
    }
    else {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *now = [formatter dateFromString:date];
    
    //加days天
    NSDate *newDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:now];
    
    NSString *time = [formatter stringFromDate:newDate];
    return time;
}


+ (NSString *) beforeDays:(int)days date:(NSString *)date format:(NSString*)format{
    
    //获取时间Time
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    if (format && format.length!= 0) {
        [formatter setDateFormat:format];
    }
    else {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *now = [formatter dateFromString:date];
    
    //剪days天
    NSDate *newDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:now];
    
    NSString *time = [formatter stringFromDate:newDate];
    return time;
}



+ (NSString *) clientId:(NSString *)projectId{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *time = [formatter stringFromDate:now];
    return [NSString stringWithFormat:@"%@-%@",projectId,time ] ;
}


//转为时间格式
+ (NSDate *)stringToDate:(NSString *)time{
    NSDate *now = nil;//[NSDate date];
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    now = [formatter dateFromString:time];

    return now;
}

+ (NSDate *)stringToDateRT:(NSString *)time
{
    time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDate *now = nil;//[NSDate date];
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    now = [formatter dateFromString:time];
    
    return now;
}

/**
 *  格式化时间到字符串
 *
 *  @param date   要格式化的日间
 *  @param format 指定格式   如：@"yyyy-MM-dd"
 *
 *  @return 格式化后的字符串
 */
+(NSString*) formatDate:(NSDate*)date format:(NSString*)format
{
    NSDateFormatter  *dateformatter = [DateUtils dateFormatterInstance];
    [dateformatter setDateFormat:format];
    NSString *  dateString = [dateformatter stringFromDate:date];
    
    return dateString;
}

/**
 *  时间差
 *
 *  @return
 */

+ (NSString *)intervalStringFromLastDate: (NSDate *)d1  toTheDate:(NSDate *)d2;
{
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    NSString *min=@"";
    NSString *sen=@"";
    
    sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    //        min = [min substringToIndex:min.length-7];
    //    秒
    sen=[NSString stringWithFormat:@"%@", sen];
    
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    //        min = [min substringToIndex:min.length-7];
    //    分
    min=[NSString stringWithFormat:@"%@", min];
    
    //    小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    //        house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    
    timeString=[NSString stringWithFormat:@"%@:%@:%@",house,min,sen];
    
    return timeString;
}


+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format{
    NSDateFormatter *formatter = [DateUtils dateFormatterInstance];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}

+ (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}

+(NSString*)weekFromDate:(NSDate*)date
{
    NSArray * arrWeek=[NSArray arrayWithObjects:@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六", nil];

    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
                        NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:date];
    
    NSInteger week = [comps weekday] - 1;
//    int year=[comps year];
//    int month = [comps month];
//    int day = [comps day];
    
    if (week < arrWeek.count) {
        return [arrWeek objectAtIndex:week];
    }
    
    return @"";
}

/**
 *  转换为农历
 *
 *  @param date date description
 *
 *  @return return value description
 */
+(NSString*)chineseDayFromDate:(NSDate *)date{
    
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

+ (NSDate*)addDate:(NSDate*)date interval:(NSInteger)interval
{
    return [date dateByAddingTimeInterval:interval];
}

/**
 *  是否是同一天
 *
 *  @param date1 date1
 *  @param date2 date2
 *
 *  @return
 */
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    
    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
}
@end
