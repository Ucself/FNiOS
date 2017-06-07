//
//  LCTabBarButton.m
//  LuoChang
//
//  Created by Rick on 15/4/29.
//  Copyright (c) 2015年 Rick. All rights reserved.
//

#define kImageRatio 0.5

#import "LCTabBarButton.h"

@implementation LCTabBarButton



-(void)setHighlighted:(BOOL)highlighted{
    
}

#pragma mark 返回按钮内部titlelabel的边框
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
//    return CGRectMake(0, contentRect.size.height*kImageRatio-5, contentRect.size.width, contentRect.size.height-contentRect.size.height*kImageRatio);
    return CGRectMake(0, 34, contentRect.size.width, 14.f);
}

#pragma mark 返回按钮内部UIImage的边框
-(CGRect) imageRectForContentRect:(CGRect)contentRect{
//    return CGRectMake(0, 10, contentRect.size.width, contentRect.size.height*kImageRatio);
    return CGRectMake(contentRect.size.width/2.f - 12.f, 7, 24.f, 24.f);
}

@end
