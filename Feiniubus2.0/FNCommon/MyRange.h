//
//  MyRange.h
//  FNCommon
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyRange : NSObject

@property(nonatomic, assign) NSUInteger location;

@property(nonatomic, assign) NSUInteger length;

-(id)initWithContent:(NSUInteger)location length:(NSUInteger)length;

@end
