//
//  UrlMaps.h
//  FNNetInterface
//
//  Created by tianbo on 16/1/18.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UrlMapsInstance  [UrlMaps sharedInstance]

@interface UrlMaps : NSObject

+(UrlMaps*)sharedInstance;

-(void)resetUrlMaps:(NSDictionary*)dict;

-(NSString*)urlWithTypeNew:(int)type;
@end
