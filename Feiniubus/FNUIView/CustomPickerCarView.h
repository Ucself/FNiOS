//
//  CustomPickerCarView.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/9/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"

@class CustomPickerCarView;
@protocol CustomPickerCarViewDelegate <NSObject>

@optional

- (void)pickerCarViewCancel;
- (void)pickerCarViewOKSeatIndex:(NSUInteger)seatIndex levelIndex:(NSUInteger)levelIndex amountIndex:(NSUInteger)amountIndex title:(NSString *)title pickerCarView:(CustomPickerCarView *)pickerCarView;

@end

@interface CustomPickerCarView : BaseUIView

@property(nonatomic, assign) id<CustomPickerCarViewDelegate> delegate;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *lineImageView;
@property (nonatomic,assign) BOOL isShowTitle;
@property (nonatomic,assign) int  carTypeAndLevelId;

-(instancetype)initWithFrame:(CGRect)frame dataSourceArray:(NSArray*)dataSourceArray seatIndex:(NSUInteger)seatIndex levelIndex:(NSUInteger)levelIndex amountIndex:(NSUInteger)amountIndex;
- (void)showInView:(UIView *) view;
- (void)cancelPicker:(UIView *) view;

@end
