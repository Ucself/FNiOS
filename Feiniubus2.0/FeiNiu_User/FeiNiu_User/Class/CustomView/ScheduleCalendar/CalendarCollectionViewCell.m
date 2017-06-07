//
//  CollectionViewCell.m
//  GJCAR.COM
//
//  Created by 段博 on 16/5/26.
//  Copyright © 2016年 DuanBo. All rights reserved.
//

#import "CalendarCollectionViewCell.h"

#import "CalendarUtils.h"

#import <FNUIView/BaseUIView.h>


@interface CalendarCollectionViewCell ()

@property (weak, nonatomic) CAShapeLayer *selectionLayer;



@end

@implementation CalendarCollectionViewCell


-(instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        [self createUI];
    }
    
    return self;
}



-(void)createUI
{
//    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0 , 0 , ScreenWidth/7, 0.5)];
//    line.backgroundColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1];
//    [self addSubview:line];
    
//    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth/7, 0, 0.5, ScreenWidth/7)];
//    line2.backgroundColor =[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1] ;
//    [self addSubview:line2];
    
//    CAShapeLayer *selectionLayer = [[CAShapeLayer alloc] init];
//    selectionLayer.fillColor = UIColor_DefOrange.CGColor;
//    //selectionLayer.actions = @{@"hidden":[NSNull null]};
//    [self.contentView.layer insertSublayer:selectionLayer below:self.dateLabel.layer];
//    self.selectionLayer = selectionLayer;
//    self.selectionLayer.frame = CGRectInset(self.bounds, -0.2, 0.2);
//    self.selectionLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.selectionLayer.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(0, 0)].CGPath;
//    self.selectionLayer.hidden = YES;

    self.backgroundColor = [UIColor colorWithWhite:1. alpha:.0];
    
    UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0 , 44 , ScreenWidth/7, 0.5)];
    line3.backgroundColor = UIColorFromRGB(0xe6e6e6);//[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1];
    [self addSubview:line3];

    self.selectView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, -0.2, 0.3)];
    self.selectView.backgroundColor = UIColor_DefOrange;
    [self addSubview:self.selectView];
    self.selectView.hidden = YES;

    
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth/7, 24)];
    self.dateLabel.textColor = UITextColor_LightGray;
    self.dateLabel.textAlignment= 1 ;
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.dateLabel];
    
    
    self.detailLable = [[UILabel alloc]initWithFrame:CGRectZero];
    //self.detailLable.backgroundColor = UIColor_DefOrange;
    self.detailLable.textColor = [UIColor whiteColor];
    self.detailLable.textAlignment= 1 ;
    self.detailLable.font = [UIFont systemFontOfSize:12];
    self.detailLable.layer.cornerRadius = 3;
    self.detailLable.layer.masksToBounds = YES;
    [self addSubview:self.detailLable];
    self.detailLable.hidden = YES;
    
    [self.detailLable makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(-7);
        make.width.equalTo(30);
        make.height.equalTo(14);
    }];
    
}
//
//-(void)layoutSubviews
//{
//    
//    if (self.selected) {
//        //self.selectionLayer.hidden = NO;
//        self.selectView.hidden = NO;
//        self.detailLable.backgroundColor = [UIColor whiteColor];
//        self.detailLable.textColor = UIColor_DefOrange;
//    }
//    else {
//        //self.selectionLayer.hidden = YES;
//        self.selectView.hidden = YES;
//        self.detailLable.backgroundColor = UIColor_DefOrange;
//        self.detailLable.textColor = [UIColor whiteColor];
//    }
//    
//}

@end
