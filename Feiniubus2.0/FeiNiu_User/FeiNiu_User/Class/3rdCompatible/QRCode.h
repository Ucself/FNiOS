//
//  QRCode.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/10.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCode : NSObject
+ (UIImage *)generateQRImageForString:(NSString *)string;
@end
