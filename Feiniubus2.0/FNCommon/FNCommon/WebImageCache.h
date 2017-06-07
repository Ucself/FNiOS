//
//  ImageCache.h
//  FNCommon
//
//  Created by tianbo on 2017/5/11.
//  Copyright © 2017年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WebImageCache : NSObject

+(WebImageCache*)instance;

-(void)setFolder:(NSString*)folder;
-(void)saveImage:(NSString*)url name:(NSString*)name success:(void(^)(BOOL success))block;
-(UIImage*)loadImageWithName:(NSString*)name;
@end
