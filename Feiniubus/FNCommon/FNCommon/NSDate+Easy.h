//
//  NSDate+Easy.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/9/28.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const defaultDateFormat;

@interface NSDate (Easy)

/**
 *  @author Nick
 *
 *  默认格式：yyyy-MM-dd HH:mm:ss
 *
 *  @return
 */
- (NSString *)timeStringByDefault;

- (NSString *)timeStringByFormat:(NSString *)format;

/**
 *  @author Nick
 *
 *  将格式为“yyyy-MM-dd HH:mm:ss”的字符串转换为Date
 *
 *  @param string string description
 *
 *  @return return value description
 */
+ (NSDate *)dateFromString:(NSString *)string;

/**
 *  @author Nick
 *
 *  将字符串以指定格式转换为date
 *
 *  @param dateString 时间字符串
 *  @param format     格式化字符串，例如： yyyy-MM-dd HH:mm:ss
 *
 *  @return date
 */
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;





//当前时间
+ (NSString *) now;
//今天
+ (NSString *) today;
//今天dd/MM
+ (NSString *) todayfmtDDMM;

//之后
+ (NSString *) afterDays:(int)days date:(NSString *)date;
//之前
+ (NSString *) beforeDays:(int)days date:(NSString *)date;

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
+ (NSString *)intervalFromLastDate: (NSString *) dateString1  toTheDate:(NSString *) dateString2;

@end
