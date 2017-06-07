//
//  SegmentControl.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "SegmentControl.h"

@interface SegmentControl ()
{
    
}
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) UIColor *lightColor;

@end

@implementation SegmentControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)initControls
{
    
}

-(void)setIndex:(int)index
{
    if (self.index != index) {
        self.index = index;
        
    }
    
}

-(void)setItems:(NSArray*)items
{
    self.items = items;
}


-(void)setHighlightColor:(UIColor*)color
{
    self.lightColor = color;
}

@end
