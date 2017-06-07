//
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

//当前时间
+ (NSString *) now;
//今天
+ (NSString *) today;
//今天dd/MM
+ (NSString *) todayfmtDDMM;

//之后
+ (NSString *) afterDays:(int)days date:(NSString *)strDate format:(NSString*)format;

//之前
+ (NSString *) beforeDays:(int)days date:(NSString *)strDate format:(NSString*)format;


//根据时间获取客户端id
+ (NSString *) clientId:(NSString *)projectId;

+ (BOOL) beforeNow:(NSString *)date;

+ (NSDate *)stringToDate:(NSString *)time;

+ (NSDate *)stringToDateRT:(NSString *)time;

/**
 *  格式化时间到字符串
 *
 *  @param date   要格式化的日间
 *  @param format 指定格式   如：@"yyyy-MM-dd"
 *
 *  @return 格式化后的字符串
 */
+(NSString*) formatDate:(NSDate*)date format:(NSString*)format;

/**
 *  时间差
 *
 *  @return
 */
+ (NSString *)intervalStringFromLastDate: (NSDate *)d1  toTheDate:(NSDate *)d2;

/**
 *  时间添加
 *
 *  @param interval 时间 秒
 *
 *  @return 相加后的时间
 */
+ (NSDate*)addDate:(NSDate*)date interval:(NSInteger)interval;
/**
 *  将字符串以指定格式转换为date
 *
 *  @param dateString 时间字符串
 *  @param format     格式化字符串，例如： yyyy-MM-dd HH:mm:ss
 *
 *  @return date
 */
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;

/**
 *  数字转时间
 *
 */
+ (NSString *)timeFormatted:(int)totalSeconds;

/**
 *  日期转星期
 *
 *  @param date 日期
 *
 *  @return 星期
 */
+(NSString*)weekFromDate:(NSDate*)date;
/**
 *  日期转农历
 *
 *  @param date 日期
 *
 *  @return
 */
+(NSString*)chineseDayFromDate:(NSDate *)date;

/**
 *  是否是同一天
 *
 *  @param date1 date1
 *  @param date2 date2
 *
 *  @return
 */
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;
@end



