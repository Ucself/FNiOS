//
//  CircleShapeLayer.m
//  CircularProgressControl
//
//  Created by Carlos Eduardo Arantes Ferreira on 22/11/14.
//  Copyright (c) 2014 Mobistart. All rights reserved.
//

#import "CircleShapeLayer.h"

@interface CircleShapeLayer ()

@property (assign, nonatomic) double initialProgress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic ,strong) CAShapeLayer *pointLayer;

@end

@implementation CircleShapeLayer

@synthesize frame = _frame;
@synthesize percent = _percent;

- (instancetype)init {
    if ((self = [super init]))
    {
        [self setupLayer];
    }
    
    return self;
}

- (void)layoutSublayers {

    self.path = [self drawPathWithArcCenter];
    self.progressLayer.path = [self drawPathWithArcCenter];
    self.pointLayer.path = [self drawPathWithArcCenter];
    [super layoutSublayers];
}

- (void)setupLayer {
    
    self.path = [self drawPathWithArcCenter];
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.f].CGColor;
    self.lineWidth = 3;
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.path = [self drawPathWithArcCenter];
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.lineWidth = 3;
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.lineJoin = kCALineJoinRound;
    [self addSublayer:self.progressLayer];
    
    self.pointLayer = [CAShapeLayer layer];
    self.pointLayer.path = [self drawPathWithArcCenter];
    self.pointLayer.fillColor = [UIColor clearColor].CGColor;
    self.pointLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.pointLayer.lineWidth = 8;
    self.pointLayer.lineCap = kCALineCapRound;
    self.pointLayer.lineJoin = kCALineJoinRound;
    [self addSublayer:self.pointLayer];
    
}

- (CGPathRef)drawPathWithArcCenter {
    
    CGFloat position_y = self.frame.size.height/2;
    CGFloat position_x = self.frame.size.width/2; // Assuming that width == height
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y)
                                          radius:position_y
                                      startAngle:(-M_PI/2)
                                        endAngle:(3*M_PI/2)
                                       clockwise:YES].CGPath;
}


- (void)setElapsedTime:(NSTimeInterval)elapsedTime {
    _initialProgress = [self calculatePercent:_elapsedTime toTime:_timeLimit];
    _elapsedTime = elapsedTime;
    
    self.progressLayer.strokeEnd = self.percent;
    self.self.pointLayer.strokeStart = self.percent - 0.0005;
    self.pointLayer.strokeEnd = self.percent;
    
//    NSLog(@"self.initialProgress==%f,self.initialProgress==%f",self.initialProgress,self.percent);
//    [self startAnimation];
}

- (double)percent {
    
    _percent = [self calculatePercent:_elapsedTime toTime:_timeLimit];
    return _percent;
}

- (void)setProgressColor:(UIColor *)progressColor {
    self.progressLayer.strokeColor = progressColor.CGColor;
    self.pointLayer.strokeColor = progressColor.CGColor;
}

- (double)calculatePercent:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime {
    
    if ((toTime > 0) && (fromTime > 0)) {
        
        CGFloat progress = 0;
        
        progress = fromTime / toTime;
        
        if ((progress * 10) > 10) {
            progress = 1.0f;
        }
        return progress;
    }
    else
        return 0.0f;
}

- (void)startAnimation {
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.1;
    pathAnimation.fromValue = @(self.initialProgress);
    pathAnimation.toValue = @(self.percent);
    pathAnimation.removedOnCompletion = NO;
    
    [self.progressLayer addAnimation:pathAnimation forKey:nil];
    
    NSLog(@"self.initialProgress==%f,self.initialProgress==%f",self.initialProgress,self.percent);
    
//    CABasicAnimation *pointPathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    pointPathAnimation.duration = 0.1;
//    pointPathAnimation.fromValue = @(0.00);
//    pointPathAnimation.toValue = @(self.percent);
//    pointPathAnimation.removedOnCompletion = YES;
//    [self.pointLayer addAnimation:pointPathAnimation forKey:nil];
}

@end
