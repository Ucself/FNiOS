//
//  HeaderCollectionReusableView.m
//  UICollectionView
//
//  Created by smith on 15/12/10.
//  Copyright © 2015年 smith. All rights reserved.
//

#import "CalendarHeaderView.h"




//获取屏幕宽度
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width

//获取屏幕高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height



@implementation CalendarHeaderView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithWhite:1. alpha:.0];
        
        UIView *  priceView = [[UIView alloc]initWithFrame:frame];
        
        
        NSArray * weekArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        
        for (int i = 0; i < 7; i++)
            
        {
        
            UILabel * weekView= [[UILabel alloc]initWithFrame:CGRectMake(i * frame.size.width/7, 0, frame.size.width/7, frame.size.height)];
            weekView.textAlignment = 1;
            weekView.text = weekArray[i];
            weekView.textColor = UITextColor_Black;
            weekView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.94 green:0.97 blue:1 alpha:1];
            weekView.font = [UIFont systemFontOfSize:12];
            [priceView addSubview:weekView];
        }
        
        [self addSubview:priceView];
        
        
        UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0 , 0 , frame.size.width, 0.5)];
        line2.backgroundColor = UIColorFromRGB(0xe6e6e6);
        [self addSubview:line2];
        
        UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0 , frame.size.height - 1 , frame.size.width, 0.5)];
        line3.backgroundColor = UIColorFromRGB(0xe6e6e6);//[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1];
        [self addSubview:line3];

    }

   
    return self;
}

@end
