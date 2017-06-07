//
//  CircularProgressView.h
//  FeiNiu_User
//
//  Created by tianbo on 2017/1/12.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

@protocol CircularProgressDelegate;

@interface CircularProgressView : BaseUIView

@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *progressColor;
@property (assign, nonatomic) CGFloat lineWidth;


@property (assign, nonatomic) float duration;
@property (assign, nonatomic) id <CircularProgressDelegate> delegate;
@property (assign, nonatomic) BOOL isNeedDraw;

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;

-(void)setCenterImage:(UIImage*)image;

- (void)play;
- (void)pause;
- (void)revert;


@end

@protocol CircularProgressDelegate <NSObject>

- (void)circularProgressViewDidFinished:(CircularProgressView *)circularProgressView;
- (void)circularProgressViewDidCancel;

@end
