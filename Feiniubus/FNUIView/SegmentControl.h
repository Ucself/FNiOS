//
//  SegmentControl.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentControl : UIView
{
    
}

@property (nonatomic, assign) int index;

-(void)setItems:(NSArray*)items;


-(void)setHighlightColor:(UIColor*)color;

@end
