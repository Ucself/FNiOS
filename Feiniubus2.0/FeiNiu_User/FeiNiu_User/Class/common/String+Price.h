//
//  String+Price.h
//  FeiNiu_User
//
//  Created by tianbo on 2017/1/20.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Price)

+(NSString*)calculatePrice:(NSInteger)price;
+(NSString*)calculatePriceNO:(NSInteger)price;

@end
