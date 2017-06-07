//
//  CustomSearchDisplayController.m
//  FNMap
//
//  Created by iamdzz on 15/10/6.
//  Copyright © 2015年 feiniubus. All rights reserved.
//

#import "CustomSearchDisplayController.h"

@implementation CustomSearchDisplayController

//stop animation and show navigationbar
-(void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive:visible animated:NO];
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end
