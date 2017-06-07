//
//  String+Price.m
//  FeiNiu_User
//
//  Created by tianbo on 2017/1/20.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import "String+Price.h"

@implementation NSString (Price)

+(NSString*)calculatePrice:(NSInteger)price
{
    if (price % 10 != 0) {
        return [NSString stringWithFormat:@"¥%.2f", price/100.0];
    }
    else if (price % 100 != 0) {
        return [NSString stringWithFormat:@"¥%.1f", price/100.0];
    }
    else {
        return [NSString stringWithFormat:@"¥%ld", price/100];
    }
}
+(NSString*)calculatePriceNO:(NSInteger)price
{
    if (price % 10 != 0) {
        return [NSString stringWithFormat:@"%.2f", price/100.0];
    }
    else if (price % 100 != 0) {
        return [NSString stringWithFormat:@"¥%.1f", price/100.0];
    }
    else {
        return [NSString stringWithFormat:@"%ld", price/100];
    }
}

@end
