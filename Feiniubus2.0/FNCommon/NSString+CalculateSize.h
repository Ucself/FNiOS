//
//  NSString+CalculateSize.h
//  V_Cat
//
//  Created by my on 15/7/28.
//  Copyright (c) 2015年 ChenYJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRange.h"

@interface NSString (CalculateSize)
/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width lineSpacing:(CGFloat)lineSpacing;
/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;


/**
 * @breif 修改字符串属性
 */
+ (id)hintStringWithIntactString:(NSString *)intactString hintString:(NSString *)remain intactColor:(UIColor *)intactColor hintColor:(UIColor *)hintColor;

+ (id)hintMainString:(NSString *)mainString rangs:(NSMutableArray *)rangs defaultColor:(UIColor *)defaultColor changeColor:(UIColor *)changeColor;

+ (id)hintStringFontSize:(NSString *)mainString rangs:(NSMutableArray*)rangs defaultFontSize:(UIFont *)defaultFont changeFontSize:(UIFont *)changeFont;
/**
 * @breif Url特殊字符编码
 */
+ (NSString *)urlEncodedString:(NSString *)sourceText;

/**
 * @breif 对象转字符串
 */
+ (NSString*)getJson:(NSDictionary*)dicData;

@end

