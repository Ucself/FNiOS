//
//  MyRange.m
//  FNCommon
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import "MyRange.h"

@implementation MyRange


-(id)initWithContent:(NSUInteger)location length:(NSUInteger)length
{
    if (self = [super init]) {
        self.location = location;
        self.length = length;
    }
    return self;
}
@end
