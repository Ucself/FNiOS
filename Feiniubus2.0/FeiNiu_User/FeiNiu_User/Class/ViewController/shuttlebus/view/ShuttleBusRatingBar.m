//
//  RatingBar.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ShuttleBusRatingBar.h"

@interface ShuttleBusRatingBar (){

    float lastRating;
    
    float height;
    float width;
    
    UIImage *unSelectedImage;
    UIImage *halfSelectedImage;
    UIImage *fullSelectedImage;
}

@property (nonatomic,strong) UIImageView *s1;
@property (nonatomic,strong) UIImageView *s2;
@property (nonatomic,strong) UIImageView *s3;
@property (nonatomic,strong) UIImageView *s4;
@property (nonatomic,strong) UIImageView *s5;

@property (nonatomic,weak) id<ShuttleBusRatingBarDelegate> delegate;

@end

@implementation ShuttleBusRatingBar

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    lastRating = 0.0;
    
    _s1 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s2 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s3 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s4 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s5 = [[UIImageView alloc] initWithImage:unSelectedImage];
    _s1.contentMode = UIViewContentModeScaleAspectFit;
    _s2.contentMode = UIViewContentModeScaleAspectFit;
    _s3.contentMode = UIViewContentModeScaleAspectFit;
    _s4.contentMode = UIViewContentModeScaleAspectFit;
    _s5.contentMode = UIViewContentModeScaleAspectFit;
    
    [_s1 setUserInteractionEnabled:NO];
    [_s2 setUserInteractionEnabled:NO];
    [_s3 setUserInteractionEnabled:NO];
    [_s4 setUserInteractionEnabled:NO];
    [_s5 setUserInteractionEnabled:NO];
    
    [self addSubview:_s1];
    [self addSubview:_s2];
    [self addSubview:_s3];
    [self addSubview:_s4];
    [self addSubview:_s5];
}

/**
 *  初始化设置未选中图片、半选中图片、全选中图片，以及评分值改变的代理（可以用
 *  Block）实现
 *
 *  @param deselectedName   未选中图片名称
 *  @param halfSelectedName 半选中图片名称
 *  @param fullSelectedName 全选中图片名称
 *  @param delegate          代理
 */
-(void)setImageDeselected:(NSString *)deselectedName
             halfSelected:(NSString *)halfSelectedName
             fullSelected:(NSString *)fullSelectedName
              andDelegate:(id<ShuttleBusRatingBarDelegate>)delegate{
    
    self.delegate = delegate;
    
    unSelectedImage = [UIImage imageNamed:deselectedName];
    halfSelectedImage = halfSelectedName == nil ? unSelectedImage : [UIImage imageNamed:halfSelectedName];
    fullSelectedImage = [UIImage imageNamed:fullSelectedName];
    
    height = 16, width = 15;
    
//    if (height < [fullSelectedImage size].height) {
//        height = [fullSelectedImage size].height;
//    }
//    if (height < [halfSelectedImage size].height) {
//        height = [halfSelectedImage size].height;
//    }
//    if (height < [unSelectedImage size].height) {
//        height = [unSelectedImage size].height;
//    }
//    if (width < [fullSelectedImage size].width) {
//        width = [fullSelectedImage size].width;
//    }
//    if (width < [halfSelectedImage size].width) {
//        width = [halfSelectedImage size].width;
//    }
//    if (width < [unSelectedImage size].width) {
//        width = [unSelectedImage size].width;
//    }
//    
    
    [_s1 remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.top.equalTo(0);
        make.width.equalTo(width);
        make.height.equalTo(height);
    }];
    [_s2 remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(width +4);
        make.top.equalTo(0);
        make.width.equalTo(width);
        make.height.equalTo(height);
    }];
    [_s3 remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(2 * (width+4));
        make.top.equalTo(0);
        make.width.equalTo(width);
        make.height.equalTo(height);
    }];
    [_s4 remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(3 * (width+4));
        make.top.equalTo(0);
        make.width.equalTo(width);
        make.height.equalTo(height);
    }];
    [_s5 remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(4 * (width+4));
        make.top.equalTo(0);
        make.width.equalTo(width);
        make.height.equalTo(height);
    }];
    
    [self displayRating:0];
}

/**
 *  设置评分值
 *
 *  @param rating 评分值
 */
-(void)displayRating:(float)rating{
    [_s1 setImage:unSelectedImage];
    [_s2 setImage:unSelectedImage];
    [_s3 setImage:unSelectedImage];
    [_s4 setImage:unSelectedImage];
    [_s5 setImage:unSelectedImage];
    
    if (rating >= 0.5) {
        [_s1 setImage:halfSelectedImage];
    }
    if (rating >= 1) {
        [_s1 setImage:fullSelectedImage];
    }
    if (rating >= 1.5) {
        [_s2 setImage:halfSelectedImage];
    }
    if (rating >= 2) {
        [_s2 setImage:fullSelectedImage];
    }
    if (rating >= 2.5) {
        [_s3 setImage:halfSelectedImage];
    }
    if (rating >= 3) {
        [_s3 setImage:fullSelectedImage];
    }
    if (rating >= 3.5) {
        [_s4 setImage:halfSelectedImage];
    }
    if (rating >= 4) {
        [_s4 setImage:fullSelectedImage];
    }
    if (rating >= 4.5) {
        [_s5 setImage:halfSelectedImage];
    }
    if (rating >= 5) {
        [_s5 setImage:fullSelectedImage];
    }
    
    
//    if ([_delegate respondsToSelector:@selector(ratingBar:newRating:)]) {
//        [_delegate ratingBar:self newRating:rating];
//    }
    
}

/**
 *  获取当前的评分值
 *
 *  @return 评分值
 */
-(float)rating{
    return lastRating;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if (self.isIndicator) {
        return;
    }
    
    CGPoint point = [[touches anyObject] locationInView:self];
    int newRating = (int) (point.x / (width+5)) + 1;
    if (newRating > 5)
        return;
    
    if (point.x < 0) {
        newRating = 0;
    }
    
    if (newRating != lastRating){
        [self setRating:newRating];
        
        if ([_delegate respondsToSelector:@selector(ratingBar:newRating:)]) {
            [_delegate ratingBar:self newRating:lastRating];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
}

- (void)setRating:(float)rating
{
    lastRating = rating;
    [self displayRating:lastRating];
}

@end
