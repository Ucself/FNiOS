//
//  CircularProgressView.m
//  FeiNiu_User
//
//  Created by tianbo on 2017/1/12.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import "CircularProgressView.h"

@interface CircularProgressView ()
{

}


@property (assign, nonatomic) float progress;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) float currentTime;

@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        _backColor = backColor;
        _progressColor = progressColor;
        _lineWidth = lineWidth;
        
        [self initUI];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    _duration = 10;
    _currentTime = -1;
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.backgroundColor = [UIColor clearColor];

    [self addSubview:_imageView];
    [_imageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.equalTo(80);
        make.height.equalTo(80);
    }];
    
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

- (void)drawRect:(CGRect)rect
{
    //draw background circle
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2)
                                                              radius:self.bounds.size.width / 2 - self.lineWidth / 2
                                                          startAngle:(CGFloat) - M_PI_2
                                                            endAngle:(CGFloat)(1.5 * M_PI)
                                                           clockwise:YES];
    [self.backColor setStroke];
    backCircle.lineWidth = self.lineWidth;
    [backCircle stroke];
    
    if (self.progress != 0) {
        //draw progress circle
        UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2)
                                                                      radius:self.bounds.size.width / 2 - self.lineWidth / 2
                                                                  startAngle:(CGFloat) - M_PI_2
                                                                    endAngle:(CGFloat)(- M_PI_2 + self.progress * 2 * M_PI)
                                                                   clockwise:YES];
        [self.progressColor setStroke];
        progressCircle.lineWidth = self.lineWidth;
        [progressCircle stroke];
    }
}

- (void)updateProgressCircle{
    
    if (self.currentTime >= self.duration) {
        [self pause];
        
        if ([self.delegate respondsToSelector:@selector(circularProgressViewDidFinished:)]) {
            [self.delegate circularProgressViewDidFinished:self];
        }
        return;
    }
    
    self.currentTime++;
    self.progress = (float) (self.currentTime / self.duration);
    [self setNeedsDisplay];
}

- (void)play{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(updateProgressCircle) userInfo:nil repeats:YES];
    [self.timer fire];

}

- (void)pause{
    [self.timer invalidate];
}

- (void)revert{
    [self.timer invalidate];
    self.currentTime = -1;
    [self updateProgressCircle];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    NSLog(@"gesture.state = %ld", gesture.state);
    if(gesture.state == UIGestureRecognizerStateBegan){
        if (!self.isNeedDraw) {
            //不需要绘制直接回调完成
            if ([self.delegate respondsToSelector:@selector(circularProgressViewDidFinished:)]) {
                [self.delegate circularProgressViewDidFinished:self];
            }
            return;
        }
        else{
            [self play];
        }
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.currentTime < self.duration)  {
            [self revert];
        }
        
    }
}

-(void)setCenterImage:(UIImage*)image
{
    self.imageView.image = image;
}

@end
