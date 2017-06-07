//
//  BCBaseObject.m
//  ChangQu
//
//  Created by 牛 方健 on 13-4-17.
//  Copyright (c) 2013年 BC. All rights reserved.
//

#import "BCBaseObject.h"
#import <CommonCrypto/CommonDigest.h>

@implementation BCBaseObject



/*
 *  用正则判断用户名，是否2－16位
 */
+ (BOOL) checkInputUserName:(NSString *)text
{
    NSString *Regex = @"^\\w{2,16}$";
    NSPredicate *userName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [userName evaluateWithObject:text];
}


/*
 *  用正则判断邮箱
 */
+ (BOOL) checkInputEmail:(NSString *)text
{
    NSString *Regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *email = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [email evaluateWithObject:text];
}

/*
 *  请输入6-16位字母和数字,符号两种以上组合
 */
+ (BOOL) checkInputPassword:(NSString *)text
{
//    NSString *Regex = @"^(?![0-9]+$)[\\@A-Za-z0-9\\-\\/\\:\\;\\(\\)\\$\\&\\@\\”\\.\\,\\?\\!\\’\\[\\]\\{\\}\\#\\%\\^\\*\\+\\=\\_\\|\\~\\<\\>\\€\\£\\¥\\•']{6,16}$";
    NSString *Regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z\\-\\/\\:\\;\\(\\)\\$\\&\\@\\”\\.\\,\\?\\!\\’\\[\\]\\{\\}\\#\\%\\^\\*\\+\\=\\_\\|\\~\\<\\>\\€\\£\\¥\\•]{6,16}$";
    NSPredicate *password = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [password evaluateWithObject:text];
}

/*
 *  得到字符串长度 中英文混合情况下
 */
+(int)lengthToInt:(NSString*)string;
{
    //去掉空格
    NSString *st = [string  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int strlength = 0;
    char* p = (char*)[st cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[st lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

/*
 *  将字符串进行MD5加密，返回加密后的字符串
 */

+ (NSString *) MD5Hash:(NSString*) aString
{
	const char *cStr = [aString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, strlen(cStr), result);
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]];
}

+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|4[0-9]|5[0-35-9]|7[0-9]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[0-9]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
/*
 * FN的电话验证
 */
+(BOOL)isFNMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^(1[3|4|5|6|7|8])\\d{9}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobileNum];
}

/*
 *  URL解码
 */
+ (NSString *)URLDecodedString:(NSString*)stringURL
{
	return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                        (CFStringRef)stringURL,
                                                                                        CFSTR(""),
                                                                                        kCFStringEncodingUTF8);
}

///*
// *  图片变灰
// */
//+ (UIImage *)grayscaleWithImage:(UIImage *)image
//{
//	CGSize size = image.size;
//	CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
//	
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
//	CGColorSpaceRelease(colorSpace);
//	
//	CGContextDrawImage(context, rect, [image CGImage]);
//	CGImageRef grayscale = CGBitmapContextCreateImage(context);
//	CGContextRelease(context);
//	
//	UIImage * image1 = [UIImage imageWithCGImage:grayscale];
//	CFRelease(grayscale);
//	
//	return image1;
//}

/*
 *  判断字符串是否是数字组成
 */
+ (BOOL)isNumberStr:(NSString*)string
{
    NSString *number =@"0123456789";
    NSCharacterSet * cs =[[NSCharacterSet characterSetWithCharactersInString:number]invertedSet];
    NSString * comparStr = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
    return [string isEqualToString:comparStr];
}

/*
 *  判断手机型号是否是iPhone5；
 */
+ (BOOL)isiPhone5Height:(NSInteger)height
{
    if (height>481) {
        return YES;
    }else
    {
        return NO;
    }
}

/*
 *  判断是否是身份证
 *  需要-(BOOL)isNumberStr:(NSString*)string配合
 */
+(BOOL)isPersonCard:(NSString*)string
{
    //    DBG_MSG(@"%d",[self length]);
    if ([string length]!= 15 && [string length] != 18)
    {
        return NO;
    }
    else if ( ([string length] == 18 ||[string length] ==15) && [self isNumberStr:string])
    {
        return YES;
    }
    else if ([string length] == 18  && ([self isNumberStr:[string substringToIndex:17] ] && ([string hasSuffix:@"X"] || [string hasSuffix:@"x"])))
    {
        return YES;
    }
    else
    {
        return NO;
    }

}

/*
 *  判断String中是否都是数字
 */
-(BOOL)isNumberStr:(NSString*)string
{
    NSString *number =@"0123456789";
    NSCharacterSet * cs =[[NSCharacterSet characterSetWithCharactersInString:number]invertedSet];
    NSString * comparStr = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
    return [string isEqualToString:comparStr];
}

/**
 *  判断字符串是否全是数字与字母
 */
+(BOOL)isNumberandLetterStr:(NSString*)string
{
    NSString *number =@"0123456789abcefghijklmnopqrstuvwxyzABCEFGHIJKLMNOPQRSTUVWXYZ";
    NSCharacterSet * cs =[[NSCharacterSet characterSetWithCharactersInString:number]invertedSet];
    NSString * comparStr = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
    return [string isEqualToString:comparStr];
}
/*
 *  请输入6-16位字母和数字,符号两种以上组合
 */
+ (BOOL)isChineseStr:(NSString *)string
{
    NSString *Regex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *textString = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [textString evaluateWithObject:string];
}

/**
 *  判断字符串是否包含中文
 */
+(BOOL)isHasChineseCharacter:(NSString*)string
{
    BOOL ret = NO;
    for(int i=0; i< [string length];i++){
        int a = [string characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
            ret = YES;
    }

    return ret;
}
/*
 *  是否为车辆牌照
 */
+(BOOL)isLicensePlate:(NSString*)string
{
    NSString *Regex = @"^[\u4e00-\u9fa5]{1}[A-Z]{1}[A-Z_0-9]{5}$";
    NSPredicate *textString = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [textString evaluateWithObject:string];
}
/*
 *  是否为中文 英文字母  点  空格
 */
+(BOOL)isSpecialName:(NSString*)string
{
    NSString *Regex = @"^[a-zA-Z\u4e00-\u9fa5 .]+$";
    NSPredicate *textString = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [textString evaluateWithObject:string];
}

@end
