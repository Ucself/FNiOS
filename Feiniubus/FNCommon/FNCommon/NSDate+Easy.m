//
//  NSDate+Easy.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/9/28.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "NSDate+Easy.h"

 NSString *const defaultDateFormat = @"yyyy-MM-dd HH:mm:ss";

@implementation NSDate (Easy)
- (NSString *)timeStringByDefault{
    return [self timeStringByFormat:defaultDateFormat];
}
- (NSString *)timeStringByFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromString:(NSString *)string{
    return [self dateFromString:string format:defaultDateFormat];
}
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}




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
    
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
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
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [formatter stringFromDate:now];
    return time;
}


+ (NSString *) today{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *time = [formatter stringFromDate:now];
    return time;
}

+ (NSString *) todayfmtDDMM
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"dd/MM月"];
    NSString *time = [formatter stringFromDate:now];
    return time;
}

+ (NSString *) afterDays:(int)days date:(NSString *)date{
    
    //获取时间Time
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [formatter dateFromString:date];
    
    //加days天
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([now timeIntervalSinceReferenceDate] + 24*3600*(days-1))];
    
    NSString *time = [formatter stringFromDate:newDate];
    return time;
}

+ (NSString *) beforeDays:(int)days date:(NSString *)date{
    
    //获取时间Time
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [formatter dateFromString:date];
    
    //剪days天
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([now timeIntervalSinceReferenceDate] - 24*3600*(days-1))];
    
    NSString *time = [formatter stringFromDate:newDate];
    return time;
}

+ (NSString *) clientId:(NSString *)projectId{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *time = [formatter stringFromDate:now];
    return [NSString stringWithFormat:@"%@-%@",projectId,time ] ;
}


//转为时间格式
+ (NSDate *)stringToDate:(NSString *)time{
    NSDate *now = nil;//[NSDate date];
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    now = [formatter dateFromString:time];
    
    return now;
}

+ (NSDate *)stringToDateRT:(NSString *)time
{
    time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDate *now = nil;//[NSDate date];
    NSDateFormatter *formatter = [NSDate dateFormatterInstance];
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
    NSDateFormatter  *dateformatter = [NSDate dateFormatterInstance];
    [dateformatter setDateFormat:format];
    NSString *  dateString = [dateformatter stringFromDate:date];
    
    return dateString;
}

/**
 *  时间差
 *
 *  @return
 */
+ (NSString *)intervalFromLastDate: (NSDate *)d1  toTheDate:(NSDate *)d2
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

@end
