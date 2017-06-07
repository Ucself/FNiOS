//
//  DBHelper.m
//  XinRanApp
//
//  Created by tianbo on 15-3-23.
//  Copyright (c) 2015年 mac.com All rights reserved.
//

#import "DBHelper.h"
#import <FNDBManager/FMDBUtils.h>


@implementation DBHelper

+(void)initDB
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        if (![FMDBUtils checkDB]) {
            if ([FMDBUtils createDB]) {
                [DBHelper createTable];
            }
        }
    });
}

+(void)createTable
{
}
@end
