//
//  SelectView.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/19.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"


typedef NS_ENUM(int, SelectType)
{
    SelectType_Sex = 0,
    SelectType_Image,
};

@class SelectView;
@protocol SelectViewDelegate <NSObject>

- (void)selectViewCancel;
- (void)selectView:(int)index;

@end


@interface SelectView : BaseUIView

@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIButton *btn1;
@property (nonatomic, strong) UIButton *btn2;

@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) SelectType type;


- (void)showInView:(UIView *) view;
- (void)cancelSelect:(UIView *) view;
@end
